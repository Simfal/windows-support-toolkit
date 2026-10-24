# Start here

This is a separate portfolio project: **Windows IT Support Toolkit**.
Use the Windows client VM from your Active Directory lab. No new VM is needed.
If it is easier to download on your own Windows laptop, this starter also runs locally there.

## 1. Extract the project

Right-click `windows-support-toolkit.zip`, choose **Extract All**, and open the extracted folder.
Go into `windows-support-toolkit` until you can see `Get-SupportReport.ps1`.
Read the script in Notepad or VS Code before running it.

## 2. Open PowerShell in that folder

Click File Explorer's address bar, type `powershell`, and press Enter.
A normal PowerShell window is enough; do not choose Run as administrator.

## 3. Generate your first report

Enter:

```powershell
.\Get-SupportReport.ps1 -OpenReport
```

The report should open in your browser. A copy is saved in the `reports` folder.
The script reads computer details, disk space and configured network settings.
It does not change Windows configuration or attempt repairs.

## If PowerShell blocks the script

On your own lab VM or personal laptop, after reviewing the script, allow local scripts for this PowerShell window:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
```

If prompted, type `Y` and press Enter. This setting ends when you close that PowerShell window.
If Windows also marks the downloaded script as blocked or unsigned, unblock this file:

```powershell
Unblock-File -LiteralPath .\Get-SupportReport.ps1
```

Then rerun:

```powershell
.\Get-SupportReport.ps1 -OpenReport
```

If an organisation's policy blocks execution, keep the error for troubleshooting.

## Your first milestone

- Run the report on Windows.
- Check that the Windows version, RAM and disk values look right.
- Note what each report section tells a support technician.
- Follow `docs/validation.md` to record what actually passed.

The next stage is adding DNS and connectivity checks, then documenting a troubleshooting example and uploading the project to GitHub.

Before sharing screenshots, hide computer names, IP addresses, DNS servers and other local identifiers. Generated reports are excluded by `.gitignore`.

Microsoft reference: [PowerShell execution policies and unblocking](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-5.1).
