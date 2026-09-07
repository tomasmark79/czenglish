"""Integration tests use a temporary filesystem; never modify the host."""
from pathlib import Path
import subprocess
import tempfile
import unittest
import xml.etree.ElementTree as ET

PROJECT = Path(__file__).resolve().parents[1]
RULES = b'''<xkbConfigRegistry><layoutList>
<layout><configItem><name>us</name></configItem><variantList>
<variant><configItem><name>czenglish</name></configItem></variant>
</variantList></layout>
<layout><configItem><name>cz</name></configItem><variantList>
<variant><configItem><name>qwerty</name></configItem></variant>
</variantList></layout></layoutList></xkbConfigRegistry>'''
SIMPLE = b'''<component><name>org.freedesktop.IBus.Simple</name>
<exec>/usr/libexec/ibus-engine-simple</exec><!-- retain me --><engines>
<engine><name>xkb:us::eng</name><layout>us</layout></engine>
</engines></component>'''


class InstallTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.symbols = self.put('usr/share/X11/xkb/symbols/cz',
                                b'partial alphanumeric_keys\nxkb_symbols "basic" {\n key <AD01> { [ q ] };\n};\n')
        self.rules = self.put('usr/share/X11/xkb/rules/evdev.xml', RULES)
        self.ibus = self.put('usr/share/ibus/component/simple.xml', SIMPLE)

    def put(self, name, data):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
        return path

    def run_installer(self, *args, success=True):
        result = subprocess.run(['bash', str(PROJECT / 'install-linux.sh'),
                                 '--root', str(self.root), *args],
                                cwd='/', capture_output=True, text=True)
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)
        return result

    def test_install_and_repeat_preserve_other_layouts_and_backups(self):
        self.symbols.chmod(0o640)
        originals = {p: p.read_bytes() for p in (self.symbols, self.rules, self.ibus)}
        self.run_installer()
        symbols = self.symbols.read_text()
        self.assertIn('xkb_symbols "basic"', symbols)
        self.assertIn((PROJECT / 'czenglish_layout').read_text().strip(), symbols)
        rules = ET.parse(self.rules)
        self.assertEqual(len(rules.findall("./layoutList/layout/configItem[name='cz']/../variantList/variant/configItem[name='czenglish']")), 1)
        self.assertIsNotNone(rules.find("./layoutList/layout/configItem[name='cz']/../variantList/variant/configItem[name='qwerty']"))
        component = ET.parse(self.ibus)
        self.assertEqual(component.findtext('exec'), '/usr/libexec/ibus-engine-simple')
        self.assertIsNotNone(component.find("./engines/engine[name='xkb:us::eng']"))
        engine = component.find("./engines/engine[name='xkb:cz:czenglish:ces']")
        self.assertEqual(engine.findtext('layout_variant'), 'czenglish')
        self.assertEqual(engine.findtext('layout'), 'cz')
        self.assertEqual(engine.findtext('language'), 'cs')
        self.assertIn('<!-- retain me -->', self.ibus.read_text())
        installed = {p: p.read_bytes() for p in originals}
        self.run_installer()
        self.assertEqual(installed, {p: p.read_bytes() for p in originals})
        self.assertEqual(self.symbols.stat().st_mode & 0o777, 0o640)
        for path, original in originals.items():
            backups = list(path.parent.glob(path.name + '.backup.*'))
            self.assertEqual(len(backups), 1)
            self.assertEqual(backups[0].read_bytes(), original)

    def test_without_ibus(self):
        self.ibus.unlink()
        result = self.run_installer()
        self.assertIn('nainstalováno pouze XKB', result.stdout)
        self.assertFalse(self.ibus.exists())

    def test_bad_ibus_xml_changes_nothing(self):
        self.ibus.write_text('<component>')
        originals = {p: p.read_bytes() for p in (self.symbols, self.rules, self.ibus)}
        self.run_installer(success=False)
        self.assertEqual(originals, {p: p.read_bytes() for p in originals})
        self.assertEqual(list(self.root.rglob('*.backup.*')), [])

    def test_explicit_component_and_base_symlink(self):
        custom = self.root / 'opt/ibus/simple.xml'
        custom.parent.mkdir(parents=True)
        self.ibus.rename(custom)
        base = self.rules.with_name('base.xml')
        base.symlink_to('evdev.xml')
        self.run_installer('--ibus-component', '/opt/ibus/simple.xml')
        self.assertTrue(base.is_symlink())
        self.assertIn('xkb:cz:czenglish:ces', custom.read_text())

    def test_separate_base_and_existing_broken_engine(self):
        base = self.put('usr/share/X11/xkb/rules/base.xml', RULES)
        self.ibus.write_bytes(SIMPLE.replace(b'</engines>', b'<engine><name>xkb:cz:czenglish:ces</name><layout>us</layout></engine></engines>'))
        self.run_installer()
        self.assertIn('Czech (czenglish)', base.read_text())
        engines = ET.parse(self.ibus).findall("./engines/engine[name='xkb:cz:czenglish:ces']")
        self.assertEqual(len(engines), 1)
        self.assertEqual(engines[0].findtext('layout'), 'cz')

    def test_staging_cannot_escape_root(self):
        self.ibus.unlink()
        self.ibus.symlink_to('/etc/os-release')
        original = self.symbols.read_bytes()
        self.run_installer(success=False)
        self.assertEqual(self.symbols.read_bytes(), original)


if __name__ == '__main__':
    unittest.main()
