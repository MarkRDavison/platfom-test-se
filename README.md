# Software Engineer in Platform code test

This code is an example of a very .net basic application that implements a web app which talks to a web api and on to a DB. Its purpose is to present some part of an application that has user profiles which is information that the supposed app would record about a person - ie. Name, Address, Email etc. The developer is no longer here and we need to complete the work to release this.

As a part of the exercise we will be asking you to make some changes to this application. We are also interested in your thoughts on whether we can ship it as is. Also if you were to own this application long term, what plans would you want for improvements.

## Prerequisites 

- This application needs .net core 3.1+ to run which you can download from [here](https://dotnet.microsoft.com/download).
- You will also need to install the [entity framework](https://docs.microsoft.com/en-us/ef/core/cli/dotnet)

### To build the code use the command `dotnet build`
---
e.g.

```
C:\dev\platfom-test-se2 on  master[?!]
➜  dotnet build
Microsoft (R) Build Engine version 16.8.0+126527ff1 for .NET
Copyright (C) Microsoft Corporation. All rights reserved.

  Determining projects to restore...
  All projects are up-to-date for restore.
  ProfilesAppTests -> C:\dev\platfom-test-se2\ProfilesAppTests\bin\Debug\net5.0\ProfilesAppTests.dll
  ProfilesApp -> C:\dev\platfom-test-se2\ProfilesApp\bin\Debug\netcoreapp3.1\ProfilesApp.dll
  ProfilesApp -> C:\dev\platfom-test-se2\ProfilesApp\bin\Debug\netcoreapp3.1\ProfilesApp.Views.dll

Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:02.82
C:\dev\platfom-test-se2 on  master[?!]
➜  dotnet test
  Determining projects to restore...
  All projects are up-to-date for restore.
  ProfilesAppTests -> C:\dev\platfom-test-se2\ProfilesAppTests\bin\Debug\net5.0\ProfilesAppTests.dll
Test run for C:\dev\platfom-test-se2\ProfilesAppTests\bin\Debug\net5.0\ProfilesAppTests.dll (.NETCoreApp,Version=v5.0)
Microsoft (R) Test Execution Command Line Tool Version 16.8.1
Copyright (c) Microsoft Corporation.  All rights reserved.

Starting test execution, please wait...
A total of 1 test files matched the specified pattern.
  Failed Test1 [30 ms]
  Error Message:
     Expected: False
  But was:  True

  Stack Trace:
     at ProfilesAppTests.Tests.Test1() in c:\dev\platfom-test-se2\ProfilesAppTests\UnitTest1.cs:line 15


Failed!  - Failed:     1, Passed:     0, Skipped:     0, Total:     1, Duration: 30 ms - ProfilesAppTests.dll (net5.0)
C:\dev\platfom-test-se2 on  master[?!]
➜

 ```

### Database 

- You need to [install the entity framework](https://docs.microsoft.com/en-us/ef/core/cli/dotnet):

```
# install & update Entity framework 
dotnet tool install --global dotnet-ef
dotnet tool update --global dotnet-ef
```

- you can recreate the db using this:
```

rm -r Migrations
dotnet ef migrations add InitalCreate
dotnet ef database update
```

- you can run the app using `dotnet run --project .\ProfilesApp\ProfilesApp.csproj`

### Deployment Infrastrastructure

---
**NOTE** You'll need [Docker Desktop](https://www.docker.com/products/docker-desktop) installed to make this work. 

There is a script (`init.ps1`) that can be used to create an apppropriate infrstructure.

```
.\init.ps1 -subscriptionName "your_sub" -name "your_name" -sqlPassword (ConvertTo-SecureString  -AsPlainText -Force "your_sql_password")
```

The following will be created:

- A resource group (*d-aue-quasar-interviewtest-your_name-rg*)
- A Sql Server (*d-aue-quasar-interviewtest-your_name-sql*)
- A Sql DB (*d-aue-quasar-interviewtest-your_name-db (d-aue-quasar-interviewtest-your_name-sql/d-aue-quasar-interviewtest-your_name-db) with credentials your_name-admin/your_sql_password*)
- A Container registry containing on repository with the [latest DockerHub image of grafana](https://hub.docker.com/r/grafana/grafana/)
- An App Service Plan (*d-aue-quasar-interviewtest-your_name-asplan*)
- A Web App Service (*d-aue-quasar-interviewtest-your_name-asplan-app*)

One manual step remaims and that is to set the deployment credentials
```
az webapp deployment user set --user-name "some_user_id" --password "some_user_deployment_password" --subscription "your_sub"
```
To deploy your app to the infrastructure you'll need to add an addition git remote to your repo. More info [here](https://docs.microsoft.com/en-us/azure/app-service/scripts/cli-deploy-local-git). The instructions are printed at the end of the script. e.g.:

```
git remote add azure "https://some_user_id@d-aue-quasar-interviewtest-your_name-asplan-app.scm.azurewebsites.net/d-aue-quasar-interviewtest-your_name-asplan-app.git"
git push azure
```

You will supply those deployment credentials when you push your app the first time. 

You can tear down the infrastructure using:

```
.\init.ps1 -subscriptionName "your_sub" -name "your_name" -sqlPassword (ConvertTo-SecureString  -AsPlainText -Force "your_sql_password") -teardown $true
```