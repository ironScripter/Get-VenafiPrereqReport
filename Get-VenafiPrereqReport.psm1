Function Get-VenafiPrereqReport {
    <#
    .SYNOPSIS
    Pulls a report for use in verifying prerequisites for Venafi Certificate Manager.

    .DESCRIPTION
    This module collects a report of 4 key prerequisites needed for Venafi Certificate Manager to operate normally. They are WinRM, WMF, IIS Snap-in for PowerShell, and a specific service account that Venafi uses. The service account is set to “certadmin” by default, but can be passed into the cmdlet. This cmdlet requires admin credentials to be run. It can be used remotely or locally. It uses WinRM to connect to the servers/ workstations.

    Created by James A. Arnett
    07/2018
        
    .EXAMPLE
    This is the basic example of the syntax

    Running this command, you will be prompted for a server list. This list should be line delimited and a .txt. It will run on the list remotely. Make sure all servers are accessible from this location.

    C:\PS> Get-VenafiPrereqReport

    Running this command, will run the report against the computer that the cmdlet is installed on. It should be used in instances where WinRM is not enabled. It will display the output to screen.

    C:\PS> Get-VenafiPrereqReport -Local

    Running this command, you will be prompted for a server list. This list should be line delimited and a .txt. You also will need to specify the service account used in your environment.

    C:\PS> Get-VenafiPrereqReport -ServiceAccount <SERVICEACCOUNT>

    Running this command, will run the report against the computer that the cmdlet is installed on. It should be used in instances where WinRM is not enabled. You also will need to specify the service account used in your environment. It will display the output to screen.

    C:\PS> Get-VenafiPrereqReport -Local -ServiceAccount <SERVICEACCOUNT>


    .LINK
    http://bloggintechie.blogspot.com/
    https://chromebookparadise.wordpress.com/
    #>  

    [cmdletbinding()]Param(
        [string]$ServiceAccount = "certadmin",
        [switch]$Local
        )

    if(!$Local){
        Function GetServerListPath{   
            [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
            $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
            $OpenFileDialog.initialDirectory = $initialDirectory
            $OpenFileDialog.filter = "All files (*.*)| *.*"
            $OpenFileDialog.Title = "Please Specify Serverlist File:"
            $OpenFileDialog.ShowHelp = $false
            $OpenFileDialog.DefaultExt = "txt"
            $OpenFileDialog.Filter = "Text files (*.txt)|*.txt"
            $Show = $OpenFileDialog.ShowDialog()
            If ($Show -eq "OK"){
                Return $OpenFileDialog.filename
            }Else{
                Write-Error "Operation cancelled by user." -ErrorAction Stop
            }
        }
        Try{
            $ServerListPath = GetServerListPath
            $serverList = Get-Content $ServerListPath
            $Report = @()
            ForEach($Server in $ServerList){
	            $Session = New-PSSession -ComputerName $Server -ErrorVariable SER -ErrorAction SilentlyContinue
	            $command = {
		            ####### Check WMF Version ######
		            $WMFVersion = $PSVersionTable.PSVersion.Major

		            ####### Check for IIS Snap In ######
		            $SnapIn = Get-Module -ListAvailable | ?{$_.Name -like "*Web*"}

		            ####### Get User Data #######
		            $user = @()
		            $admins = @()
		            $group =[ADSI]"WinNT://$env:computername/Administrators" 
		            $members = @($group.psbase.Invoke("Members"))
		            $members | foreach {
		             $obj = new-object psobject -Property @{
		             Server = $env:computername
		             Admin = $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
		             }
		             $admins += $obj
		             }
		            $user += $admins
		            $user = $user | ?{$_.Admin -like "*$ServiceAccount*"}

		            ####### Build Results Object #######
		            $Results = New-Object PSObject
		            $Results | Add-Member Noteproperty ServerName $env:computername
		            if($user){$Results | Add-Member Noteproperty SvcAcctExst $true
			            }else{$Results | Add-Member Noteproperty SvcAcctExst $false
			            }
		            if($WMFVersion -ge 3){$Results | Add-Member Noteproperty WMF $true
			            }else{$Results | Add-Member Noteproperty WMF $false}
		            if($SnapIn){$Results | Add-Member Noteproperty SnapinExst $true
			            }else{$Results | Add-Member Noteproperty SnapinExst $false}
		            $Results | Add-Member Noteproperty WinRM $true
		            $Results
	            }
	            if($SER){
		            $Return = New-Object PSObject -Property @{ 
			            ServerName = $Server
			            WinRM = "Not Enabled. Check Server Manually"
			            SnapinExst = $null
			            WMF = $null
			            SvcAcctExst = $null
			            }
		            }else{
			            $Return = Invoke-Command -Session $Session -ScriptBlock $command
			            }
	            $Report += $Return
	            }
            $ReportPath = "$env:userprofile\Desktop\Venafi Prereq Report.csv"
            $Report | Export-Csv -NoTypeInformation -Path $ReportPath
            Write-Host "Report has been generated and placed at $ReportPath"
        }Catch{
            Write-Error "An Error has occurred. Please try again."
        }
    }else{
        ####### Check WMF Version ######
        $WMFVersion = $PSVersionTable.PSVersion.Major

        ####### Check for IIS Snap In ######
        $SnapIn = Get-Module -ListAvailable | ?{$_.Name -like "*Web*"}

        ####### Get User Data #######
        $user = @()
        $admins = @()
        $group =[ADSI]"WinNT://$env:computername/Administrators" 
        $members = @($group.psbase.Invoke("Members"))
        $members | foreach {
         $obj = new-object psobject -Property @{
         Server = $env:computername
         Admin = $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
         }
         $admins += $obj
         }
        $user += $admins
        $user = $user | ?{$_.Admin -like "*$ServiceAccount*"}

        ####### Check WinRM Service Start Type #####
        $WinRM = Get-Service -Name winrm | ?{$_.StartType -like "Automatic"}

        ####### Build Results Object #######
        $Results = New-Object PSObject
        $Results | Add-Member Noteproperty ServerName $env:computername
        if($user){$Results | Add-Member Noteproperty SvcAcctExst $true
	        }else{$Results | Add-Member Noteproperty SvcAcctExst $false
	        }
        if($WMFVersion -ge 3){$Results | Add-Member Noteproperty WMF $true
	        }else{$Results | Add-Member Noteproperty WMF $false}
        if($SnapIn){$Results | Add-Member Noteproperty SnapinExst $true
	        }else{$Results | Add-Member Noteproperty SnapinExst $false}
        if($WinRM){$Results | Add-Member Noteproperty WinRM $true
	        }else{$Results | Add-Member Noteproperty WinRM $false}
        $Results
    }
}
Export-ModuleMember -Function Get-*