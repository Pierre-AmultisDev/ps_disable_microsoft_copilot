# Inloggen bij Microsoft Graph (indien nodig wordt gevraagd om in te loggen)
Connect-MgGraph -Scopes "User.Read.All", "Directory.ReadWrite.All"

# === Instellingen ===

# Pad naar het CSV-bestand met gebruikers
$csvPath = ".\users\copilot-users.csv"

# Pad naar het logbestand dat wordt aangemaakt
$logPath = ".\logs\copilot-remove-log.csv"

# Naam van de Copilot-licentie (aanpassen als jouw tenant een andere naam gebruikt)
$copilotSkuPartNumber = "MICROSOFT_365_COPILOT"

# === Voorbereiding ===

# CSV-bestand inlezen
$csv = Import-Csv -Path $csvPath

# Loggegevens bijhouden
$logData = @()

# Licenties ophalen in tenant
$licenses = Get-MgSubscribedSku
$copilotSku = $licenses | Where-Object { $_.SkuPartNumber -eq $copilotSkuPartNumber }

if ($copilotSku -eq $null) {
    Write-Host "❌ Copilot-licentie niet gevonden in de tenant. Controleer de licentienaam." -ForegroundColor Red
    return
}

$copilotSkuId = $copilotSku.SkuId

# === Verwerking per gebruiker ===
foreach ($entry in $csv) {
    $upn = $entry.UserPrincipalName
    $status = ""
    $details = ""

    Write-Host "▶ Verwerken: $upn"

    try {
        # Gebruiker ophalen
        $user = Get-MgUser -UserId $upn
        $userLicenses = $user.AssignedLicenses

        if ($userLicenses.SkuId -contains $copilotSkuId) {
            Write-Host "🔎 Copilot-licentie gevonden. Verwijderen..." -ForegroundColor Yellow

            $removeLicenses = @(@{
                SkuId = $copilotSkuId
            })

            Set-MgUserLicense -UserId $user.Id -RemoveLicenses $removeLicenses -AddLicenses @()
            Write-Host "✅ Licentie verwijderd bij $upn" -ForegroundColor Green

            $status = "Licentie verwijderd"
            $details = "Copilot-licentie was aanwezig en is verwijderd"
        } else {
            Write-Host "ℹ️ Geen Copilot-licentie aanwezig bij $upn" -ForegroundColor Gray
            $status = "Geen licentie"
            $details = "Gebruiker had geen Copilot-licentie"
        }
    } catch {
        Write-Host "❌ Fout bij verwerken van ${upn}: $($_.Exception.Message)" -ForegroundColor Red
        $status = "Fout"
        $details = $_.Exception.Message
    }

    # Voeg regel toe aan loggegevens
    $logData += [PSCustomObject]@{
        Tijdstempel = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Gebruiker   = $upn
        Status      = $status
        Details     = $details
    }
}

# === Logbestand opslaan ===
$logData | Export-Csv -Path $logPath -NoTypeInformation -Encoding UTF8
Write-Host "Logbestand opgeslagen op: $logPath" -ForegroundColor Cyan
