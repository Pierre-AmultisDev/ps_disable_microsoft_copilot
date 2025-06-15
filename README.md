# 1. Introductie
__disable_copilot.ps1__ is een PowerShell-script dat de microsoft copilot licentie uitzet voor geberuikers die in het bestand __copilot-users.csv__ staan.

Dit script:
- Controleert of een gebruiker een Copilot-licentie heeft.
- De Copilot-licentie verwijdert als die is toegewezen.

Dit vereist dat je de Microsoft Graph PowerShell SDK geïnstalleerd hebt en de juiste rechten hebt (bijv. License Administrator, Global Administrator of User Administrator).
 
# 2. Voorbereiding
## 2.1. Microsoft Graph
Installeren van Microsoft Graph PowerShell (indien nog niet gedaan) via powershell:
```
Install-Module Microsoft.Graph -Scope CurrentUser
```

## 2.2. Powershell actief maken voor lokaal gebruik (eenmalig)
Open een terminal window en geef eerst volgende commando.
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```
om er voor te zorgen dat dit niet ondertekend script uitgevoerd mag worden. 
en daarna in hetzelfde terminal window
```
.\disable_copilot.ps1 
```

# 3. Benodigde CSV-indeling
Bijvoorbeeld een bestand genaamd .\users\copilot-users.csv met deze inhoud:
```
UserPrincipalName
jan.jansen@bedrijf.nl
piet.pietersen@bedrijf.nl
klant.support@bedrijf.nl
```
De kolom moet exact UserPrincipalName heten (hoofdlettergevoelig als je Import-Csv gebruikt zonder aanpassingen.
