
#This script will do a regedit to stop automatic updates. The 'Version' Variable can be updated to rewrite the registry value to whatever windows version you want deployed.

#region Pseudocode -----------------------------Pseudocode

<#First: The script will navigate to the local machine hive
Second: Check to see if the 'WindowsUpdate' Key exists, if not then create it
Third: Check if the 'TargetReleaseVersion' and 'TargetReleaseVersionInfo' properties exist, if not, create them 
Fourth: Assign values to new properties. 
Finally, if no error has occurred then commit the transaction. If it failed, the transaction will roll back

Note: It seems that machine may be defaulted to not allowing scripts run, you can remedy this by opening this script 
in the Powershell ISE, running Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass, and then running this script

The Set-ExecutionPolicy cmdlet will allow for scripts to be run during this session alone, once powershell ise is closed it goes back to not allowing
#>

#Program written by DJM 11/18/22
#endregion

#region Local Variables ---------------------------Local Variables

$version = "21H1"
$path = "HKLM:\software\Policies\Microsoft\Windows\WindowsUpdate"

#endregion


#set path
set-location -path $path

#start the transaction, encase everything in try/catch with catch invoking a rollback
Start-Transaction
try 
{
    #Check if key already exists, if not create it
    $key = try 
    {
        Get-Item -Path $path -ErrorAction Stop
    }
    catch 
    {
        New-Item -Path $path -Force
    }

    #check if the keyvalues exist, if not create them, if they do simply update the  values
    try
    {
        Set-ItemProperty -Path $key.PSPath -Name 'TargetReleaseVersion' -PropertyType Dword -Value 1 -ErrorAction Stop
    }
    catch
    {
        New-ItemProperty -Path $key.PSPath -Name 'TargetReleaseVersion' -PropertyType Dword -Value 1 -force
    }

    try
    {
        Set-ItemProperty -Path $key.PSPath -Name 'TargetReleaseVersionInfo' -PropertyType String -Value $version -ErrorAction Stop
    }
    catch
    {
        New-ItemProperty -Path $key.PSPath -Name 'TargetReleaseVersionInfo' -PropertyType String -Value $version -Force
    }
    #if we made it this far with no error, commit the transaction
    Complete-Transaction
}
catch 
{
    Undo-Transaction
}