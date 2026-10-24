# Windows IT Support Toolkit

A PowerShell home lab project that generates an HTML report for basic Windows support checks.

## Features

- Windows version, RAM and system uptime
- Disk capacity and free-space information
- Low disk-space warnings with an adjustable threshold
- Network adapter, IP, gateway and DNS settings
- IPv4 DNS lookup for `www.microsoft.com`
- TCP connectivity check to port 443 on `www.microsoft.com`
- HTML report saved in the `reports` folder

## Requirements

- Windows with PowerShell 5.1 or later
- `Resolve-DnsName` and `Test-NetConnection` commands available
- Network access for the DNS and TCP checks

The toolkit was manually checked on Windows 11 Home. A normal PowerShell window is sufficient.

## Run the toolkit

Open PowerShell in the project folder and run:

```powershell
.\Get-SupportReport.ps1 -OpenReport
```

The report opens in your browser and is saved in the `reports` folder. It collects a snapshot of the computer and checks DNS resolution and TCP connectivity to the Microsoft endpoint.

If script execution is blocked on your personal computer, review the script, then run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
Unblock-File -LiteralPath .\Get-SupportReport.ps1
.\Get-SupportReport.ps1 -OpenReport
```

If prompted, enter `Y`. The execution-policy change lasts only for that PowerShell session. If an organisation's policy blocks execution, keep the error for troubleshooting with its IT team.

## Test the disk warning

```powershell
.\Get-SupportReport.ps1 -LowDiskThreshold 100 -OpenReport
```

Disks with less than 100% free space should show **Low space**. This tests the warning without filling the disk. The normal threshold is less than 15% free space and applies again on the next run without the threshold argument.

## Validation

Manually checked during the guided home lab session:

- HTML report generated and opened
- Windows, RAM and disk information reviewed
- Low-space warning triggered using the 100% test threshold
- Normal report generated again with the 15% threshold
- Automated DNS and TCP checks passed and appeared in the report

See [the validation log](docs/validation.md) for results and checks still pending. These are manual checks; this repository does not contain an automated test suite.

## Limitations

- The DNS check requests IPv4 records.
- The TCP check confirms a connection to one server on port 443; it does not validate HTTPS certificates or website content.
- Network checks depend on the configured network and the external endpoint, and may take time to finish.
- Network failure scenarios and invalid-parameter rejection have not yet been tested.
- This is an inventory and diagnostics tool; it does not attempt repairs.

## Privacy

Generated reports contain local device and network details. The `.gitignore` excludes the default `reports` folder from Git tracking. Keep reports out of browser uploads too, and redact local details from shared screenshots. Reports saved to a custom output directory also need to be excluded before uploading.

## Skills demonstrated

PowerShell scripting, Windows troubleshooting, CIM queries, network diagnostics, HTML reporting and manual validation.
