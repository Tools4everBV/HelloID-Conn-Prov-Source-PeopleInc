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
    Write-Verbose 'Retrieving employee information'
    $headers = [System.Collections.Generic.Dictionary[string, string]]::new()
    $headers.Add("PSPToken", $($config.PSPToken))
    $headers.Add("PSPViewName", $($config.PSPViewName))

    $splatParams = @{
        Uri     = "$($config.BaseUrl)/PSPGetViewData/Data/GetViewData"
        Method  = 'GET'
        Headers = $headers
    }
    $persons = Invoke-RestMethod @splatParams -Verbose:$false

    Write-Verbose 'Importing raw data in HelloID'
    foreach ($person in $persons ) {
        $person | Add-Member -NotePropertyMembers @{ ExternalId = $person.werknemerid }
        $person | Add-Member -NotePropertyMembers @{ DisplayName = "$($person.roepnaam) $($person.achternaam)".trim(' ') }
        $person | Add-Member -NotePropertyMembers @{ Contracts = [System.Collections.Generic.List[Object]]::new() }

        Write-Output $person | ConvertTo-Json -Depth 10
    }
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
