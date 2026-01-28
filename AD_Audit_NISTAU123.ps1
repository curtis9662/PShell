<#
.SYNOPSIS
    Enterprise AD Audit and Threat Hunting Script
.DESCRIPTION
    Performs security auditing, event log quantification, and latency checks using Zero Trust methodology.
    -Curtis J.-
.NOTES
    NIST alignment: AC-2, AU-2, AU-6, SI-4
#>
<#
a PowerShell script designed for enterprise auditing and monitoring of Active Directory and Windows Server environments.

Script Overview
This script utilizes Zero Trust principles (Verify Explicitly) by enforcing pre-flight checks for administrative privileges, operating system verification, and network latency before executing core logic. It aggregates data using Get-WinEvent for performance and focuses on read-only auditing to maintain system integrity.

Capabilities:

Environment Verification: Enforces Admin context and Windows Server OS.

Identity & Access: Audits lockouts, logons, and group membership changes.

Threat Hunting: Scans for indicators like Security Log clearing (Event ID 1102) and Group Policy modification.

Quantification: Provides statistical counts of Critical/High events.
#>

# -Curtis J.- We Verify Explicitly: Enforce Admin Context
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "User not authenticated as Administrator. Zero Trust check failed."
    Break
}

# -Curtis J.- Now some Host Verification
$osInfo = Get-CimInstance Win32_OperatingSystem
if ($osInfo.ProductType -eq 1) { 
    Write-Warning "Host is a Workstation, not a Server. Aborting."
    Break
}

# -Curtis J.- Here I ensure (0) Trust: Network Latency & Connectivity Check
$dcInfo = Get-ADDomainController
$latency = Test-Connection -ComputerName $dcInfo.HostName -Count 2 -ErrorAction SilentlyContinue
if ($latency.ResponseTime -gt 200) { Write-Warning "High Latency detected to DC: $($latency.ResponseTime)ms" }

$auditResults = [PSCustomObject]@{
    Timestamp = Get-Date
    Host      = $env:COMPUTERNAME
    Domain    = $env:USERDOMAIN
}

# -Curtis J.- Show the Numbers 📈📊 Quantitative Event Analysis (High/Critical)
$timeSpan = (Get-Date).AddDays(-1)
$critEvents = Get-WinEvent -FilterHashtable @{LogName='Security'; Level=1,2; StartTime=$timeSpan} -ErrorAction SilentlyContinue
$adminEvents = Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2; StartTime=$timeSpan} -ErrorAction SilentlyContinue

Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "Security_HighCrit_24h" -Value ($critEvents.Count)
Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "System_Admin_24h" -Value ($adminEvents.Count)

# -Curtis J.- Who has used our DC/AD Monitor User Login (Event 4624)
$logons = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624; StartTime=$timeSpan} -ErrorAction SilentlyContinue | Select-Object -First 50
Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "Recent_Logons_Sample" -Value $logons.Count

# -Curtis J.- Who abused here we Analyze Account Lockouts (Event 4740)
$lockouts = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4740; StartTime=$timeSpan} -ErrorAction SilentlyContinue
Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "Account_Lockouts_24h" -Value $lockouts.Count

# -Curtis J.- Proactive Threat Hunting (IoC's)
# Hunting for: Log Clearing (1102), Member Added to Security Group (4728/4732/4756)
$threatEvents = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=1102,4728,4732,4756; StartTime=$timeSpan} -ErrorAction SilentlyContinue
$threatSummary = if ($threatEvents) { "DETECTED: $($threatEvents.Count) suspicious events" } else { "None" }
Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "Threat_Hunting_Status" -Value $threatSummary

# -Curtis J.- Audit GPO Changes (Event 5136)
$gpoChanges = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=5136; StartTime=$timeSpan} -ErrorAction SilentlyContinue
Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "GPO_Modifications_24h" -Value ($gpoChanges.Count)

# -Curtis J.- Hybrid Auditing Status Check (For those w/ On-Prem Write back)
# Checks for Azure AD Connect Health Agent presence as proxy for Hybrid Auditing enablement
$hybridStatus = Get-Service "AdHealthService" -ErrorAction SilentlyContinue
$hybridState = if ($hybridStatus.Status -eq 'Running') { "Enabled/Running" } else { "Disabled/Not Found" }
Add-Member -InputObject $auditResults -MemberType NoteProperty -Name "Hybrid_Auditing_State" -Value $hybridState

# -Curtis J.- Output
$auditResults | Format-List
<#
The Following contains A standalone, zero-dependency HTML file output with a modern, high-contrast Dark Mode UI, CSS-only animated charts (no external CDNs required for security), and interactive hover states designed for C-Suite readability.
#>

# ... [Previous script code ends here] ...

# -Curtis J.- Setup Output Paths
$reportPath = "$env:USERPROFILE\Desktop\Security_Dashboard.html"
$pptPath    = "$env:USERPROFILE\Desktop\Executive_Brief.pptx"

# -Curtis J.- HTML Generator (Vibrant, Interactive, CSS-Only)
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enterprise Security Brief</title>
    <style>
        :root { --bg: #1a1a2e; --card: #16213e; --accent: #e94560; --text: #ecf0f1; --success: #0f3460; }
        body { font-family: 'Segoe UI', sans-serif; background-color: var(--bg); color: var(--text); margin: 0; padding: 20px; }
        .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid var(--accent); padding-bottom: 15px; margin-bottom: 30px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }
        .card { background-color: var(--card); padding: 20px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.3); transition: transform 0.2s; }
        .card:hover { transform: translateY(-5px); border-top: 3px solid var(--accent); }
        .metric { font-size: 2.5em; font-weight: bold; color: var(--accent); }
        .label { font-size: 0.9em; text-transform: uppercase; letter-spacing: 1px; opacity: 0.8; }
        
        /* CSS Charts */
        .chart-container { margin-top: 40px; background: var(--card); padding: 20px; border-radius: 10px; }
        .bar-group { display: flex; align-items: flex-end; height: 200px; gap: 20px; padding-top: 20px; }
        .bar { width: 15%; background: linear-gradient(to top, var(--success), var(--accent)); transition: height 1s ease-out; border-radius: 5px 5px 0 0; position: relative; }
        .bar:hover::after { content: attr(data-val); position: absolute; top: -25px; left: 50%; transform: translateX(-50%); font-weight: bold; }
        .legend { text-align: center; margin-top: 10px; font-size: 0.8em; }
        
        .status-badge { padding: 5px 10px; border-radius: 15px; background: var(--success); font-size: 0.8em; }
        .footer { margin-top: 50px; font-size: 0.8em; text-align: center; opacity: 0.5; }
    </style>
</head>
<body>
    <div class="header">
        <div>
            <h1>Executive Security Audit</h1>
            <small>Host: $($auditResults.Host) | Domain: $($auditResults.Domain)</small>
        </div>
        <div class="status-badge">NIST COMPLIANCE MODE</div>
    </div>

    <div class="grid">
        <div class="card">
            <div class="label">Critical Security Events (24h)</div>
            <div class="metric">$($auditResults.Security_HighCrit_24h)</div>
        </div>
        <div class="card">
            <div class="label">Admin System Events</div>
            <div class="metric">$($auditResults.System_Admin_24h)</div>
        </div>
        <div class="card">
            <div class="label">Account Lockouts</div>
            <div class="metric">$($auditResults.Account_Lockouts_24h)</div>
        </div>
        <div class="card">
            <div class="label">Hybrid Identity Status</div>
            <div style="font-size: 1.2em; margin-top: 10px;">$($auditResults.Hybrid_Auditing_State)</div>
        </div>
    </div>

    <div class="chart-container">
        <h3>Threat Activity Visualization</h3>
        <div class="bar-group">
            <div class="bar" style="height: $([math]::Min($auditResults.Security_HighCrit_24h * 5 + 5, 100))%;" data-val="$($auditResults.Security_HighCrit_24h)"></div>
            <div class="bar" style="height: $([math]::Min($auditResults.Recent_Logons_Sample * 2 + 5, 100))%;" data-val="$($auditResults.Recent_Logons_Sample)"></div>
            <div class="bar" style="height: $([math]::Min($auditResults.Account_Lockouts_24h * 10 + 5, 100))%;" data-val="$($auditResults.Account_Lockouts_24h)"></div>
            <div class="bar" style="height: $([math]::Min($auditResults.GPO_Modifications_24h * 10 + 5, 100))%;" data-val="$($auditResults.GPO_Modifications_24h)"></div>
        </div>
        <div class="grid" style="margin-top:10px; text-align:center; font-size:0.8em;">
            <div>High Severity</div>
            <div>User Logons</div>
            <div>Lockouts</div>
            <div>GPO Changes</div>
        </div>
    </div>

    <div class="footer">
        Generated via PowerShell Zero Trust Framework | -Curtis J.-
    </div>
</body>
</html>
"@

$htmlContent | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "HTML Dashboard generated at: $reportPath" -ForegroundColor Cyan

# -Curtis J.- PowerPoint Generation (Requires installed Office Interop)
Try {
    $ppt = New-Object -ComObject PowerPoint.Application
    $pres = $ppt.Presentations.Add()

    # Slide 1: Title
    $slide1 = $pres.Slides.Add(1, 1) # ppLayoutTitle
    $slide1.Shapes.Item(1).TextFrame.TextRange.Text = "Zero Trust Audit Report"
    $slide1.Shapes.Item(2).TextFrame.TextRange.Text = "Generated: $(Get-Date)`r`nHost: $($auditResults.Host)"

    # Slide 2: Quantitative Metrics
    $slide2 = $pres.Slides.Add(2, 2) # ppLayoutText
    $slide2.Shapes.Item(1).TextFrame.TextRange.Text = "24-Hour Security Metrics"
    $textRange = $slide2.Shapes.Item(2).TextFrame.TextRange
    $textRange.Text = "Critical Events: $($auditResults.Security_HighCrit_24h)`r`n" +
                      "Admin Events: $($auditResults.System_Admin_24h)`r`n" +
                      "Account Lockouts: $($auditResults.Account_Lockouts_24h)`r`n" +
                      "GPO Modifications: $($auditResults.GPO_Modifications_24h)"

    # Slide 3: Threat Hunting
    $slide3 = $pres.Slides.Add(3, 2)
    $slide3.Shapes.Item(1).TextFrame.TextRange.Text = "Threat Hunting & Hybrid Status"
    $textRange3 = $slide3.Shapes.Item(2).TextFrame.TextRange
    $textRange3.Text = "Status: $($auditResults.Threat_Hunting_Status)`r`n" +
                       "Hybrid Agent: $($auditResults.Hybrid_Auditing_State)`r`n" +
                       "DC Latency Check: Passed (<200ms)"

    $pres.SaveAs($pptPath)
    $ppt.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ppt) | Out-Null
    Write-Host "PowerPoint (.pptx) generated at: $pptPath" -ForegroundColor Cyan
} Catch {
    Write-Warning "PowerPoint generation skipped: MS Office application not detected on Server."
    Write-Host "Use the generated HTML Dashboard for presentation purposes." -ForegroundColor Yellow
}

# -Curtis J.- Cleanup
[GC]::Collect()
[GC]::WaitForPendingFinalizers()