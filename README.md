# Software Engineer in Platform code test

This code is an example of a very .net basic application that implements a web app what talks to a web api and on to a DB. Its purpose is to present some part of an application that has user profiles which is information that the supposed app would record about a person - ie. Name, Address, Email etc. The developer is no longer here and we need to complete the work to release this.

This code is very basic state and not something we can release as is.

## Challenge

- How would you improve the code, so that we can **ship it** to our first customers?
- What is wrong with it?
- What is missing?
- What should be cleaned up? 
- We will be supporting this for a long time so we need to ensure that the code is in a state that this can be acheived. What will we need to add/change to make that sure we can?

## Requirements

- This test needs .net core 3.1+ to run which you can download from [here](https://dotnet.microsoft.com/download).

### To build the code use the command `dotnet build`
---
e.g.

```
➜  dotnet build
Microsoft (R) Build Engine version 16.8.0+126527ff1 for .NET
Copyright (C) Microsoft Corporation. All rights reserved.

  Determining projects to restore...
  All projects are up-to-date for restore.
  DotNetCoreSqlDb -> C:\dev\test\bin\Debug\netcoreapp3.1\DotNetCoreSqlDb.dll
  DotNetCoreSqlDb -> C:\dev\test\bin\Debug\netcoreapp3.1\DotNetCoreSqlDb.Views.dll

Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:01.10

➜  dotnet test
  Determining projects to restore...
  All projects are up-to-date for restore.
C:\dev\test on  master[?!]

 ```

### Deployment Infrastrastructure 

---
**NOTE** You'll need [Docker Desktop](https://www.docker.com/products/docker-desktop) installed to make this work. 

There is a script (`init.ps1`) that can be used to create an apppropriate infrstructure.

```
.\init.ps1 -subscriptionName "your_sub" -name "your_name" -sqlPassword (ConvertTo-SecureString  -AsPlainText -Force "your_sql_password")
```

The following will be created:

- A resource group (*d-aue-quasar-interviewtest-wilfred-rg*)
- A Sql Server (*d-aue-quasar-interviewtest-wilfred-sql*)
- A Sql DB (*d-aue-quasar-interviewtest-wilfred-db (d-aue-quasar-interviewtest-wilfred-sql/d-aue-quasar-interviewtest-wilfred-db) with credentials your_name-admin/your_sql_password*)
- A Container registry containing on repository with the [latest DockerHub image of grafana](https://hub.docker.com/r/grafana/grafana/)
- A App Service Plan (*d-aue-quasar-interviewtest-wilfred-asplan*)
- A Web App Service (*d-aue-quasar-interviewtest-wilfred-asplan-app*)

One manual step remaims and that is to set the deployment credentials
```
az webapp deployment user set --user-name "some_user_id" --password "some_user_deployment_password"
```
To deploy your app to the infrastructure you'll need to add an addition git remote to your repo.  The instructions are printed at the end of the script. e.g.:

```
git remote add azure "https://some_user_id@d-aue-quasar-interviewtest-your_name-asplan-app.scm.azurewebsites.net/d-aue-quasar-interviewtest-your_name-asplan-app.git"
git push azure
```

You will supply those deployment credential when you push your app the first time. 