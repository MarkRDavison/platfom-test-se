# Software Engineer in Platform code test

This code is an example of a very .net application that implements a web app what talks to a web api and through to a DB. It's purpose is to present some part of an application that has profiles which information that the supposed app would record about a person - ie. Name, Address, email etc. The developer is no longer here and we need to complete the work to release this.

This code is very basic and is in a very poor state and not something we can release as is.

## Challenge

- How would you improve the code, so that we can **ship it** to our first customers?
- What is wrong with it?
- What is missing?
- What should be cleaned up?  

We will be supporting this for a long time so we need to ensure that the code is in a state that this can be acheived.
## Requirements

- This test needs .net core 3.1+ to run which you can download from [here](https://dotnet.microsoft.com/download).

### To build the code use the command `dotnet build`

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
