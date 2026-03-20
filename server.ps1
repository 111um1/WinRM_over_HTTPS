# Try to find FQDN name of the server
$FQDN = try { [System.Net.Dns]::GetHostEntry($env:COMPUTERNAME).HostName } catch { $env:COMPUTERNAME }

# Add a self signed certificate with 50 years validity
# This is at risk but we set some of security things on it
$cert = New-SelfSignedCertificate `
  -DnsName $FQDN, $env:COMPUTERNAME `
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

# Supprime l’eventuel listener HTTP si tu veux du full HTTPS
Remove-Item -Path WSMan:\Localhost\Listener\Listener_*\ -Recurse -Force

# Crée le listener HTTPS
New-Item -Path WSMan:\Localhost\Listener `
  -Transport HTTPS `
  -Address * `
  -Hostname $FQDN `
  -CertificateThumbprint $cert.Thumbprint | Out-Null

# Vérifications
Get-ChildItem WSMan:\Localhost\Listener
winrm enumerate winrm/config/listener





# $certi = $cert.Thumbprint
# $com = $env:COMPUTERNAME
# $cert = Get-ChildItem Cert:\LocalMachine\My\$certi
# test-wsman xXXX -UseSSL
# Export-Certificate -Cert $cert -FilePath C:\temp\$com.cer
# Import-Certificate -FilePath .\winrm-server.cer -CertStoreLocation Cert:\LocalMachine\Root
