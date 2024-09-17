# Requires elevation (Run as Administrator)
# Requires -Modules NetEventPacketCapture

# Define the URL or IP to filter (change as needed)
$filterTarget = "example.com"

# Start packet capture
New-NetEventSession -Name "DNSCapture" -CaptureMode SaveToFile -LocalFilePath "$env:TEMP\dnscapture.etl"
Add-NetEventPacketCaptureProvider -SessionName "DNSCapture" -EtherType 0x0800 -IpProtocols Udp -IpAddresses 0.0.0.0 -CaptureType BothPackets
Add-NetEventProvider -Name "Microsoft-Windows-TCPIP" -SessionName "DNSCapture"
Start-NetEventSession -Name "DNSCapture"

Write-Host "Capturing DNS traffic. Press Ctrl+C to stop..."

try {
    # Capture for 60 seconds (adjust as needed)
    Start-Sleep -Seconds 60
}
finally {
    # Stop capture
    Stop-NetEventSession -Name "DNSCapture"
}

# Convert ETL to text
etl2pcapng "$env:TEMP\dnscapture.etl" "$env:TEMP\dnscapture.pcapng"

# Analyze with tshark (part of Wireshark)
$dnsQueries = & tshark -r "$env:TEMP\dnscapture.pcapng" -Y "dns.qry.name contains $filterTarget" -T fields -e dns.qry.name -e ip.src

# Display results
$dnsQueries | ForEach-Object {
    $parts = $_ -split "`t"
    Write-Host "Query: $($parts[0]) from IP: $($parts[1])"
}

# Clean up
Remove-Item "$env:TEMP\dnscapture.etl"
Remove-Item "$env:TEMP\dnscapture.pcapng"
Remove-NetEventSession -Name "DNSCapture"



##############################################################################
GET ALLL DNS TRAFFIC
##############################################################################

# Requires elevation (Run as Administrator)
# Requires -Modules NetEventPacketCapture

# Start packet capture
New-NetEventSession -Name "DNSCapture" -CaptureMode SaveToFile -LocalFilePath "$env:TEMP\dnscapture.etl"
Add-NetEventPacketCaptureProvider -SessionName "DNSCapture" -EtherType 0x0800 -IpProtocols Udp -IpAddresses 0.0.0.0 -CaptureType BothPackets
Add-NetEventProvider -Name "Microsoft-Windows-TCPIP" -SessionName "DNSCapture"
Start-NetEventSession -Name "DNSCapture"

Write-Host "Capturing DNS traffic. Press Ctrl+C to stop..."

try {
    # Capture for 60 seconds (adjust as needed)
    Start-Sleep -Seconds 60
}
finally {
    # Stop capture
    Stop-NetEventSession -Name "DNSCapture"
}

# Convert ETL to text
etl2pcapng "$env:TEMP\dnscapture.etl" "$env:TEMP\dnscapture.pcapng"

# Analyze with tshark (part of Wireshark)
$dnsQueries = & tshark -r "$env:TEMP\dnscapture.pcapng" -Y "dns" -T fields -e frame.time -e ip.src -e dns.qry.name -e dns.resp.name

# Display results
$dnsQueries | ForEach-Object {
    $parts = $_ -split "`t"
    $timestamp = $parts[0]
    $sourceIP = $parts[1]
    $queryName = $parts[2]
    $responseName = $parts[3]

    if ($queryName) {
        Write-Host "Time: $timestamp | Source IP: $sourceIP | Query: $queryName"
    }
    if ($responseName) {
        Write-Host "Time: $timestamp | Source IP: $sourceIP | Response: $responseName"
    }
}

# Clean up
Remove-Item "$env:TEMP\dnscapture.etl"
Remove-Item "$env:TEMP\dnscapture.pcapng"
Remove-NetEventSession -Name "DNSCapture"

##############################################################################

##############################################################################
> ####
Start-Sleep  -Seconds 0
ipconfig /release
ipconfig /flushdns
ipconfig /renew
netsh winsock reset
netsh interface ipv4 reset
netsh interface ipv6 reset
netsh winsock reset catalog
netsh int ipv4 reset reset.log
netsh int ipv6 reset reset.log
netsh advfirewall reset
Clear-DnsClientCache
Get-DNSClientCache | Select-Object Entry, RecordName, Status, TimeToLive | Format-Table -AutoSize
Start-Sleep 20
shutdown -a
shutdown -r -f -t 100
exit
### Recheck DNS Entries ### with → Get-DNSClientCache | Select-Object Entry, RecordName, Status, TimeToLive | Format-Table -AutoSize###