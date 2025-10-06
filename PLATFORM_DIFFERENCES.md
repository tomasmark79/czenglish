# Rozdíly mezi Linux a Windows verzí layoutu

## ⚠️ Důležité rozdíly

Kvůli omezením Windows code page 1250 byly z Windows verze odstraněny některé znaky:

### ❌ Odstraněno z Windows verze:

1. **AltGr + Shift + 2**: Combining caron (ˇ) - dead key
   - **Důvod**: Combining znak U+030C není v Windows code page 1250
   - **Alternativa**: Použijte Shift + = pro dead caron

2. **AltGr + \**: Dead diaeresis (¨)
   - **Důvod**: Výsledné znaky ï, ÿ, Ï, Ÿ nejsou v code page 1250
   - **Alternativa**: Není pro češtinu nutné

## ✅ Co funguje identicky na obou platformách:

### Základní české znaky (Base state):
```
Klávesy: 2 3 4 5 6 7 8 9 0 ; [
Znaky:   ě š č ř ž ý á í é ů ú
```

### Se Shiftem:
```
Klávesy: 2 3 4 5 6 7 8 9 0 ; [
Znaky:   2 3 4 5 6 7 8 9 0 : {
```

### S AltGr (Ctrl+Alt na Windows):
```
2 → @
3 → #
4 → $
5 → %
6 → ^
7 → &
8 → *
9 → (
0 → )
= → =
E → € (Euro)
[ → [
; → ;
```

### S AltGr + Shift:
```
3 → Š
4 → Č
5 → Ř
6 → Ž
7 → Ý
8 → Á
9 → Í
0 → É
= → +
[ → Ú
; → Ů
```

### Dead keys (identické):
| Klávesa | Linux | Windows | Funkce |
|---------|-------|---------|--------|
| `=` | ✅ | ✅ | Dead acute (á, é, í, ó, ú, ý) |
| Shift + `=` | ✅ | ✅ | Dead caron (č, ď, ě, ň, ř, š, ť, ž) |
| AltGr + `\` | ✅ | ❌ | Dead diaeresis (ä, ë, ö, ü) - **NENÍ na Windows** |
| AltGr + Shift + `2` | ✅ | ❌ | Combining caron - **NENÍ na Windows** |

## 💡 Doporučení pro uživatele:

Pokud používáte layout na obou platformách:
- Používejte **Shift + =** pro háčky (dead caron) - funguje všude
- Používejte **=** pro čárky (dead acute) - funguje všude
- Vyhněte se AltGr + \ a AltGr + Shift + 2 na Linuxu, pokud chcete konzistenci

## 🔧 Technické detaily:

**Windows code page 1250** obsahuje:
- ✅ Všechny české znaky: ěščřžýáíéůúďťň + velká písmena
- ✅ Dead keys: acute (´) a caron (ˇ)
- ❌ Combining characters: U+030C
- ❌ Některé diakritické znaky: ï, ÿ, Ï, Ÿ

**Linux XKB** podporuje:
- ✅ Vše z Windows verze
- ✅ Všechny Unicode znaky včetně combining characters
- ✅ Dead diaeresis

## 📝 Poznámka:

I přes drobné rozdíly jsou oba layouty **99% identické** pro běžné psaní v češtině. Všechny české znaky fungují stejně na obou platformách.
