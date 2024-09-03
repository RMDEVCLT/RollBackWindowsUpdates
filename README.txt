# RollBackWindowsUpdates
Dynamic Roll Back for Windows Updates.
Things to know: 
- It will search and identify what has been installed between the 2nd tuesday of the month and the previous 2nd tuesday of the month. 
- It cannot be run 2x by default. 
- It cannot remove servicing stack this is locked down by Microsoft. 

HOW TO USE IT:
1) Download the file to C:\temp\RollbackDynamic.ps1 (Doesn't really matter where you put it)
2) Open Powershell CLI as the Administrator and Navidate to C:\Scripts.
3) Run the script:   .\RollBackDynamic.ps1.
Sample output.
[hvserver]: PS C:\script> dir


    Directory: C:\script


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----         02/3/2024   3:30 PM           8141 RollBackDynamic.ps1


[hvserver]: PS C:\script> .\RollBackDynamic.ps1

4) Roll back will output something like this:
[hvserver]: PS C:\script> .\RollBackDynamic.ps1
Transcript started, output file is C:\script\rollbackLog.txt
New Timestamp:
08/16/2024
--------------------------------------------------------
This month's tuesday is :  08/13/2024
--------------------------------------------------------
Last month's tuesday is :  07/09/2024
--------------------------------------------------------
Today's date is :  08/16/2024
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
Days to Rollback :  03
CodeBuild completed...
--------------------------------------------------------
Here's the Code that will be executed
--------------------------------------------------------
dism /Online /Remove-Package /PackageName:Package_for_DotNetRollup~31bf3856ad364e35~amd64~~10.0.4108.3 /NoRestart
dism /Online /Remove-Package /PackageName:Package_for_RollupFix~31bf3856ad364e35~amd64~~17763.6189.1.18 /NoRestart
dism /Online /Remove-Package /PackageName:Package_for_ServicingStack_6174~31bf3856ad364e35~amd64~~17763.6174.1.2 /NoRestart


5) Safety mechanism added to the script. to Prevent multiple runs, if you want to re-run it you can delete the following log located in the same directory of the script, "thisMonthTimestamp.log" if you do not you will get the following message

[hvserver]: PS C:\script> .\RollBackDynamic.ps1
Transcript started, output file is C:\script\rollbackLog.txt
The date is less than this month's tuesday
Days to Rollback :  03
you will accidentally roll back another month .... wait another month
Unable to Rollback
Transcript stopped, output file is C:\script\rollbackLog.txt
