# Ensure script is run as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  Write-Warning "Please run this script as an Administrator!"
  Break
}

# 1. Update PowerShell to latest version and packages
Write-Host "Updating PowerShell and packages..."
Install-Module -Name PowerShellGet -Force -AllowClobber
Update-Module -Name PowerShellGet
Install-Module -Name PSWindowsUpdate -Force
Get-WindowsUpdate -Install -AcceptAll -AutoReboot

# 2. Disable Windows Automatic Updates
Write-Host "Disabling Windows Automatic Updates..."
$AutoUpdatePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
If (Test-Path -Path $AutoUpdatePath) {
    Set-ItemProperty -Path $AutoUpdatePath -Name NoAutoUpdate -Value 1
} Else {
    New-Item -Path $AutoUpdatePath -Force
    New-ItemProperty -Path $AutoUpdatePath -Name NoAutoUpdate -Value 1 -PropertyType DWORD
}
Write-Host "Waiting. . . "
Start-Sleep 10

# 3. Block inbound on all ports except 80, 3389, and 443
Write-Host "Configuring Windows Firewall..."
# Reset all Firewall rules
netsh advfirewall reset

Write-Host "Waiting. . . "
Start-Sleep 10

# Set default inbound action to block
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound

Write-Host "Waiting. . . "
Start-Sleep 10

# Allow specific inbound ports
netsh advfirewall firewall add rule name="Allow Inbound Port 80" dir=in action=allow protocol=TCP localport=80
netsh advfirewall firewall add rule name="Allow Inbound Port 3389" dir=in action=allow protocol=TCP localport=3389
netsh advfirewall firewall add rule name="Allow Inbound Port 443" dir=in action=allow protocol=TCP localport=443
Write-Host "Waiting. . . "
Start-Sleep 10

Write-Host "Waiting. . . "
Start-Sleep 1
Write-Host "Waiting. . . "
Start-Sleep 1
Write-Host "Waiting. . . "
Start-Sleep 1
Write-Host "Waiting. . . "
Start-Sleep 1
Write-Host "Waiting. . . "
Start-Sleep 1
Write-Host "Waiting. . . "
Start-Sleep 1
Write-Host "Waiting. . . "
Start-Sleep 1
Write-Host "Waiting. . . "
Start-Sleep 1
Write-Host "Waiting. . . "
Start-Sleep 1
Write-Host "Waiting. . . "
Start-Sleep 1

Write-Host "Script execution completed."
