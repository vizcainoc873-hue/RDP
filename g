name: RDP
on:
workflow_dispatch:
jobs:
secure-rdp:
runs-on: windows-latest
timeout-minutes: 3600
steps:
- name: Configure Core RDP Settings
run: |
# Enable Remote Desktop and disable Network Level Authentication (if needed)
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' `
-Name "fDenyTSConnections" -Value 0 -Force
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
-Name "UserAuthentication" -Value 0 -Force
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
-Name "SecurityLayer" -Value 0 -Force
# Remove any existing rule with the same name to avoid duplication
netsh advfirewall firewall delete rule name="RDP-Tailscale"
# For testing, allow any incoming connection on port 3389
netsh advfirewall firewall add rule name="RDP-Tailscale" `
dir=in action=allow protocol=TCP localport=3389
# (Optional) Restart the Remote Desktop service to ensure changes take effect
Restart-Service -Name TermService -Force
- name: Create RDP User with Secure Password
run: |
Add-Type -AssemblyName System.Security
$charSet = @{
Upper = [char[]](65..90) # A-Z
Lower = [char[]](97..122) # a-z
Number = [char[]](48..57) # 0-9
Special = ([char[]](33..47) + [char[]](58..64) +
[char[]](91..96) + [char[]](123..126)) # Special characters
}
$rawPassword = @()
$rawPassword += $charSet.Upper | Get-Random -Count 4
$rawPassword += $charSet.Lower | Get-Random -Count 4
$rawPassword += $charSet.Number | Get-Random -Count 4
$rawPassword += $charSet.Special | Get-Random -Count 4
$password = -join ($rawPassword | Sort-Object { Get-Random })
$securePass = ConvertTo-SecureString $password -AsPlainText -Force
New-
