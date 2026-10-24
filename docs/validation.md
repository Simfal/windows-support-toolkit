# Windows validation log

Recorded on 24 October 2026 from the guided home lab session. The script was run by the project owner on a Windows laptop. These are manual observations, not automated unit tests.

- Windows edition: Windows 11 Home
- Windows version reported by the script: 10.0.26300
- PowerShell version: not recorded

## Results

| Check | Action | Observed result | Status |
| --- | --- | --- | --- |
| Normal report | Run `.\Get-SupportReport.ps1 -OpenReport` | HTML opened with computer, disk and network sections | Passed |
| Information review | Review the Windows version, RAM, disk values and network settings | Owner confirmed the values looked correct | Passed by owner review |
| Warning branch | Run `.\Get-SupportReport.ps1 -LowDiskThreshold 100 -OpenReport` | Owner confirmed that Low space appeared | Passed by owner observation |
| Return to default | Run the normal command again | Report showed the 15% threshold; the measured disk showed OK | Passed |
| Automated DNS check | Run the updated script | Report showed DNS lookup for www.microsoft.com: Passed | Passed |
| Automated TCP check | Run the updated script | Report showed TCP connection to port 443: Passed | Passed |
| Unique report filenames | Compare filenames from separate runs | Repeated reports were opened, but filename uniqueness was not explicitly checked | Not checked |
| Parameter validation | Run `.\Get-SupportReport.ps1 -LowDiskThreshold 0` | Expected: PowerShell rejects the value before generating a report | Not run |
| Network failure handling | Exercise DNS and TCP failure cases in the lab | Expected: failure details appear while the report is still generated | Not run |

RAM and disk capacities use GiB (bytes divided by 1,073,741,824). Configured adapter values are collected separately from the DNS and TCP checks. A successful TCP check does not validate a website's HTTPS certificate or content.

## Setup issues resolved

1. The command was initially run from the user home folder, where the script was not present.
2. File Explorer was displaying the ZIP archive. Extracting the files and opening PowerShell in the extracted script folder resolved the path issue.
3. The execution policy initially blocked scripts. A process-scoped RemoteSigned policy was set, and the downloaded script was unblocked before running.
4. DNS and TCP diagnostics were added to the script and their successful results were confirmed in the HTML report.

## Explain it in an interview

- What information a technician gains from each section
- How the configurable disk threshold works
- Why configured network settings alone do not prove connectivity
- How DNS resolution and a TCP port check differ
- Which checks passed, which remain pending and what the toolkit cannot diagnose
