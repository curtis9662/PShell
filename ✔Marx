# 🛡️ Enterprise Runbook: Checkmarx Integration & Migration

**Objective:** Automate security scanning for the GitHub codebase using Checkmarx (CxSAST/CxOne) API.  
**Scope:** Migration validation, API integration, and GitHub Actions workflow.

---

## 1. Prerequisites & Authentication
**Critical:** Ensure all credentials are validated before attempting API calls.

* **Access Control:** Verify the target project exists in the Checkmarx instance.
* **API Key Generation:**
    * Log into the Checkmarx User Interface.
    * Navigate to *User Settings* and generate an **OAuth2 Refresh Token** or **API Key**.
* **Project Identification:**
    * Retrieve the `projectID` for the codebase being migrated.
    * *Method:* Use the UI or query the API:
        ```http
        GET /projects
        ```

---

## 2. API Workflow Execution
Follow this sequence to initialize and trigger scans programmatically.

### Step A: Configure Scan Target
Link the Checkmarx project to the GitHub repository.

* **Endpoints:**
    * SSH: `POST /api/v1/projects/{id}/configuration/ssh`
    * HTTPS: `POST /api/v1/projects/{id}/configuration/git`
* **Action:** Provide the GitHub Repository URL and target branch (e.g., `main`, `migration-dev`).

### Step B: Trigger the Scan
Initiate the SAST scan once the repository is linked.

* **Endpoint:** `POST /api/v1/scans`
* **Payload:**
    ```json
    {
      "project": { "id": "your-project-uuid" },
      "type": "sast",
      "handler": { "branch": "main" }
    }
    ```

### Step C: Monitor Status
Scans are asynchronous. Poll the status until completion.

* **Endpoint:** `GET /api/v1/scans/{scanId}`
* **Success Criteria:** Status transitions from `Running` to `Completed`.

---

## 3. Migration Strategy (Lift & Shift)
When moving repositories or restructuring folders, strictly adhere to this security baseline process:

1.  **Baseline Scan:** Execute a full scan on the *source* code prior to migration to establish a cleanliness benchmark.
2.  **Incremental Validation:** Immediately post-migration, run an incremental scan to detect any misconfigurations introduced during the move.
3.  **Remote URL Consistency:**
    > **Note:** If using the Checkmarx GitHub Action or CLI, ensure the `CX_PROJECT_NAME` remains consistent to preserve scan history.

---

## 4. CI/CD Integration (GitHub Actions)
For automated migrations, the Checkmarx GitHub Action is recommended over raw API calls.

**Implementation:**
Create or update `.github/workflows/checkmarx.yml`:

```yaml
- name: Checkmarx AST Scan
  uses: checkmarx/ast-github-action@main
  with:
    project_name: ${{ github.event.repository.name }}
    base_uri: ${{ secrets.CX_BASE_URI }}
    cx_client_id: ${{ secrets.CX_CLIENT_ID }}
    cx_client_secret: ${{ secrets.CX_CLIENT_SECRET }}
