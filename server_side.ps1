# Check if WinRM is already installed. If not, it will proceed with the installation
if (-not (Get-Service WinRM -ErrorAction SilentlyContinue)) { winrm quickconfig -q}


# Try to find FQDN name of the server
$FQDN = try { [System.Net.Dns]::GetHostEntry($env:COMPUTERNAME).HostName } catch { $env:COMPUTERNAME }

# Add a self signed certificate with 50 years validity
# This is at risk but we set some of security things on it
$cert = New-SelfSignedCertificate `
  -DnsName $FQDN `
  -CertStoreLocation 'Cert:\LocalMachine\My' `
  -NotAfter (Get-Date).AddYears(50) `
  -KeyAlgorithm RSA `
  -KeyLength 4096 `
  -HashAlgorithm SHA256 `
  -KeyExportPolicy NonExportable `
  -KeyUsage DigitalSignature, KeyEncipherment `
  -TextExtension @(
      # EKU = Server Authentication
      '2.5.29.37={text}1.3.6.1.5.5.7.3.1',
      # Basic Constraints: CA=false
      '2.5.29.19={critical}{text}CA=FALSE'
  ) `
  -Provider 'Microsoft Enhanced RSA and AES Cryptographic Provider'

# Delete actual HTTP listener
Remove-Item -Path WSMan:\Localhost\Listener\Listener_*\ -Recurse -Force

$cthumbprint = $cert.Thumbprint

# <Add HTTPS listener
New-Item -Path WSMan:\Localhost\Listener `
  -Transport HTTPS `
  -Address * `
  -Hostname $FQDN `
  -CertificateThumbprint $cert.Thumbprint | Out-Null

# Check if everything is apply
Get-ChildItem WSMan:\Localhost\Listener
winrm enumerate winrm/config/listener

# Export the certificate (upload it on the client side)
Export-Certificate -Cert $cert -FilePath C:\temp\$FQDN.cer

#Add a local firewall rule
#New-NetFirewallRule -DisplayName "WinRM_HTTPS" -Direction Inbound -Action Allow -Enabled True -Protocol TCP -LocalPort 5986 -RemoteAddress xxx.xxx.xxx.xxx -Profile Any

