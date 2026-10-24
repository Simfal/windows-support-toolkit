# Start here

## 1. Extract the project

If you downloaded a ZIP, right-click it, choose **Extract All**, and click **Extract**. Open the extracted folder until `Get-SupportReport.ps1` is visible. Review the script in Notepad or VS Code before running it.

Use your personal Windows laptop or Windows lab VM. No new VM is required.

## 2. Open PowerShell in that folder

In File Explorer, press **Alt + D**, type `powershell`, and press **Enter**. A normal PowerShell window is sufficient.

## 3. Generate a report

Run:

```powershell
.\Get-SupportReport.ps1 -OpenReport
```

The script reads computer, disk and network settings, then checks IPv4 DNS resolution and TCP port 443 connectivity to `www.microsoft.com`. It saves an HTML report in `reports` and opens it in your browser. It does not change Windows configuration or attempt repairs.

Wait for the network checks to finish. Review the report's computer information, disk status and DNS/TCP results.

## If PowerShell blocks the script

On your personal laptop or lab VM, after reviewing the script, run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
```

If prompted, enter `Y`. This policy setting ends when you close the PowerShell window. Unblock the downloaded file and run it:

```powershell
Unblock-File -LiteralPath .\Get-SupportReport.ps1
.\Get-SupportReport.ps1 -OpenReport
```

If an organisation's policy blocks execution, keep the error for troubleshooting with its IT team.

## Record your results

Use `docs/validation.md` to record what you actually checked. Existing results describe the project owner's session; add a separate entry for your own run.

The disk-warning test and the toolkit's limitations are described in `README.md`.

## Before uploading to GitHub

- Include the script, README, this guide, `.gitignore` and `docs` folder.
- Exclude the generated `reports` folder and ZIP archives from browser uploads.
- Redact computer names, local IP addresses, gateways and DNS server details from screenshots.

The `.gitignore` excludes the default report folder from Git tracking; it does not filter browser uploads.
