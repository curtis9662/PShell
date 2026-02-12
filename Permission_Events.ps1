# Define the timeframe (30 days ago)
$StartTime = (Get-Date).AddDays(-30)

# Filter for Local Security Group Member Addition (4732) and Removal (4733)
$EventIds = @(4732, 4733)

Write-Host "Searching Security Logs for local group changes since $($StartTime)..." -ForegroundColor Cyan

try {
    # Fetch events using Get-WinEvent (faster than Get-EventLog)
    $Events = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = $EventIds
        StartTime = $StartTime
    } -ErrorAction Stop

    $Results = foreach ($Event in $Events) {
        # Parse the XML data for cleaner output
        $eventXml = [xml]$Event.ToXml()
        
        # Extract Data fields (Subject, Member, and Group)
        $subjectUser = ($eventXml.Event.EventData.Data | Where-Object { $_.Name -eq "SubjectUserName" })."#text"
        $targetGroup = ($eventXml.Event.EventData.Data | Where-Object { $_.Name -eq "TargetUserName" })."#text"
        $memberSid   = ($eventXml.Event.EventData.Data | Where-Object { $_.Name -eq "MemberSid" })."#text"
        
        # Determine the action
        $action = if ($Event.Id -eq 4732) { "Added" } else { "Removed" }

        [PSCustomObject]@{
            TimeCreated  = $Event.TimeCreated
            Action       = $action
            TargetGroup  = $targetGroup
            MemberSID    = $memberSid
            PerformedBy  = $subjectUser
            EventID      = $Event.Id
        }
    }

    # Display results grouped by the Target Group (e.g., Administrators)
    $Results | Group-Object TargetGroup | ForEach-Object {
        Write-Host "`n--- Group: $($_.Name) ---" -ForegroundColor Yellow
        $_.Group | Sort-Object TimeCreated -Descending | Format-Table TimeCreated, Action, MemberSID, PerformedBy -AutoSize
    }

} catch {
    Write-Warning "No events found or access denied. Ensure you are running as Administrator."
}
