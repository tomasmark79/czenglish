# Czenglish Keyboard Layout

České rozložení klávesnice pro zachování maximální kompatibility s anglickým rozložením.

> Prakticky se jedná o finální verzi rozložení

![nativní](czenglish-1.png)
![se shiftem a s pravým altem](czenglish-2.png)
![se shiftem](czenglish-3.png)
![s pravým altem (altgr)](czenglish-4.png)

# Instalace

### Linux (XKB)

Použijte script pro automatickou instalaci:

```bash
git clone https://github.com/tomasmark79/czenglish.git
cd czenglish![alt text](image.png)
./Install-Linux.sh
```   

#### NixOS
```nix
# Czenglish keyboard layout
  services.xserver.xkb = {
    extraLayouts.cze = {
      description = "Czenglish";
      languages = [ "czech" ];
      symbolsFile =
        pkgs.fetchFromGitHub {
          owner = "tomasmark79";
          repo = "czenglish";
          rev = "5a405e5f96103e997a9f5f64e0403eb5a1e8f6c0";
          hash = "sha256-i0NDINIy8kOHT+QRC+lZ8VzOJT2rguqCNr8dbCvCFkc=";
        }
        + "/czenglish_layout";
    };
    layout = "us";
    variant = "";
    options = "eurosign:e,caps:escape";
  };
```

#### Manuální hack instalace

1. **Zkopírujte soubory** `czenglish_layout` a `evdev.xml` do `/usr/share/X11/xkb/symbols/` a `/usr/share/X11/xkb/rules/` (vyžaduje root oprávnění)
2. **Restartujte X server** nebo se odhlaste a přihlaste znovu
3. **Vyberte nový layout** v nastavení klávesnice vašeho desktopového prostředí (např. GNOME, KDE, XFCE).

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


