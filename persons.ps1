########################################################################
# HelloID-Conn-Prov-Source-PeopleInc-Persons
#
# Version: 1.0.0
########################################################################
# Initialize default value's
$config = $Configuration | ConvertFrom-Json

# Set debug logging
switch ($($config.IsDebug)) {
    $true { $VerbosePreference = 'Continue' }
    $false { $VerbosePreference = 'SilentlyContinue' }
}

#region functions
function Resolve-HTTPError {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline
        )]
        [object]$ErrorObject
    )
    process {
        $httpErrorObj = [PSCustomObject]@{
            FullyQualifiedErrorId = $ErrorObject.FullyQualifiedErrorId
            MyCommand             = $ErrorObject.InvocationInfo.MyCommand
            RequestUri            = $ErrorObject.TargetObject.RequestUri
            ScriptStackTrace      = $ErrorObject.ScriptStackTrace
            ErrorMessage          = ''
        }
        if ($ErrorObject.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.HttpResponseException') {
            $httpErrorObj.ErrorMessage = $ErrorObject.ErrorDetails.Message
        } elseif ($ErrorObject.Exception.GetType().FullName -eq 'System.Net.WebException') {
            $httpErrorObj.ErrorMessage = [System.IO.StreamReader]::new($ErrorObject.Exception.Response.GetResponseStream()).ReadToEnd()
        }
        Write-Output $httpErrorObj
    }
}
#endregion

try {
    Write-Verbose 'Adding authorization headers'
    $headers = [System.Collections.Generic.Dictionary[string, string]]::new()
    $headers.Add('PSPToken', $($config.PSPToken))
    $headers.Add('Accept', 'application/json')
    $headers.Add('PSPViewName', $($config.EmployeeView))

    $splatParams = @{
        Uri     = "$($config.BaseUrl)/PSPGetViewData/Data/GetViewData"
        Method  = 'GET'
        Headers = $headers
    }

    Write-Verbose "Getting employee data from view: [$($config.EmployeeView)]"
    $employees = Invoke-RestMethod @splatParams -Verbose:$false
    $activeEmployees = $employees.foreach({$_ | Where-Object {$_.werknemerid -ne ""}})

    Write-Verbose "Getting contract data from view: [$($config.ContractView)]"
    $headers['PSPViewName'] = $($config.ContractView)
    $contracts = Invoke-RestMethod @splatParams -Verbose:$false

    Write-Verbose 'Importing raw data in HelloID'
    $contractsLookupTable = $contracts | Group-Object -Property werknemerid -AsHashTable -AsString
    $activeEmployees.ForEach({

        $contractList = [System.Collections.Generic.List[Object]]::new()
        $contractList.AddRange($contractsLookupTable[$employee.werknemerid])

        $_ | Add-Member -MemberType NoteProperty -Name ExternalId -Value $_.werknemerid
        $_ | Add-Member -MemberType NoteProperty -Name DisplayName -Value $_.red_samengesteldenaam
        $_ | Add-Member -MemberType NoteProperty -Name Contracts -Value $contractList

        Write-Output $_ | ConvertTo-Json -Depth 10
    })
} catch {
    $ex = $PSItem
    if ($($ex.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.HttpResponseException') -or
        $($ex.Exception.GetType().FullName -eq 'System.Net.WebException')) {
        $errorMessage = Resolve-HTTPError -ErrorObject $ex
        Write-Verbose "Could not retrieve PeopleInc employees. Error: $errorMessage"
    } else {
        Write-Verbose "Could not retrieve PeopleInc employees. Error: $($ex.Exception.Message)"
    }
}
