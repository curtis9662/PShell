# Ensure script is run as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  Write-Warning "Please run this script as an Administrator!"
  Break
}

# 1. Update PowerShell to latest version and packages
Write-Host "Updating PowerShell..."
Install-Module -Name PowerShellGet -Force -AllowClobber
Update-Module -Name PowerShellGet
Install-Module -Name PSWindowsUpdate -Force
Get-WindowsUpdate -Install -AcceptAll -AutoReboot

# 2. Disable Windows Automatic Updates
Write-Host "Disabling Windows Automatic Updates..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1

# 3. Block inbound on all ports except 80, 3389, and 443
Write-Host "Configuring Windows Firewall..."
New-NetFirewallRule -DisplayName "Allow Inbound Port 80" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Inbound Port 3389" -Direction Inbound -LocalPort 3389 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Inbound Port 443" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow
Set-NetFirewallProfile -DefaultInboundAction Block -DefaultOutboundAction Allow -NotifyOnListen True -AllowUnicastResponseToMulticast True

# 4. Update Local Security Policy to align with NIST 800-53, 800-171 baselines
Write-Host "Updating Local Security Policy..."
# Note: This is a simplified example and does not cover all NIST 800-53 and 800-171 requirements
secedit /export /cfg c:\secpol.cfg
(Get-Content C:\secpol.cfg) -Replace "PasswordComplexity = 0","PasswordComplexity = 1" | Set-Content C:\secpol.cfg
(Get-Content C:\secpol.cfg) -Replace "MinimumPasswordLength = 0","MinimumPasswordLength = 14" | Set-Content C:\secpol.cfg
secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
Remove-Item -force c:\secpol.cfg -confirm:$false

Write-Host "Script execution completed. Please review changes and reboot the system."

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
