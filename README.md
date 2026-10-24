# \# Windows IT Support Toolkit

# 

# A PowerShell home lab project that generates an HTML report for basic Windows support checks.

# 

# \## Features

# 

# \- Windows version, RAM and system uptime

# \- Disk capacity and free-space information

# \- Low disk-space warnings with an adjustable threshold

# \- Network adapter, IP, gateway and DNS settings

# \- DNS lookup for www.microsoft.com

# \- TCP connectivity check to port 443

# \- HTML report saved in the reports folder

# 

# \## Requirements

# 

# \- Windows

# \- Windows PowerShell 5.1 or later

# \- Resolve-DnsName and Test-NetConnection commands available

# \- Network access for the DNS and TCP checks

# 

# \## Run the toolkit

# 

# Open PowerShell in the project folder and run:

# 

# ```powershell

# .\\Get-SupportReport.ps1 -OpenReport

# ```

# 

# The report opens in your browser.

# 

# If script execution is blocked on your personal computer, run:

# 

# ```powershell

# Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned

# Unblock-File -LiteralPath .\\Get-SupportReport.ps1

# .\\Get-SupportReport.ps1 -OpenReport

# ```

# 

# The execution-policy change lasts only for that PowerShell session.

# 

# \## Test the disk warning

# 

# ```powershell

# .\\Get-SupportReport.ps1 -LowDiskThreshold 100 -OpenReport

# ```

# 

# Disks with less than 100% free space should show “Low space”.

# This tests the warning without filling the disk.

# 

# \## Validation

# 

# Manually checked on Windows 11 Home:

# 

# \- HTML report generated and opened

# \- Computer and disk information checked

# \- Low-space warning triggered using the test threshold

# \- Automated DNS and TCP checks passed in the report

# 

# See docs/validation.md for the checklist.

# 

# \## Limitations

# 

# The DNS check requests IPv4 records. The TCP check confirms a connection to one server on port 443; it does not validate HTTPS certificates or website content. Network failure scenarios have not yet been tested.

# 

# \## Privacy

# 

# Generated reports contain local device and network details.

# Keep the reports folder out of GitHub uploads and hide these details in shared screenshots.

# 

# \## Skills demonstrated

# 

# PowerShell scripting, Windows troubleshooting, CIM queries, network diagnostics, HTML reporting and manual validation.

