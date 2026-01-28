<#
.SYNOPSIS
    Enterprise Zero Trust AD Audit & Threat Hunting (NIST AU-Compliant)
.DESCRIPTION
    Validates Host, Latency, and Identity. Aggregates Security/System logs.
    Generates C-Suite HTML Dashboard and PowerPoint Brief.
    -Curtis J.-
.NOTES
    NIST Mapping: AU-2, AU-3, AU-4, AU-5, AU-6
#>

# -Curtis J.- /Admin: Begin Development/
# -Curtis J.- Verify Explicitly: Enforce Admin Context (Zero Trust)
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Access Denied: Administrator privileges required for Audit."
    Break
}

# -Curtis J.- Host Verification (Server OS Check)
$osInfo = Get-CimInstance Win32_OperatingSystem
if ($osInfo.ProductType -eq 1) { 
    Write-Warning "Environment Mismatch: Script restricted to Windows Server Hosts."
    Break
}

# -Curtis J.- Zero Trust: Network Latency & Connectivity Check
$dcInfo = Get-ADDomainController
$latency = Test-Connection -ComputerName $dcInfo.HostName -Count 2 -ErrorAction SilentlyContinue
if ($latency.ResponseTime -gt 200) { Write-Warning "Network Instability: High Latency to DC ($($latency.ResponseTime)ms)" }

# -Curtis J.- Initialize Data Collection
$auditResults = [PSCustomObject]@{
    Timestamp = Get-Date
    Host      = $env:COMPUTERNAME
    Domain    = $env:USERDOMAIN
    Status    = "NIST_Scanning"
}

# -Curtis J.- NIST AU-5: Response to Audit Logging Process Failures (Service Check)
$logService = Get-Service EventLog
$au5Status = if ($logService.Status -eq 'Running') { "Active" } else { "CRITICAL FAILURE" }
Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "Audit_Service_Status" -Value $au5Status

# -Curtis J.- NIST AU-4: Audit Log Storage Capacity Check
$logFile = Get-CimInstance Win32_NTEventLogFile | Where-Object { $_.LogfileName -eq 'Security' }
$storageUsage = [math]::Round(($logFile.FileSize / $logFile.MaxFileSize) * 100, 2)
Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "Log_Storage_Used_Pct" -Value $storageUsage

# -Curtis J.- Quantitative Event Analysis (AU-2 / AU-6)
$timeSpan = (Get-Date).AddDays(-1)
# High/Critical Security Events
$critEvents = Get-WinEvent -FilterHashtable @{LogName='Security'; Level=1,2; StartTime=$timeSpan} -ErrorAction SilentlyContinue
# Admin/System Errors
$adminEvents = Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2; StartTime=$timeSpan} -ErrorAction SilentlyContinue

Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "Security_HighCrit_24h" -Value ($critEvents.Count)
Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "System_Admin_24h" -Value ($adminEvents.Count)

# -Curtis J.- Monitor User Login (Event 4624) - AU-3
$logons = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624; StartTime=$timeSpan} -ErrorAction SilentlyContinue
Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "Logon_Volume_24h" -Value ($logons.Count)

# -Curtis J.- Analyze Account Lockouts (Event 4740)
$lockouts = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4740; StartTime=$timeSpan} -ErrorAction SilentlyContinue
Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "Account_Lockouts_24h" -Value ($lockouts.Count)

# -Curtis J.- Proactive Threat Hunting (Indicators: 1102 Log Clear, 4728/4732/4756 Group Mod)
$threatEvents = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=1102,4728,4732,4756; StartTime=$timeSpan} -ErrorAction SilentlyContinue
$threatSummary = if ($threatEvents) { "ALERT: $($threatEvents.Count) suspicious events detected" } else { "Clean" }
Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "Threat_Hunting_Status" -Value $threatSummary

# -Curtis J.- Audit GPO Changes (Event 5136)
$gpoChanges = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=5136; StartTime=$timeSpan} -ErrorAction SilentlyContinue
Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "GPO_Modifications_24h" -Value ($gpoChanges.Count)

# -Curtis J.- Hybrid Auditing Status (Azure AD Connect Health Check)
$hybridSvc = Get-Service "AdHealthService" -ErrorAction SilentlyContinue
$hybridState = if ($hybridSvc.Status -eq 'Running') { "Hybrid Enabled" } else { "On-Prem Only" }
Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "Hybrid_Auditing_State" -Value $hybridState

# -Curtis J.- Setup Output Paths
$reportPath = "$env:USERPROFILE\Desktop\Security_Dashboard.html"
$pptPath    = "$env:USERPROFILE\Desktop\Executive_Brief.pptx"

# -Curtis J.- HTML Generator (C-Suite UI/UX, Dark Mode, CSS Charts)
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Enterprise Security Audit</title>
    <style>
        :root { --bg: #0f172a; --card: #1e293b; --accent: #38bdf8; --crit: #f43f5e; --text: #f1f5f9; }
        body { font-family: 'Segoe UI', sans-serif; background: var(--bg); color: var(--text); padding: 40px; }
        h1 { border-bottom: 2px solid var(--accent); padding-bottom: 10px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 20px; }
        .card { background: var(--card); padding: 20px; border-radius: 8px; border-left: 4px solid var(--accent); }
        .card.alert { border-left-color: var(--crit); }
        .metric { font-size: 2.5em; font-weight: 700; margin: 10px 0; }
        .label { font-size: 0.85em; text-transform: uppercase; opacity: 0.7; }
        .chart-box { background: var(--card); padding: 30px; border-radius: 8px; margin-top: 30px; }
        .bar-container { display: flex; height: 200px; align-items: flex-end; gap: 40px; padding-top: 20px; }
        .bar { width: 60px; background: var(--accent); transition: height 0.5s; position: relative; border-radius: 4px 4px 0 0; }
        .bar span { position: absolute; top: -25px; left: 50%; transform: translateX(-50%); font-weight: bold; }
        footer { margin-top: 50px; font-size: 0.8em; opacity: 0.5; text-align: center; }
    </style>
</head>
<body>
    <h1>Executive Security Audit: AU-Compliance</h1>
    <p>Host: $($auditResults.Host) | Domain: $($auditResults.Domain) | NIST Status: Checked</p>
    
    <div class="grid">
        <div class="card $(if($auditResults.Security_HighCrit_24h -gt 0){'alert'})">
            <div class="label">Critical Events (24h)</div>
            <div class="metric">$($auditResults.Security_HighCrit_24h)</div>
        </div>
        <div class="card">
            <div class="label">Logon Volume</div>
            <div class="metric">$($auditResults.Logon_Volume_24h)</div>
        </div>
        <div class="card $(if($auditResults.Account_Lockouts_24h -gt 0){'alert'})">
            <div class="label">Account Lockouts</div>
            <div class="metric">$($auditResults.Account_Lockouts_24h)</div>
        </div>
        <div class="card">
            <div class="label">Log Storage Used</div>
            <div class="metric">$($auditResults.Log_Storage_Used_Pct)%</div>
        </div>
        <div class="card">
            <div class="label">Hybrid Status</div>
            <div class="metric" style="font-size:1.2em; margin-top:20px;">$($auditResults.Hybrid_Auditing_State)</div>
        </div>
    </div>

    <div class="chart-box">
        <h3>Threat & Activity Visualization</h3>
        <div class="bar-container">
            <div class="bar" style="height: $([math]::Min($auditResults.Security_HighCrit_24h * 10 + 2, 100))%;"><span>$($auditResults.Security_HighCrit_24h)</span></div>
            <div class="bar" style="height: $([math]::Min($auditResults.Account_Lockouts_24h * 10 + 2, 100))%; background: var(--crit);"><span>$($auditResults.Account_Lockouts_24h)</span></div>
            <div class="bar" style="height: $([math]::Min($auditResults.GPO_Modifications_24h * 10 + 2, 100))%;"><span>$($auditResults.GPO_Modifications_24h)</span></div>
            <div class="bar" style="height: $([math]::Min($auditResults.System_Admin_24h * 5 + 2, 100))%;"><span>$($auditResults.System_Admin_24h)</span></div>
        </div>
        <div style="display:flex; gap:40px; margin-top:10px; font-size:0.8em;">
            <div style="width:60px; text-align:center">Critical</div>
            <div style="width:60px; text-align:center">Lockouts</div>
            <div style="width:60px; text-align:center">GPO Mods</div>
            <div style="width:60px; text-align:center">Sys Admin</div>
        </div>
    </div>
    <footer>Generated via PowerShell NIST Framework | -Curtis J.-</footer>
</body>
</html>
"@
$htmlContent | Out-File -FilePath $reportPath -Encoding UTF8

# -Curtis J.- PowerPoint Generation (COM Object)
Try {
    $ppt = New-Object -ComObject PowerPoint.Application
    $pres = $ppt.Presentations.Add()
    
    # Slide 1: Title
    $s1 = $pres.Slides.Add(1, 1)
    $s1.Shapes.Item(1).TextFrame.TextRange.Text = "NIST AU Audit Report"
    $s1.Shapes.Item(2).TextFrame.TextRange.Text = "Date: $(Get-Date)`r`nServer: $($auditResults.Host)"

    # Slide 2: Metrics
    $s2 = $pres.Slides.Add(2, 2)
    $s2.Shapes.Item(1).TextFrame.TextRange.Text = "Key Security Metrics (24h)"
    $s2.Shapes.Item(2).TextFrame.TextRange.Text = "Security Critical Events: $($auditResults.Security_HighCrit_24h)`r`n" +
        "Account Lockouts: $($auditResults.Account_Lockouts_24h)`r`n" +
        "GPO Changes: $($auditResults.GPO_Modifications_24h)`r`n" +
        "Log Storage Capacity: $($auditResults.Log_Storage_Used_Pct)%"

    # Slide 3: Threat Hunting
    $s3 = $pres.Slides.Add(3, 2)
    $s3.Shapes.Item(1).TextFrame.TextRange.Text = "Threat Hunting & AU Status"
    $s3.Shapes.Item(2).TextFrame.TextRange.Text = "Threat Hunt Status: $($auditResults.Threat_Hunting_Status)`r`n" +
        "Audit Service (AU-5): $($auditResults.Audit_Service_Status)`r`n" +
        "Hybrid Auditing: $($auditResults.Hybrid_Auditing_State)"

    $pres.SaveAs($pptPath)
    $ppt.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ppt) | Out-Null
    Write-Host "Success: Reports generated at $reportPath and $pptPath" -ForegroundColor Green
} Catch {
    Write-Warning "PowerPoint Generation Failed (Office not installed?). HTML Report is available."
}
# -Curtis J.- Final Cleanup
[GC]::Collect()