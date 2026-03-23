<#

# Import certificate previously export
Import-Certificate -FilePath .\winrm-server.cer -CertStoreLocation Cert:\LocalMachine\Root

# Test WinRM access
test-wsman SERVERNAME -UseSSL

# Basic test
Invoke-Command -ComputerName SERVERNAME -UseSSL -ScriptBlock { ipconfig }

#>
