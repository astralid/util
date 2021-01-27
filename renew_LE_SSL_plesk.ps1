<#
.SYNOPSIS
Renew Let's Encrypt SSL/TLS certificate.
.DESCRIPTION
This is a wrapper script for Posh-ACME ACMEv2 client to renew LE SSL/TLS certificates with HTTP authentication.
.LINK
janih.eu
#>

# Copyright 2020 Jani Huumonen. All rights reserved.

#TODO: select account
Set-PAAccount -ID 00000000
$domain = 'domain.tld'
$contact = 'a@b.c'
$csrpath = "$PSScriptRoot\domain-csr.txt"

Set-PAServer LE_PROD
if (-not (Get-PAAccount)) {
    New-PAAccount -AcceptTOS -Contact $contact
}
"Olet uusimassa ssl-sertifikaattia:  $domain  $((Get-PAAccount).contact), haluatko jatkaa?"
$confirmation = Read-Host "y/n?"
if ($confirmation -ne 'y') { exit }

New-PAOrder $domain
$auths = Get-PAOrder | Get-PAAuthorizations
$keyauth = Get-KeyAuthorization $auths.HTTP01Token (Get-PAAccount)
$keyauth | Out-File -FilePath "./$($auths.HTTP01Token)" -Encoding ascii
"Tiedosto $($auths.HTTP01Token) luotu kansioon: TODO:<kansion nimi>, lataa se ennen jatkamista palvelimelle osoitteeseen:"
"http://$($auths.fqdn)/.well-known/acme-challenge/"
"Haluatko jatkaa?"
#TODO: automaattinen upload vaihtoehto

do {
    $confirmation = Read-Host "y/n?"
    if ($confirmation -ne 'y') { exit }
} until (
    (Invoke-WebRequest -Uri "http://$($auths.fqdn)/.well-known/acme-challenge/$($auths.HTTP01Token)").Content.Replace("`r`n","") `    -eq $keyauth
) # godaddy windows webhotel returns a string with line ending

$auths.HTTP01Url | Send-ChallengeAck
do {
    "Tarkistetaan ..."
    Start-Sleep -Seconds 5
    $checking = (Get-PAOrder | Get-PAAuthorizations).HTTP01Status
} until ( $checking -eq "valid" -or $checking -eq "invalid" )

if ($checking -eq 'valid') {
    if ((Get-PAOrder -Refresh).status -eq "ready") {
        New-PACertificate -CSRPath $csrpath
        "`nVarmenne:`n"
        Get-Content -Encoding Ascii (Get-PACertificate).CertFile
        "`nCA-varmenne:`n"
        Get-Content -Encoding Ascii (Get-PACertificate).ChainFile
        "Voit nyt poistaa aiemmin lataamasi tiedoston sekä palvelimelta, että omalta koneeltasi."
        "`nKopioi ja liitä nämä 2 varmennetta 'Varmenne' ja 'CA-varmenne' kenttiin Plesk hallintapaneelin"
        "Verkkosivustot ja toimialueet > SSL/TLS-varmenteet > top (valitse kohteet-listasta)"
        "sivulla ja paina 'Lataa varmenne'."
#TODO: automaattinen kopiointi leikepöydälle
    } else {
        "(Get-PAOrder -Refresh).status NOT ready"
    }
} else {
    (Get-PAOrder | Get-PAAuthorizations).challenges.error | fl
    "Tapahtui virhe!"
}
Read-Host "`nPaina enter lopettaaksesi."
