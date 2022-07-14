
# HelloID-Conn-Prov-Source-PeopleInc

| :warning: Warning |
|:---------------------------|
| Note that this connector is "a work in progress" and therefore not ready to use in your production environment. |

| :warning: Warning |
|:---------------------------|
| This connector has not been tested on a PeopleInc enviroment. Development is based on documentation. Therefore; changes will have to be made according to your environment. |

| :information_source: Information |
|:---------------------------|
| This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements. |

<p align="center">
  <img src="https://www.peopleinc.nl/wp-content/uploads/2021/04/peopleinc-logo-regular.png">
</p>

## Table of contents

- [Introduction](#Introduction)
- [Getting started](#Getting-started)
  + [Connection settings](#Connection-settings)
  + [Prerequisites](#Prerequisites)
  + [Remarks](#Remarks)
- [Setup the connector](@Setup-The-Connector)
- [Getting help](#Getting-help)
- [HelloID Docs](#HelloID-docs)

## Introduction

_HelloID-Conn-Prov-Source-PeopleInc_ is a _source_ connector. PeopleInc provides a set of REST API's that allow you to programmatically interact with it's data.

## Getting started

In order to use the API, a view must be created within PeopleInc. A view specifies which data will be returned. To get a list of all available views, a HTTP: GET must be executed to: https://mijn.{environment-name}.nl/PSPGetViewData/Data/GetViews

> Currently only a limited data set in included. Changes will have to be made according to your needs.

### Connection settings

The following settings are required to connect to the API.

| Setting      | Description                            | Mandatory   |
| ------------ | -----------                            | ----------- |
| PSPViewName  | The name of the view that will be read | Yes         |
| PSPToken     | The PSPToken to connect to the API     | Yes         |
| BaseUrl      | The URL to the API                     | Yes         |

### Prerequisites

- In order to use the API, a view must be created within PeopleInc. A view specifies which data will be returned. To get a list of all available views, a HTTP: GET must be executed to: https://mijn.{environment-name}.nl/PSPGetViewData/Data/GetViews

### Remarks

> This connector has not been tested on a real PeopleInc. enviroment. Development is based on documentation. Therefore; changes will have to be made according to your environment.

## Setup the connector

> _How to setup the connector in HelloID._ Are special settings required. Like the _primary manager_ settings for a source connector.

## Getting help

> _For more information on how to configure a HelloID PowerShell connector, please refer to our [documentation](https://docs.helloid.com/hc/en-us/articles/360012557600-Configure-a-custom-PowerShell-source-system) pages_

> _If you need help, feel free to ask questions on our [forum](https://forum.helloid.com)_

## HelloID docs

The official HelloID documentation can be found at: https://docs.helloid.com/
