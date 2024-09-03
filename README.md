# RollBackWindowsUpdates
Roll Back Windows Updates.


*) Download the file to C:\temp\RollbackDynamic.ps1
*) Open Powershell as the Administrator and Navidate to C:\Scripts.
*) Run the script:   .\RollBackDynamic.ps1
[hvserver]: PS C:\script> dir


    Directory: C:\script


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----         02/3/2024   3:30 PM           8141 RollBackDynamic.ps1


[hvserver]: PS C:\script> .\RollBackDynamic.ps1

*) Roll back will output something like this:
[hvserver]: PS C:\script> .\RollBackDynamic.ps1
Transcript started, output file is C:\script\rollbackLog.txt
New Timestamp:
09/03/2024
--------------------------------------------------------
This month's tuesday is :  9/10/2024
--------------------------------------------------------
Last month's tuesday is :  8/13/2024
--------------------------------------------------------
Today's date is :  9/3/2024
--------------------------------------------------------
Last Time Ran :
--------------------------------------------------------
Checking Staging folder existance
--------------------------------------------------------
Path exists!
--------------------------------------------------------
Building Code Execution...
--------------------------------------------------------
The date is less than this month's tuesday
Days to Rollback :  21
CodeBuild completed...
--------------------------------------------------------
Here's the Code that will be executed
--------------------------------------------------------
dism /Online /Remove-Package /PackageName:Package_for_DotNetRollup~31bf3856ad364e35~amd64~~10.0.4108.3 /NoRestart
dism /Online /Remove-Package /PackageName:Package_for_RollupFix~31bf3856ad364e35~amd64~~17763.6189.1.18 /NoRestart
dism /Online /Remove-Package /PackageName:Package_for_ServicingStack_6174~31bf3856ad364e35~amd64~~17763.6174.1.2 /NoRestart


*) Safety mechanism added to the script. to Prevent multiple runs, if you want to re-run it you can delete the following log located in the same directory of the script, "thisMonthTimestamp.log" if you do not you will get the following message

[hvserver]: PS C:\script> .\RollBackDynamic.ps1
Transcript started, output file is C:\script\rollbackLog.txt
The date is less than this month's tuesday
Days to Rollback :  21
you will accidentally roll back another month .... wait another month
Unable to Rollback
Transcript stopped, output file is C:\script\rollbackLog.txt
