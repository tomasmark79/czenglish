#!/usr/bin/env python3
"""Install the cz(czenglish) XKB variant and its IBus Simple descriptor."""

import argparse
from datetime import datetime
import os
from pathlib import Path
import re
import shutil
import sys
import tempfile
import xml.etree.ElementTree as ET

ENGINE = "xkb:cz:czenglish:ces"


def xml_document(path):
    # Retain comments; parse before any system file is modified.
    parser = ET.XMLParser(target=ET.TreeBuilder(insert_comments=True))
    return ET.fromstring(path.read_bytes(), parser=parser)


def xml_bytes(root):
    return ET.tostring(root, encoding="utf-8", xml_declaration=True) + b"\n"


def update_xkb(path):
    root = xml_document(path)
    layout = root.find("./layoutList/layout/configItem[name='cz']/..")
    if layout is None:
        raise ValueError(f"{path}: chybí české rozložení cz")
    variants = layout.find("variantList")
    if variants is None:
        variants = ET.SubElement(layout, "variantList")
    matches = variants.findall("./variant/configItem[name='czenglish']/..")
    if len(matches) == 1:
        return path.read_bytes()
    for item in matches:
        variants.remove(item)
    item = ET.SubElement(ET.SubElement(variants, "variant"), "configItem")
    ET.SubElement(item, "name").text = "czenglish"
    ET.SubElement(item, "description").text = "Czech (czenglish)"
    return xml_bytes(root)


def update_ibus(path):
    root = xml_document(path)
    engines = root.find("engines")
    if root.tag != "component" or root.findtext("name") != "org.freedesktop.IBus.Simple" or engines is None:
        raise ValueError(f"{path}: není očekávaná komponenta IBus Simple")
    fields = {
        "name": ENGINE,
        "language": "cs",
        "layout": "cz",
        "layout_variant": "czenglish",
        "longname": "Czech (czenglish)",
        "description": "Czech (czenglish)",
        "icon": "ibus-keyboard",
        "rank": "1",
    }
    matches = [e for e in engines.findall("engine") if e.findtext("name") == ENGINE]
    if len(matches) == 1 and all(matches[0].findtext(k) == v for k, v in fields.items()):
        return path.read_bytes()
    for item in matches:
        engines.remove(item)
    engine = ET.SubElement(engines, "engine")
    for key, value in fields.items():
        ET.SubElement(engine, key).text = value
    return xml_bytes(root)


def write_with_backup(path, data, stamp):
    # Resolve symlinks so that e.g. base.xml -> evdev.xml stays intact.
    path = path.resolve(strict=True)
    if path.read_bytes() == data:
        print(f"Beze změny: {path}")
        return
    backup = path.with_name(path.name + ".backup." + stamp)
    shutil.copy2(path, backup)
    fd, temporary = tempfile.mkstemp(prefix=".czenglish-", dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as output:
            output.write(data)
        stat = path.stat()
        if os.geteuid() == 0:
            os.chown(temporary, stat.st_uid, stat.st_gid)
        shutil.copystat(path, temporary)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
    print(f"Upraveno: {path}\n  Záloha: {backup}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path("/"),
                        help="kořen připraveného systému pro testování/balení (výchozí /)")
    parser.add_argument("--ibus-component", type=Path,
                        help="nestandardní cesta k IBus simple.xml (uvnitř --root)")
    args = parser.parse_args()
    root = args.root.resolve(strict=True)
    if root == Path("/") and os.geteuid() != 0:
        parser.error("instalaci do systému spusťte přes sudo")

    def target(relative):
        path = root / str(relative).lstrip("/")
        if path.resolve() != root and root not in path.resolve().parents:
            raise ValueError(f"Cesta vede mimo cílový kořen: {path}")
        return path

    symbols = target("usr/share/X11/xkb/symbols/cz")
    rules = target("usr/share/X11/xkb/rules/evdev.xml")
    source = Path(__file__).resolve().with_name("czenglish_layout").read_text()
    old_symbols = symbols.read_text()
    pattern = r'(?ms)^(?:partial[^\n]*\n)?xkb_symbols\s+"czenglish"\s*\{.*?^\};[^\S\n]*\n?'
    remaining = re.sub(pattern, "", old_symbols)
    if 'xkb_symbols "czenglish"' in remaining:
        raise ValueError("Existující blok czenglish nelze bezpečně nahradit")
    new_symbols = remaining.rstrip() + "\n\n" + source.rstrip() + "\n"
    changes = [(symbols, new_symbols.encode()), (rules, update_xkb(rules))]

    # Some distributions use a separate base.xml rather than an evdev.xml symlink.
    base = target("usr/share/X11/xkb/rules/base.xml")
    if base.exists() and base.resolve() != rules.resolve():
        changes.append((base, update_xkb(base)))

    if args.ibus_component:
        components = [target(args.ibus_component)]
    else:
        components = [target(p) for p in (
            "usr/share/ibus/component/simple.xml",
            "usr/local/share/ibus/component/simple.xml",
        ) if target(p).is_file()]
    for component in components:
        changes.append((component, update_ibus(component)))

    # All source files and XML structures have now been checked.
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    for path, data in changes:
        write_with_backup(path, data, stamp)
    if components:
        print(f"IBus: zaregistrován {ENGINE}")
    else:
        print("IBus Simple nenalezen; nainstalováno pouze XKB. Pokud používáte IBus,\n"
              "nainstalujte jej a spusťte skript znovu, nebo zadejte --ibus-component.")
    print("Instalace dokončena. Odhlaste se a znovu přihlaste.\n"
          "V nastavení klávesnice vyberte Czech (czenglish).\n"
          "Po aktualizaci balíčků XKB/IBus může být nutné skript spustit znovu.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, ET.ParseError) as error:
        sys.exit(f"Chyba instalace: {error}")
