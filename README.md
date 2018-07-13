![alt text](https://i.imgsafe.org/52/5236bd6547.jpeg "IronScripter Logo")
# Get-VenafiPrereqReport
### SYNOPSIS
Pulls a report for use in verifying prerequisites for Venafi Certificate Manager.
### DESCRIPTION
This module collects a report of 4 key prerequisites needed for Venafi Certificate Manager to operate normally. They are WinRM, WMF, IIS Snap-in for PowerShell, and a specific service account that Venafi uses. The service account is set to “certadmin” by default, but can be passed into the cmdlet. This cmdlet requires admin credentials to be run. It can be used remotely or locally. It uses WinRM to connect to the servers/ workstations.
Created By James A. Arnett
### EXAMPLE
***This is the basic example of the syntax***

**Running this command, you will be prompted for a server list. This list should be line delimited and a .txt. It will run on the list remotely. Make sure all servers are accessible from this location.**
```powershell
C:\PS> Get-VenafiPrereqReport
```
**Running this command, will run the report against the computer that the cmdlet is installed on. It should be used in instances where WinRM is not enabled. It will display the output to screen.**
```powershell
C:\PS> Get-VenafiPrereqReport -Local
```
**Running this command, you will be prompted for a server list. This list should be line delimited and a .txt. You also will need to specify the service account used in your environment.**
```powershell
C:\PS> Get-VenafiPrereqReport -ServiceAccount <SERVICEACCOUNT>
```
**Running this command, will run the report against the computer that the cmdlet is installed on. It should be used in instances where WinRM is not enabled. You also will need to specify the service account used in your environment. It will display the output to screen.**
```powershell
C:\PS> Get-VenafiPrereqReport -Local -ServiceAccount <SERVICEACCOUNT>
```

### Installation Instructions
1. Clone or download Repo.
2. Open elevated PowerShell window.
3. Copy path of directory where you cloned/ downloaded repo to.
4. type ```Import-Module "Previously copied path"```
  * If you receive an error you might need to adjust your execution policy. This is a great article about that [4sysops.com PS Execution Policy](https://4sysops.com/archives/powershell-bypass-executionpolicy-to-run-downloaded-scripts/ "4sysops.com")
5. type desired command.

### LINKS
[The Bloggin Techie](http://bloggintechie.blogspot.com/ "James' Blog")

[Chromebook Paradise](https://chromebookparadise.wordpress.com/ "Chromebook Paradise")