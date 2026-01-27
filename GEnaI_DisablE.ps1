<#
.SYNOPSIS
    <🚀>- Developed by Curtis Jones (Blactec.biz).

.DESCRIPTION
    [Script Description]: Deactivate and delete Gen A.i. Features from your Browsers.
	
    Part of the Blactec Security Architecture portfolio. Designed for secure 
    Zero Trust adherence.

.PARAMETER <ParameterName>
    [Description]

.EXAMPLE
    .\Script-Name.ps1 -Parameter Value or Full Block insert

.NOTES
    Author:       Curtis Jones (Msc, CISSP, OSCP)
    Role:         Sr. Security Architect & IAM Strategist
    Lab Env:      Blactec Cyber Threat Monitoring
    Website:      https://curtis9662.github.io/
    GitHub:       github.com/curtis9662
    Copyright:    (c) 2025-2026 Curtis Jones. All rights reserved.
    Dev Level:    PROD
    
.LINK
    https://curtis9662.github.io/
#>
<#
1. Microsoft Edge (Enterprise/Business)
Target: Disable Copilot, Sidebar, and data transmission to Microsoft services.

Engineering Steps:

Disable Sidebar & Copilot: Modifying Group Policy limits the user interface access to GenAI tools.

Disable Search/Browsing Data Sending: Prevents URL and browsing history transmission to Microsoft for "personalization."

Disable Compose: Removes the AI text generation tool from context menus.

PowerShell Enforcement (Run as Admin):

PowerShell
#>

$EdgePath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
if (!(Test-Path $EdgePath)) { New-Item -Path $EdgePath -Force }

# Disable Copilot completely
Set-ItemProperty -Path $EdgePath -Name "EdgeCopilotEnabled" -Value 0
# Disable the Sidebar (Container for Copilot)
Set-ItemProperty -Path $EdgePath -Name "HubsSidebarEnabled" -Value 0
# Prevent User Feedback/Logging
Set-ItemProperty -Path $EdgePath -Name "UserFeedbackAllowed" -Value 0
# Disable sending data for personalization
Set-ItemProperty -Path $EdgePath -Name "PersonalizationReportingEnabled" -Value 0

<#
2. Google Chrome (Enterprise)
Target: Disable "Experimental AI" features (Help Me Write, Tab Organizer, Theme Generator) and logging.

Engineering Steps:

Enforce GenAI Default Settings: Set the global "GenAiDefaultSettings" policy to "Disabled" (Value 2).

Disable Metrics Reporting: Stops standard usage logging.

Disable Component Updates: Prevents the download of AI models (Optimization Guide).

PowerShell Enforcement (Run as Admin):

PowerShell
#>

$ChromePath = "HKLM:\SOFTWARE\Policies\Google\Chrome"
if (!(Test-Path $ChromePath)) { New-Item -Path $ChromePath -Force }

# 0=Default, 1=Enabled, 2=Disabled
# Disables "Help Me Write", "Tab Organizer", "Create Themes"
Set-ItemProperty -Path $ChromePath -Name "GenAiDefaultSettings" -Value 2
# Disable standard usage logging
Set-ItemProperty -Path $ChromePath -Name "MetricsReportingEnabled" -Value 0
# Block model downloads
Set-ItemProperty -Path $ChromePath -Name "OptimizationGuideModelDownloadingEnabled" -Value 0


<#
3. Brave Browser
Target: Disable "Leo" (AI Assistant) and anonymous privacy-preserving product analytics.

Engineering Steps:

Disable Leo AI: Turn off the BraveAIChatEnabled policy.

Disable Product Analytics: Ensure P3A (Privacy-Preserving Product Analytics) is off.

PowerShell Enforcement (Run as Admin):

PowerShell
#>

$BravePath = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
if (!(Test-Path $BravePath)) { New-Item -Path $BravePath -Force }

# Disable Leo AI Chat assistant
Set-ItemProperty -Path $BravePath -Name "BraveAIChatEnabled" -Value 0
# Disable Suggestion Services (often sends partial queries)
Set-ItemProperty -Path $BravePath -Name "SearchSuggestEnabled" -Value 0
# Disable Anonymous Usage Logging
Set-ItemProperty -Path $BravePath -Name "BraveVP3AEnabled" -Value 0

<#
4. Mozilla Firefox
Target: Disable Telemetry, Studies (often used to test AI features), and Sponsored Suggestions.

Engineering Steps:

Disable Telemetry & Studies: Prevents Mozilla from collecting interaction data used to train or test new features.

Disable Firefox Suggest: Stops the browser from sending keystrokes to Mozilla/Partners for contextual suggestions.

Disable PDF.js Cloud Conversion: Prevents cloud-based AI processing of PDFs (if applicable).

PowerShell Enforcement (Run as Admin):

PowerShell
<#

$FirefoxPath = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox"
if (!(Test-Path $FirefoxPath)) { New-Item -Path $FirefoxPath -Force }

# Disable Telemetry (Data Collection)
Set-ItemProperty -Path $FirefoxPath -Name "DisableTelemetry" -Value 1
# Disable Studies (Experimental features pushed to users)
Set-ItemProperty -Path $FirefoxPath -Name "DisableFirefoxStudies" -Value 1
# Disable "Firefox Suggest" (Sponsored/Cloud suggestions)
Set-ItemProperty -Path $FirefoxPath -Name "FirefoxSuggest" -Value 0
# Disable detailed logging
Set-ItemProperty -Path $FirefoxPath -Name "DisableFirefoxAccounts" -Value 1

#>


<#
Verification Step
After running these scripts, users must restart their browsers. To verify enforcement, navigate to:

Edge: edge://policy

Chrome: chrome://policy

Brave: brave://policy

Firefox: about:policies
#>
