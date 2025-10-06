# Czech (czenglish) Keyboard Layout - Windows Installation

## Metoda 1: Microsoft Keyboard Layout Creator (MSKLC) - Doporučeno

### Instalace

1. **Stáhněte MSKLC**
   - Stáhněte Microsoft Keyboard Layout Creator z: https://www.microsoft.com/en-us/download/details.aspx?id=102134
   - Nainstalujte aplikaci

2. **Načtěte layout**
   - Spusťte MSKLC
   - Klikněte na `File` → `Load Source File...`
   - Vyberte soubor `czenglish.klc`

3. **Zkompilujte a nainstalujte**
   - V MSKLC klikněte na `Project` → `Build DLL and Setup Package`
   - Po dokončení buildu otevřete vytvořenou složku
   - Spusťte `setup.exe` jako administrátor
   - Postupujte podle průvodce instalací

4. **Aktivujte layout**
   - Otevřete `Settings` → `Time & Language` → `Language & region`
   - Klikněte na `Czech` → `Options`
   - V sekci `Keyboards` klikněte `Add a keyboard`
   - Vyberte `Czech (czenglish)`

## Metoda 2: PowerShell Instalační Skript

### Použití instalačního skriptu

```powershell
# Spusťte PowerShell jako administrátor
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\Install-CzEnglishLayout.ps1
```

### Manuální instalace pomocí PowerShell

```powershell
# 1. Nejprve je potřeba zkompilovat layout pomocí MSKLC (viz Metoda 1, krok 1-3)

# 2. Po instalaci restartujte počítač nebo se odhlaste a přihlaste

# 3. Přidejte layout do systému
$layoutList = Get-WinUserLanguageList
$layoutList.Add("cs-CZ")
Set-WinUserLanguageList $layoutList -Force

# 4. Layout by měl být nyní dostupný v Language & region settings
```

## Metoda 3: Registry Import (Pokročilé)

**Varování:** Úprava registru může způsobit problémy se systémem. Vždy si zálohujte registry před prováděním změn.

```powershell
# Tuto metodu použijte pouze pokud metody 1 a 2 nefungují
# Registry soubor bude vytvořen během buildu v MSKLC
```

## Odinstalace

### Pomocí MSKLC
1. Otevřete vytvořený instalační balíček
2. Spusťte uninstaller

### Pomocí Control Panel
1. `Control Panel` → `Programs` → `Programs and Features`
2. Najděte `Czech (czenglish)`
3. Klikněte `Uninstall`

### Ruční odstranění
```powershell
# PowerShell jako administrátor
$layoutList = Get-WinUserLanguageList
$layoutList = $layoutList | Where-Object {$_.InputMethodTips -notlike "*czenglish*"}
Set-WinUserLanguageList $layoutList -Force
```

## Přepínání mezi layouty

- **Windows + Space**: Přepíná mezi nainstalovanými layouty
- **Alt + Shift**: Alternativní metoda přepínání (pokud je povoleno)

## Testování layoutu

Po instalaci můžete layout otestovat v poznámkovém bloku (Notepad):

```
Základní znaky: ěščřžýáíé
S Shiftem: ĚŠČŘŽÝÁÍÉ
Dead keys: 
  - AltGr + = (caron): c → č, s → š, r → ř
  - AltGr + - (acute): a → á, e → é, i → í
```

## Klávesové zkratky (AltGr)

- **AltGr + E**: € (Euro)
- **AltGr + [ (ú)**: [ (hranaté závorky)
- **AltGr + ; (ů)**: ; (středník)
- **AltGr + =**: Dead caron (háček)
- **AltGr + \**: Dead diaeresis (přehláska)

## Problémy a řešení

### Layout se nezobrazuje po instalaci
- Restartujte počítač
- Zkontrolujte, zda je česká lokalizace nainstalována v systému
- Zkuste znovu přidat layout přes `Language & region`

### Dead keys nefungují správně
- Ujistěte se, že používáte správnou kombinaci kláves (AltGr + klávesa)
- Dead keys vyžadují dva stisknutí: 1) dead key, 2) písmeno

### Layout se neinstaluje
- Ujistěte se, že máte administrátorská práva
- Zkontrolujte, zda je MSKLC správně nainstalován
- Ověřte, že soubor .klc není poškozen

## Požadavky na systém

- Windows 10 nebo novější (doporučeno)
- Windows 7/8/8.1 (s omezenou podporou)
- Microsoft Keyboard Layout Creator 1.4 nebo novější
- Administrátorská práva pro instalaci

## Poznámky

- Layout byl navržen pro zachování maximální podobnosti s US layoutem
- Všechny české znaky jsou dostupné bez přepínání layoutu
- Dead keys umožňují psát i znaky s diakritikou pro jiné jazyky

## Podpora

Pro hlášení problémů nebo dotazy:
- GitHub: https://github.com/tomasmark79/czenglish
- Email: tomas@digitalspace.name

---

© 2025 Tomas Mark
