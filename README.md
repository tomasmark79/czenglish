# Czech (czenglish) Keyboard Layout

Rozložení české klávesnice pro zachování maximální podoby US amerického rozložení. V kombinaci s US anglickou klávesnicí se při přepínání těchto dvou rozložení minimalizuje potřeba myslet na změny v klasickém českém rozložení, a zůstávají přístupné formátovací znaky pro Markdown pouze z levé ruky, atd.

![image](czenglish-keyboard-layout.png)

## Instalace

### Linux (X11/XKB)

Konfigurace probíhá v:

```bash
sudo vim /usr/share/X11/xkb/symbols/cz
sudo vim /usr/share/X11/xkb/rules/evdev.xml
```

Zkopírujte obsah souboru `czenglish_layout` do `/usr/share/X11/xkb/symbols/cz` a přidejte variantu z `evdev.xml` do `/usr/share/X11/xkb/rules/evdev.xml`.

### Windows

#### Varianta A: Stažení připraveného instalátoru (doporučeno)

1. **Stáhněte instalátor** z [GitHub Releases](https://github.com/tomasmark79/czenglish/releases)
2. **Rozbalte ZIP** a spusťte `setup.exe` jako administrátor
3. **Restartujte** počítač nebo se odhlaste a přihlaste
4. **Aktivujte layout**:
   - Settings → Time & Language → Language & region
   - Czech → Options → Add a keyboard → Czech CZ-EN
5. **Přepínejte** layouty pomocí Windows + Space

#### Varianta B: Kompilace ze zdrojového souboru

1. **Stáhněte Microsoft Keyboard Layout Creator (MSKLC)**
   - [MSKLC Download](https://www.microsoft.com/en-us/download/details.aspx?id=102134)
2. **Zkompilujte layout**
   - Otevřete MSKLC
   - Načtěte soubor `czenglish.klc` (File → Load Source File)
   - Zkompilujte: Project → Build DLL and Setup Package
3. **Nainstalujte** vygenerovaný `setup.exe` jako administrátor

## Layout funkce

### Základní české znaky (bez Shift):
```
Klávesy: 2 3 4 5 6 7 8 9 0 ; [
Znaky:   ě š č ř ž ý á í é ů ú
```

### Se Shiftem:
```
Číslice: 1 2 3 4 5 6 7 8 9 0
```

### S AltGr (pravý Alt / Ctrl+Alt):
```
Speciální znaky: @ # $ % ^ & * ( ) = € [ ;
```

### Dead keys:
- **`=` klávesa**: Dead acute → pak písmeno → á, é, í, ó, ú, ý
- **Shift + `=`**: Dead caron → pak písmeno → č, ď, ě, ň, ř, š, ť, ž

## Soubory

- `czenglish_layout` - XKB layout definice pro Linux
- `evdev.xml` - Fragment pro registraci v XKB
- `czenglish.klc` - Microsoft Keyboard Layout Creator soubor pro Windows
- `Install-Windows.bat` - Instalační skript pro Windows
- `czenglish-keyboard-layout.png` - Vizualizace layoutu

## Licence

© 2025 Tomas Mark (tomas@digitalspace.name)

