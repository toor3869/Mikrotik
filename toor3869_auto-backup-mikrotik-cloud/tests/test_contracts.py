####################################################################################################
#####                                                                                          #####
#####                                  Mikrotik - Tests locaux                                 #####
#####                                     test_contracts.py                                    #####
#####                             VERSION 2026-09-17 - BY TOOR3869                             #####
#####                                                                                          #####
####################################################################################################

"""Contrats statiques : ces tests ne simulent pas le moteur RouterOS."""
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
NAME = "toor3869_auto-backup-mikrotik-cloud"
TOKEN = "__TOOR3869_PASSWORD__"
INSTALLER = ROOT / (NAME + ".install.rsc")


def decode_ros(value):
    """Decodage du sous-ensemble utilise dans nos chaines de transport."""
    result = []
    i = 0
    mapping = {"r": "\r", "n": "\n", '"': '"', "\\": "\\", "$": "$"}
    while i < len(value):
        char = value[i]
        if char != "\\":
            result.append(char)
            i += 1
            continue
        i += 1
        if value[i] in mapping:
            result.append(mapping[value[i]])
            i += 1
        elif re.fullmatch(r"[0-9A-F]{2}", value[i:i + 2]):
            result.append(chr(int(value[i:i + 2], 16)))
            i += 2
        else:
            raise AssertionError("Echappement non reconnu")
    return "".join(result)


def escaped(value):
    return value.replace("\\", "\\\\").replace('"', '\\"').replace("$", "\\$")


def balanced(text):
    """Controle lexical seulement : ne prouve pas la syntaxe RouterOS."""
    stack = []
    quote = comment = False
    i = 0
    pairs = {")": "(", "]": "[", "}": "{"}
    while i < len(text):
        char = text[i]
        if comment:
            if char == "\n":
                comment = False
        elif quote:
            if char == "\\":
                i += 1
            elif char == '"':
                quote = False
        elif char == "#":
            comment = True
        elif char == '"':
            quote = True
        elif char in "([{":
            stack.append(char)
        elif char in ")]}":
            assert stack and stack.pop() == pairs[char], "Delimiteurs incoherents"
        i += 1
    assert not quote and not stack, "Chaine ou bloc non ferme"


class Contracts(unittest.TestCase):
    def setUp(self):
        self.installer = INSTALLER.read_text()
        pattern = r'^    :local runtimeSource \( \\\n(.*?)^    \);$'
        matches = re.findall(pattern, self.installer, re.M | re.S)
        self.assertEqual(len(matches), 1)
        chunks = re.findall(r'^        "(.*)"(?: \.)? \\$', matches[0], re.M)
        self.assertEqual(len(chunks), len(matches[0].splitlines()))
        self.source = decode_ros("".join(chunks)).replace("\r\n", "\n")
        self.code = re.sub(pattern, '', self.installer, flags=re.M | re.S)

    def test_banners_encoding_and_footer(self):
        for name, data in ((NAME + ".rsc", self.source.encode()),
                           (INSTALLER.name, INSTALLER.read_bytes())):
            self.assertTrue(data.isascii())
            self.assertNotIn(b"\r", data)
            lines = data.decode().split("\n")
            self.assertEqual(lines[:8], [
                "#" * 100, "#####", "##### Mikrotik Script",
                "##### " + name, "##### VERSION 2026-09-17 - BY TOOR3869",
                "#####", "#" * 100, "",
            ])
            self.assertTrue(lines[8])
            self.assertTrue(data.endswith(("\n\n" + "#" * 100 + "\n\n").encode()))
            self.assertFalse(data.endswith(b"\n\n\n"))
            self.assertFalse(any(line.rstrip() != line for line in lines))

    def test_embedded_source_is_single_authority(self):
        self.assertFalse((ROOT / (NAME + ".rsc")).exists())
        self.assertEqual(self.source.count(TOKEN), 1)
        self.assertIn(':local scriptName "' + NAME + '.rsc";', self.source)

    def test_identical_script_and_scheduler_comments(self):
        comment = "TOOR3869 -> Sauvegarde automatique chiffree vers MikroTik Cloud"
        self.assertIn(':local scriptComment "' + comment + '";', self.installer)
        self.assertIn(':local schedulerComment "' + comment + '";', self.installer)
        for kind, variable, identifier in (("script", "scriptComment", "scriptId"),
                                            ("scheduler", "schedulerComment", "scheduleId")):
            block = self.installer.split('/system ' + kind + ' add \\\n', 1)[1].split(';', 1)[0]
            self.assertIn('comment=$' + variable, block)
            self.assertIn('get $' + identifier + ' comment] != $' + variable, self.installer)
        self.assertNotIn('$marker', self.installer)

    def test_lexical_balance(self):
        balanced(self.source)
        balanced(self.installer)

    def test_password_round_trip(self):
        # Jeu fictif : jamais de mot de passe reel dans les tests.
        for password in ['Demo12345', ' a"b\\c$d ', "".join(map(chr, range(32, 127)))]:
            self.assertEqual(decode_ros(escaped(password)), password)
            injected = self.source.replace(TOKEN, escaped(password))
            balanced(injected)

    def test_input_alphabet(self):
        matches = re.findall(r':local alphabet "(.*)";', self.installer)
        self.assertEqual(len(matches), 1)
        self.assertEqual(decode_ros(matches[0]), "".join(map(chr, range(32, 127))))
        for guard in ("timeout=2m", "$key = 27", "$key = 8", "$key = 127",
                      "[:len $value] >= 128", "[:len $value] < 8"):
            self.assertIn(guard, self.installer)
        self.assertNotRegex(self.installer, r':(?:put|log)[^\n]*\$(?:password|confirmation)')

    def test_exact_identities_and_no_site_configuration(self):
        self.assertIn(':local scriptName "' + NAME + '.rsc";', self.installer)
        self.assertIn(':local schedulerName "' + NAME + '";', self.installer)
        for text in (self.source, self.installer):
            self.assertNotIn("raidingue.fr", text)
            self.assertNotIn("CPE01", text)
            self.assertNotIn("/tool e-mail", text)
            self.assertNotIn("dont-require-permissions=yes", text)

    def test_fail_closed_and_order(self):
        # On analyse le code de l'installateur, pas sa longue source embarquee.
        code = self.code
        first = code.index(':set stage "verification premiere sauvegarde"')
        script = code.index(':set stage "installation script"')
        scheduler = code.index(':set stage "installation scheduler desactive"')
        run = code.index('/system script run $scriptName;')
        enable = code.index('/system scheduler enable $scheduleId;')
        self.assertLess(first, script)
        self.assertLess(script, scheduler)
        self.assertLess(scheduler, run)
        self.assertLess(run, enable)
        self.assertIn("disabled=yes", code[scheduler:run])
        self.assertIn('/system scheduler disable $scheduleId', code[enable:])
        self.assertIn('[/system backup cloud get $current date] = $previousDate', self.source)
        self.assertIn("job print count-only", self.source)

    def test_cloud_creation_and_deletion_guards(self):
        code = self.code
        self.assertEqual(code.count("/system backup cloud remove-file"), 1)
        deletion = code.index("/system backup cloud remove-file")
        self.assertIn('($mode = "3") && ([:len $backups] = 1)', code[deletion - 130:deletion])
        self.assertIn(':set required "EFFACER"', code[:deletion])
        self.assertIn('Confirmer avec ', code[:deletion])
        create = code.split(':if ([:len $backups] = 0) do={', 1)[1].split('} else={', 1)[0]
        self.assertNotIn("replace=", create)
        self.assertNotIn("remove-file", self.source)
        self.assertIn("replace=$backupName", self.source)

    def test_planning_mode_no_cloud_or_secret_changes(self):
        code = self.code
        planning = code.split(':if ($mode = "2") do={', 1)[1].split('} else={', 1)[0]
        self.assertNotIn("/system backup", planning)
        self.assertNotIn("source=", planning)
        self.assertIn('($mode != "2") || ($wasDisabled = false)', code)

    def test_cleanup_requires_validated_runtime_and_active_scheduler(self):
        code = self.code
        validated = code.index(':set runtimeValidated true;')
        self.assertLess(code.index('/system script run $scriptName;'), validated)
        self.assertLess(validated, code.index('/system scheduler enable $scheduleId;'))
        gate = code.index(':if (($failed = false) && ($runtimeValidated = true))')
        self.assertLess(code.index(':error "Installation non validee";'), gate)
        cleanup = code[gate:]
        self.assertLess(cleanup.index('get $scheduleId disabled'), cleanup.index('/file remove'))
        self.assertNotIn('/system scheduler disable', cleanup)
        self.assertIn('AVERTISSEMENT', cleanup)

    def test_cleanup_targets_only_canonical_installer(self):
        code = self.code
        self.assertIn(':local installerFile "' + NAME + '.install.rsc";', code)
        self.assertEqual(code.count('/file remove'), 1)
        self.assertIn('[/file find where name=$installerFile]', code)
        self.assertIn(':if ([:len $installerIds] = 1) do={', code)
        self.assertIn('/file remove ($installerIds->0);', code)
        self.assertIn('[:len [/file find where name=$installerFile]] != 0', code)
        readme = (ROOT / 'README.md').read_text()
        self.assertIn('dst-path="' + NAME + '.install.rsc"', readme)
        self.assertNotIn('toor3869_cloud_install.rsc', readme)


if __name__ == "__main__":
    unittest.main()
