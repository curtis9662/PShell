# Define the Event IDs for local group member addition and removal
$eventIds = @(4732, 4733)

# Fetch the events from the Security log
$events = Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id      = $eventIds
} -ErrorAction SilentlyContinue

if ($null -eq $events) {
    Write-Host "No local group membership changes found." -ForegroundColor Yellow
    return
}

# Process and display the results
$results = $events | ForEach-Object {
    $xml = [xml]$_.ToXml()
    
    # Extract specific data from the Event XML
    $groupName = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetUserName' }).'#text'
    
    # Filter only for the 'Administrators' group
    if ($groupName -eq "Administrators") {
        [PSCustomObject]@{
            TimeCreated  = $_.TimeCreated
            EventID      = $_.Id
            Action       = if ($_.Id -eq 4732) { "Member Added" } else { "Member Removed" }
            TargetUser   = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq 'MemberName' }).'#text'
            ChangedBy    = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq 'SubjectUserName' }).'#text'
            Description  = $_.Message.Split("`r`n")[0] # Short description
        }
    }
}

$results | Out-GridView -Title "Local Admin Changes"