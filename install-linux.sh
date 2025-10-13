#!/bin/bash

# Czech (czenglish) Keyboard Layout - Linux Installation Script
# 2025 - (C) - Tomas Mark (tomas@digitalspace.name)

set -e

# Barvy pro výstup
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "  CZEnglish Keyboard Layout Installer  "
echo "========================================"
echo ""

# Kontrola root práv
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Chyba: Tento skript musí být spuštěn jako root (použijte sudo)${NC}"
    exit 1
fi

# Kontrola existence XKB
XKB_SYMBOLS="/usr/share/X11/xkb/symbols/cz"
XKB_RULES="/usr/share/X11/xkb/rules/evdev.xml"

if [ ! -d "/usr/share/X11/xkb" ]; then
    echo -e "${RED}Chyba: XKB není nainstalován na tomto systému${NC}"
    exit 1
fi

# Záloha souborů
echo -e "${YELLOW}Vytvářím zálohy...${NC}"
cp "$XKB_SYMBOLS" "$XKB_SYMBOLS.backup.$(date +%Y%m%d_%H%M%S)"
cp "$XKB_RULES" "$XKB_RULES.backup.$(date +%Y%m%d_%H%M%S)"
echo -e "${GREEN}✓ Zálohy vytvořeny${NC}"

# Přidání layoutu do symbols/cz
echo -e "${YELLOW}Přidávám layout do $XKB_SYMBOLS...${NC}"
if grep -q "xkb_symbols \"czenglish\"" "$XKB_SYMBOLS"; then
    echo -e "${YELLOW}! Layout czenglish již existuje, přeskakuji...${NC}"
else
    cat czenglish_layout >> "$XKB_SYMBOLS"
    echo -e "${GREEN}✓ Layout přidán${NC}"
fi

# Přidání varianty do evdev.xml
echo -e "${YELLOW}Registruji variantu v $XKB_RULES...${NC}"
if grep -q "<name>czenglish</name>" "$XKB_RULES"; then
    echo -e "${YELLOW}! Varianta czenglish již je registrována, přeskakuji...${NC}"
else
    # Najdeme sekci pro české layouty a přidáme variantu
    TEMP_FILE=$(mktemp)
    awk '
        /<name>cz<\/name>/ { in_cz=1 }
        in_cz && /<\/variantList>/ { 
            print "        <variant>"
            print "          <configItem>"
            print "            <name>czenglish</name>"
            print "            <description>Czech (czenglish)</description>"
            print "          </configItem>"
            print "        </variant>"
            print
            in_cz=0
            next
        }
        { print }
    ' "$XKB_RULES" > "$TEMP_FILE"
    
    cp "$TEMP_FILE" "$XKB_RULES"
    rm "$TEMP_FILE"
    echo -e "${GREEN}✓ Varianta zaregistrována${NC}"
fi

# Vyčištění cache
echo -e "${YELLOW}Čistím XKB cache...${NC}"
rm -rf /var/lib/xkb/* 2>/dev/null || true
echo -e "${GREEN}✓ Cache vyčištěna${NC}"

echo ""
echo -e "${GREEN}========================================"
echo "  Instalace úspěšně dokončena!  "
echo "========================================${NC}"
echo ""
echo "Aktivace klávesnice:"
echo "  1. Otevřete nastavení systému"
echo "  2. Přejděte do sekce Klávesnice / Keyboard"
echo "  3. Přidejte nový layout: Czech (czenglish)"
echo "  4. Odhlaste se a znovu přihlaste (nebo restartujte X server)"
echo ""
echo "Pro obnovení záložních souborů najdete v:"
echo "  $XKB_SYMBOLS.backup.*"
echo "  $XKB_RULES.backup.*"
echo ""
