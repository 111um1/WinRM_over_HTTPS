<#

# Import certificate previously export
Import-Certificate -FilePath .\winrm-server.cer -CertStoreLocation Cert:\LocalMachine\Root

# Test WinRM access
test-wsman SERVERNAME -UseSSL

# Basic test
Invoke-Command -ComputerName SERVERNAME -UseSSL -ScriptBlock { ipconfig }
Invoke-Command -ComputerName (Get-Content .\servers.txt) -UseSSL -ScriptBlock { ipconfig }
``

# Check if domain firewall is enabled
Invoke-Command -ComputerName (Get-Content .\servers_sage.txt) -UseSSL -ScriptBlock {
  Get-NetFirewallProfile | ForEach-Object {
    [pscustomobject]@{
      Hostname = $env:COMPUTERNAME
      Profil   = $_.Name
      Actif    = $_.Enabled
    }
  }
} |
Sort-Object Hostname, Profil |
Where-Object { $_.Profil -eq "Public" -and $_.Actif -eq $false } |
Format-Table -AutoSize

#>
