# 🛡️ Top 10 Azure Cloud Shell Commands for Security Architects by **CURTIS JONES**

Welcome to the Azure Security Enablement session! As Security Architects, the Azure Cloud Shell (via Azure CLI) is our fastest tool for rapid environment auditing, compliance verification, and proactive threat hunting. 

Below is a curated reference guide of the top 10 commands you need in your arsenal, broken down by core security domain.

---

## 🔐 Identity & Access Management (IAM)

### 1. Audit Role-Based Access Control (RBAC) Assignments
Reviewing IAM assignments across the subscription ensures no users or service principals have overly permissive access (such as widespread `Owner` or `Contributor` rights).

```bash
az role assignment list --all --output table
```
> **Use Case:** Essential for auditing and enforcing the **Principle of Least Privilege**.

### 2. Inspect Entra ID (Azure AD) Service Principals
Service Principals represent non-human, programmatic identities.

```bash
az ad sp list --show-mine --output table
```
> **Use Case:** Helps you audit and track third-party applications, automation scripts, and managed identities that maintain access to your tenant.

---

## 🌐 Infrastructure & Network Security

### 3. Analyze Network Security Group (NSG) Rules
NSGs act as your virtual firewalls. This command allows you to quickly inspect inbound and outbound rules.

```bash
az network nsg rule list --nsg-name <nsg-name> --resource-group <rg-name> --output table
```
> **Use Case:** Perfect for hunting down risky open ports (like port `22` for SSH or `3389` for RDP) that are unnecessarily exposed to the public internet.

### 4. Find Orphaned Public IPs
Unattached Public IP addresses unnecessarily expand your external attack surface and can sometimes be hijacked or misconfigured.

```bash
az network public-ip list --query "[?ipConfiguration==null].[name, ipAddress]"
```
> **Use Case:** Instantly isolates orphaned IPs so your team can review and delete them, saving costs and reducing risk.

---

## 💾 Data Protection & Secrets Management

### 5. Audit Storage Account Public Access
Unsecured Azure Blob Storage is a leading cause of enterprise data breaches. 

```bash
az storage account list --query "[].{Name:name, AllowPublicAccess:allowBlobPublicAccess}" --output table
```
> **Use Case:** Quickly lists all storage accounts in your scope and explicitly flags whether they permit public internet access.

### 6. Verify Key Vault Access Policies
Azure Key Vaults store your organization's most sensitive credentials, certificates, and encryption keys.

```bash
az keyvault show --name <vault-name> --query "properties.accessPolicies"
```
> **Use Case:** Allows you to meticulously verify exactly *who* or *what* has the authorization to read, manage, or extract secrets.

---

## 📊 Posture Management & Compliance

### 7. Check Microsoft Defender for Cloud Alerts
Tap directly into Microsoft Defender for Cloud from the command line.

```bash
az security alert list --output table
```
> **Use Case:** Enables rapid command-line triage of suspected malicious activity, anomalous behavior, or active threats across your Azure footprint.

### 8. Evaluate Resource Security Assessments
Get a bird's-eye view of your cloud security posture.

```bash
az security assessment list --query "[].{Resource:resourceDetails.Id, State:status.code, Name:displayName}" --output table
```
> **Use Case:** Lists the compliance state of your deployed resources against Azure's built-in security benchmarks and automated recommendations.

### 9. Review Azure Policy Compliance States
Azure Policies are the backbone of organizational cloud governance. 

```bash
az policy state list --all --output table
```
> **Use Case:** Identifies resources that are currently violating established governance rules (e.g., resources deployed without mandatory encryption, private endpoints, or required tagging).

---

## 🕵️ Logging, Auditing & Forensics

### 10. Investigate the Activity Log
Control-plane visibility is critical during an incident response or configuration audit.

```bash
az monitor activity-log list --offset 7d --output table
```
> **Use Case:** Pulls the last 7 days of Azure Resource Manager (ARM) events, telling you exactly *who* created, modified, or deleted resources in your subscription.
