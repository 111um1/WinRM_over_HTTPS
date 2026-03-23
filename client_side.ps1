<#

# Test WinRM access
test-wsman SERVERNAME -UseSSL

# Import certificate previously export
Import-Certificate -FilePath .\winrm-server.cer -CertStoreLocation Cert:\LocalMachine\Root

#>
