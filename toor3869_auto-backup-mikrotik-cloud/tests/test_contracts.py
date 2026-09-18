####################################################################################################
#####                                                                                          #####
#####                                  Mikrotik - Tests locaux                                 #####
#####                                     test_contracts.py                                    #####
#####                             VERSION 2026-09-18 - BY TOOR3869                             #####
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
        self.colored_installer = INSTALLER.read_text()
        # Les contrats fonctionnels lisent le meme texte, sans son habillage ANSI.
        self.installer = re.sub(r'\\1B\[(?:0|31|32|33|36)m', '', self.colored_installer)
        self.installer = re.sub(r':put \("" \. (\([^\n]+\)) \. ""\);',
                                r':put \1;', self.installer)
        # Les contrats fonctionnels ignorent le double espacement visuel.
        self.installer = re.sub(r'(?m)^( *:put "";\n)\1', r'\1', self.installer)
        # Le cadre des sous-titres est teste separement sur le texte brut.
        self.installer = re.sub(r'(?m)^ *:put "-+";\n', '', self.installer)
        pattern = r'^    :local runtimeSource \( \\\n(.*?)^    \);$'
        matches = re.findall(pattern, self.installer, re.M | re.S)
        self.assertEqual(len(matches), 1)
        chunks = re.findall(r'^        "(.*)"(?: \.)? \\$', matches[0], re.M)
        self.assertEqual(len(chunks), len(matches[0].splitlines()))
        self.source = decode_ros("".join(chunks)).replace("\r\n", "\n")
        self.code = re.sub(pattern, '', self.installer, flags=re.M | re.S)
        start = self.code.index('    # Parcours de desinstallation independant')
        end = self.code.index('    # Fin du parcours de desinstallation.')
        self.uninstall = self.code[start:end]
        self.code = self.code[:start] + self.code[end:]
        self.cleanup = self.code.split(':local cleanupInstaller do={', 1)[1].split(
            '\n    :put "";\n    :put "' + '#' * 100, 1)[0]

    def test_banners_encoding_and_footer(self):
        for name, data in ((NAME + ".rsc", self.source.encode()),
                           (INSTALLER.name, INSTALLER.read_bytes())):
            self.assertTrue(data.isascii())
            self.assertNotIn(b"\r", data)
            lines = data.decode().split("\n")
            self.assertEqual(lines[:8], [
                "#" * 100, "#####", "##### Mikrotik Script",
                "##### " + name, "##### VERSION " + "2026-09-18" + " - BY TOOR3869",
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

    def test_console_start_banner_before_menu(self):
        texts = ["", "Installation - Sauvegarde automatique MikroTik Cloud",
                 INSTALLER.name, "VERSION 2026-09-18 - BY TOOR3869", ""]
        interior = ["#####" + " " * ((90 - len(text) + 1) // 2) + text
                    + " " * ((90 - len(text)) // 2) + "#####" for text in texts]
        self.assertTrue(all(len(line) == 100 for line in interior))
        lines = ["", "#" * 100, *interior, "#" * 100, ""]
        banner = "\n".join('    :put "' + line + '";' for line in lines)
        self.assertEqual(self.code.count(banner), 1)
        self.assertLess(self.code.index(banner), self.code.index(':local mode '))

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

    def test_console_menu_exact_text(self):
        lines = ["----- Choix de l'operation -----", "",
                 "1 - Installer ou mettre a jour la sauvegarde automatique sur le cloud MikroTik",
                 "2 - Modifier les horaires et l'intervalle de sauvegarde",
                 "3 - Changer le mot de passe de la sauvegarde",
                 "9 - Desinstaller la sauvegarde automatique et nettoyer",
                 "0 - Quitter sans modification", ""]
        menu = "\n".join('    :put "' + line + '";' for line in lines)
        menu += '\n    :local mode [/terminal ask prompt="Votre choix [0] : "];'
        self.assertEqual(self.code.count(menu), 1)

    def test_lexical_balance(self):
        balanced(self.source)
        balanced(self.installer)
        balanced(self.colored_installer)

    def test_console_colors_reset_on_each_message(self):
        colored = [line for line in self.colored_installer.splitlines() if r'\1B[' in line]
        self.assertGreater(len(colored), 50)
        for line in colored:
            self.assertIn(':put ', line)
            self.assertEqual(re.findall(r'\\1B\[(\d+)m', line)[-1], '0')
            self.assertEqual(len(re.findall(r'\\1B\[0m', line)), 1)
            self.assertNotIn('/terminal ask', line)
            self.assertNotIn('$password', line)
            self.assertNotIn('$confirmation', line)
        self.assertNotIn('\\1B[', self.source)
        self.assertNotIn('\x1b', self.colored_installer)

    def test_console_palette_semantics(self):
        for label, variable in (("Heure de depart  : ", "summaryStartTime"),
                                ("Intervalle       : ", "summaryInterval")):
            self.assertIn(':put ("\\1B[32m" . ("' + label + '" . $' + variable
                          + ') . "\\1B[0m");', self.colored_installer)
        examples = {
            '36': '----- Choix de l\'operation -----',
            '32': 'Test termine avec succes.',
            '33': 'Aucune sauvegarde Cloud ne sera conservee.',
            '31': '----- Echec de l\'operation -----',
        }
        for color, message in examples.items():
            self.assertIn(':put "\\1B[' + color + 'm' + message + '\\1B[0m";',
                          self.colored_installer)
        self.assertIn(':put "Recherche des elements deja presents sur ce MikroTik";',
                      self.colored_installer)

    def test_silent_counts_and_normal_import_completion(self):
        self.assertNotIn('print count-only', self.installer)
        self.assertNotIn(':return 0;', self.installer)
        self.assertEqual(self.source.count('[:len [/system script job find where script=$scriptName]]'), 1)
        self.assertEqual(self.code.count('[:len [/system script job find where script=$scriptName]]'), 2)
        self.assertEqual(self.uninstall.count('[:len [/system script job find where script=$scriptName]]'), 4)
        self.assertIn(':put "Aucune modification.";\n    } else={', self.code)
        self.assertIn('} else={\n                # Fin du parcours de desinstallation.', self.installer)

    def test_uninstall_confirmation_and_ownership(self):
        code = self.uninstall
        confirm = code.index('prompt="Confirmer avec OUI : "] != "OUI"')
        disable = code.index('/system scheduler disable')
        self.assertLess(confirm, disable)
        for guard in ('comment] != $scriptComment', 'comment] != $schedulerComment',
                      'on-event] != $event', 'name] != $backupName',
                      '/system script job find'):
            self.assertIn(guard, code[:confirm])
        self.assertIn('Desinstallation annulee. Aucune modification.', code[confirm:disable])
        self.assertIn('} else={', code[confirm:disable])
        self.assertNotIn(':return 0;', code)
        self.assertNotIn('/system script job remove', code)
        self.assertNotIn('upload-file', code)
        self.assertNotIn('/system scheduler enable', code)

    def test_uninstall_order_verification_and_retry(self):
        code = self.uninstall
        commands = ['/system scheduler disable', '/system backup cloud remove-file',
                    '/system scheduler remove', '/system script remove', '$cleanupInstaller $installerFile']
        positions = [code.index(command) for command in commands]
        self.assertEqual(positions, sorted(positions))
        self.assertIn('/system script job find', code[positions[0]:positions[1]])
        self.assertIn('name] != $backupName', code[positions[0]:positions[1]])
        for message, start, end in [('Suppression Cloud non confirmee', positions[1], positions[2]),
                                     ('Suppression scheduler non confirmee', positions[2], positions[3]),
                                     ('Suppression script non confirmee', positions[3], positions[4])]:
            self.assertIn(message, code[start:end])
        self.assertIn('($cleanupDone = false) && ($cleanupAttempt < 2)', self.cleanup)
        self.assertIn('[/file find where name=$installerFile]', self.cleanup)
        self.assertLess(code.index(':if ($cleaned = false)'),
                        code.index('----- Desinstallation terminee -----'))
        self.assertIn('Les suppressions deja effectuees ne sont pas annulees.', code)
        self.assertIn(':set toor3869CloudInstallerLock false;', code[positions[4]:])

    def test_uninstall_success_frame(self):
        code = self.uninstall
        start = code.index(':if ($cleaned = false) do={ :error "Nettoyage incomplet"; };')
        end = code.index('} on-error={', start)
        lines = ['', '#' * 100, '', '----- Desinstallation terminee -----', '',
                 "Script, scheduler, sauvegarde Cloud et fichier d'installation supprimes.",
                 '', '#' * 100, '']
        self.assertEqual(re.findall(r':put "(.*)";', code[start:end]), lines)

    def test_cloud_deletion_diagnostics(self):
        code = self.uninstall
        self.assertIn(':if ([:onerror cloudError in={', code)
        self.assertEqual(code.count('/system backup cloud remove-file number=($backups->0);'), 1)
        self.assertNotIn('remove-file number=0', self.installer)
        self.assertEqual(self.installer.count('remove-file number=($backups->0);'), 2)
        self.assertIn('commande de suppression Cloud', code)
        self.assertIn('verification apres suppression Cloud', code)
        self.assertIn('$cloudChecks < 10', code)
        self.assertIn(':delay 1s;', code)
        self.assertNotRegex(code, r':(?:put|log)[^\n]*\$cloudError')
        self.assertIn('\\1B[33m- La sauvegarde presente sur le cloud MikroTik.\\1B[0m',
                      self.colored_installer)

    def test_password_warning_paragraphs_have_uniform_color(self):
        for message in (
            'Ce mot de passe protege votre sauvegarde chiffree.',
            'Conservez-le : il sera necessaire pour la restaurer.',
            'Il sera enregistre en clair dans le script installe sur ce MikroTik.',
            'Vous pourrez le retrouver dans la variable backupPassword.',
            'Les utilisateurs autorises a lire le script pourront aussi le consulter.',
        ):
            self.assertIn(':put "\\1B[33m' + message + '\\1B[0m";', self.colored_installer)

    def test_console_double_spacing(self):
        lines = self.colored_installer.splitlines()
        for index, line in enumerate(lines):
            if ':put "' in line and '----- ' in line:
                match = re.search(r'(\\1B\[(?:31|33|36)m)(----- .* -----)\\1B\[0m', line)
                self.assertIsNotNone(match)
                border = ':put "' + match[1] + '-' * len(match[2]) + '\\1B[0m";'
                self.assertEqual(lines[index - 1].strip(), border)
                self.assertEqual(lines[index + 1].strip(), border)
                self.assertEqual(lines[index - 2].strip(), ':put "";')
                if 'terminee -----' not in line:
                    self.assertEqual(lines[index - 3].strip(), ':put "";')
                else:
                    self.assertIn('#' * 100, lines[index - 3])
                self.assertEqual(lines[index + 2].strip(), ':put "";')
                self.assertNotEqual(lines[index + 3].strip(), ':put "";')

    def test_uninstall_spacing_after_confirmation_and_cloud(self):
        self.assertIn('} else={\n                        :put "";\n'
                      '                        :set uninstallStage "desactivation scheduler";',
                      self.colored_installer)
        self.assertIn('remove-file number=($backups->0);\n                                :put "";',
                      self.colored_installer)

    def test_installation_spacing_without_accumulation(self):
        self.assertIn(':put ("Sauvegarde sur le cloud   : " . $backupState);\n'
                      '                        :local scriptId;', self.installer)
        self.assertNotIn(':put "";\n                            };\n'
                         '                            :local timeValue', self.installer)
        self.assertIn(':put "";\n                                :set stage '
                      '"verification premiere sauvegarde";', self.installer)
        self.assertIn('/system script run $scriptName;\n                            :put "";',
                      self.installer)

    def test_planning_independent_retry_loops(self):
        code = self.code
        hour = code.index(':while ($hourAccepted = false)')
        interval = code.index(':while ($intervalAccepted = false)')
        end = code.index(':local timeValue ')
        self.assertLess(hour, interval)
        self.assertLess(end, code.index(':set stage "confirmation"'))
        self.assertIn('Heure de depart [', code[hour:interval])
        self.assertIn('Heure invalide.', code[hour:interval])
        self.assertIn('[:len $candidate] = 8', code[hour:interval])
        self.assertIn('^[0-2][0-9]:[0-5][0-9]:[0-5][0-9]', code[hour:interval])
        self.assertIn('($parsedTime >= 0s) && ($parsedTime < 1d)', code[hour:interval])
        self.assertIn('on-error={ :set hourAccepted false; }', code[hour:interval])
        self.assertIn('Intervalle entre les sauvegardes [', code[interval:end])
        self.assertIn('Intervalle invalide.', code[interval:end])
        self.assertIn('($parsedInterval > 0s) && ($parsedInterval <= 1d)', code[interval:end])
        self.assertIn('on-error={ :set intervalAccepted false; }', code[interval:end])
        self.assertNotIn(':set startTime', code[interval:end])
        self.assertIn(':set candidate $startTime', code[hour:interval])
        self.assertIn(':set candidate $interval', code[interval:end])
        self.assertIn('($intervalValue > 1d)', code[end:])

    def test_inventory_presentation_and_states(self):
        code = self.code
        title = ':put "----- Verification de l\'installation -----";'
        description = ':put "Recherche des elements deja presents sur ce MikroTik";'
        self.assertIn(title, code)
        self.assertIn(description, code)
        self.assertLess(code.index(title), code.index(':local scripts '))
        labels = ("Script sur le Mikrotik    : ", "Scheduler sur le Mikrotik : ",
                  "Sauvegarde sur le cloud   : ")
        for label, variable, absent in zip(labels, ("scriptState", "schedulerState", "backupState"),
                                            ("absent", "absent", "absente")):
            self.assertEqual(label.index(':'), 26)
            self.assertIn(':put ("' + label + '" . $' + variable + ');', code)
            self.assertIn(':local ' + variable + ' "' + absent + '";', code)
        self.assertIn(':set scriptState "present"', code)
        self.assertIn(':set backupState "presente"', code)
        self.assertIn(':set schedulerState "present (actif)"', code)
        self.assertIn(':set schedulerState "present (desactive)"', code)
        self.assertLess(code.index(':error "Etat ambigu"'), code.index(':local scriptState '))

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
        for guard in ("timeout=1m", "$key = 3", "$key = 8", "$key = 127",
                      "[:len $value] >= 128", "[:len $value] < 8"):
            self.assertIn(guard, self.installer)
        self.assertNotRegex(self.installer, r':(?:put|log)[^\n]*\$(?:password|confirmation)')

    def test_password_retry_and_cancellation(self):
        reader = self.code.split(':local readPassword do={', 1)[1].split(':local encodePassword', 1)[0]
        self.assertIn(':while (true)', reader)
        self.assertIn(':while ($submitted = false)', reader)
        self.assertIn(':set invalid true;', reader)
        self.assertIn(':return "";', reader)
        self.assertNotIn('on-error', reader)
        self.assertIn(':put $1;', reader)
        self.assertNotIn(':put $value', reader)
        self.assertIn(':put "Mot de passe trop court.', reader)
        self.assertLess(reader.index(':set submitted true;'), reader.index(':if ($invalid)'))
        pair = self.code.split(':while ($passwordsMatch = false)', 1)[1].split(':local token', 1)[0]
        self.assertIn('$readPassword "Saisissez votre mot de passe :"', pair)
        self.assertIn('$readPassword "Confirmez votre mot de passe :"', pair)
        self.assertIn(':if ($password = $confirmation)', pair)
        self.assertIn(':set passwordsMatch true;', pair)
        self.assertIn(':set password "";', pair)
        self.assertIn(':set confirmation "";', pair)
        self.assertIn('Les mots de passe ne correspondent pas. Recommencez la saisie.', pair)
        self.assertNotIn('on-error', pair)
        self.assertNotIn('saisie planning', pair)
        self.assertNotIn('/system', pair)

    def test_non_ascii_input_does_not_cancel_or_leak_paste_to_menu(self):
        reader = self.code.split(':local readPassword do={', 1)[1].split(':local encodePassword', 1)[0]
        self.assertIn(':local waitStarted [/system resource get uptime];', reader)
        self.assertIn(':if (([/system resource get uptime] - $waitStarted) >= 1m) do={', reader)
        self.assertIn(':set key -2;', reader)
        self.assertNotIn('$key = 27', reader)
        invalid = reader.split(':if (($key < 32) || ($key > 126)) do={', 1)[1].split('} else={', 1)[0]
        self.assertIn(':set invalid true;', invalid)
        self.assertNotIn(':return', invalid)
        self.assertNotIn(':set submitted true', invalid)
        # L'indicateur reste pose jusqu'a la soumission, meme apres Retour arriere.
        self.assertEqual(reader.count(':set invalid false;'), 0)
        self.assertIn('($value = "0") && ($invalid = false)', reader)

    def test_password_timeout_checked_before_key_classification(self):
        reader = self.code.split(':local readPassword do={', 1)[1].split(':local encodePassword', 1)[0]
        wait = reader.index(':local key [/terminal inkey timeout=1m];')
        elapsed = reader.index(':if (([/system resource get uptime] - $waitStarted) >= 1m)')
        classify = reader.index(':if (([:typeof $key] != "num") || ($key < 0))')
        self.assertLess(wait, elapsed)
        self.assertLess(elapsed, classify)
        expiry = reader[elapsed:classify]
        self.assertIn(':set value "";', expiry)
        self.assertIn(':return "";', expiry)
        self.assertIn('Saisie expiree apres une minute sans touche.', expiry)
        self.assertNotIn('$key', expiry)

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
        self.assertIn("job find", self.source)

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

    def test_confirmation_only_when_existing_backup_is_replaced_or_deleted(self):
        block = self.code.split(':set stage "confirmation";', 1)[1].split(
            ':set stage "mise en securite scheduler";', 1)[0]
        self.assertIn(':local required "";', block)
        self.assertNotIn('"OUI"', block)
        self.assertIn('($mode = "3") && ([:len $backups] = 1)', block)
        self.assertIn('($mode = "1") && ([:len $backups] = 1)', block)
        self.assertIn(':set required "EFFACER";', block)
        self.assertIn(':set required "REMPLACER";', block)
        gate = block.split(':if ($required != "") do={', 1)[1]
        self.assertIn('/terminal ask prompt=', gate)
        self.assertIn(':error "Operation annulee";', gate)

    def test_first_backup_progress_and_verified_success(self):
        code = self.code
        start = code.index(':local firstBackup ([:len $backups] = 0);')
        title = code.index(':put "----- Premiere sauvegarde Cloud -----";')
        upload = code.index('/system backup cloud upload-file')
        checked = code.index(':set stage "verification premiere sauvegarde";')
        success = code.index(':put "Sauvegarde Cloud creee et verifiee.";')
        self.assertLess(start, title)
        self.assertLess(title, upload)
        self.assertLess(upload, checked)
        self.assertLess(checked, success)
        self.assertIn(':if ($firstBackup) do={', code[start:title])
        self.assertIn(':error "Sauvegarde non confirmee";', code[checked:success])
        self.assertIn('Cette operation peut prendre plusieurs minutes. Merci de patienter.', code)

    def test_automation_installation_messages(self):
        code = self.code
        title = code.index(':put "----- Installation de l\'automatisation -----";')
        script = code.index(':put "Creation du script.";')
        scheduler = code.index(':put "Creation du scheduler.";')
        self.assertLess(code.index(':put "Sauvegarde Cloud creee et verifiee.";'), title)
        self.assertLess(title, script)
        self.assertLess(script, code.index('/system script add'))
        self.assertLess(code.index('/system script add'), scheduler)
        self.assertLess(scheduler, code.index('/system scheduler add'))

    def test_runtime_test_progress_and_success_order(self):
        code = self.code
        lines = ["", "----- Test du script de sauvegarde -----", "",
                 "Execution du script pour verifier son fonctionnement.",
                 "Cette operation peut prendre plusieurs minutes. Merci de patienter.", ""]
        block = "\n".join('                            :put "' + line + '";' for line in lines)
        self.assertIn(block, code)
        run = code.index('/system script run $scriptName;')
        validated = code.index(':set runtimeValidated true;')
        success = code.index(':put "Test termine avec succes.";')
        self.assertLess(code.index(block), run)
        self.assertLess(run, validated)
        self.assertLess(validated, success)
        self.assertLess(success, code.index(':set stage "activation scheduler";'))

    def test_activation_message_after_verified_enable(self):
        block = self.code.split(':set stage "activation scheduler";', 1)[1]
        title = block.index(':put "----- Activation de la sauvegarde automatique -----";')
        action = block.index(':put "Activation du scheduler.";')
        enable = block.index('/system scheduler enable $scheduleId;')
        check = block.index(':error "Activation non confirmee";')
        success = block.index(':put "Sauvegarde automatique en service.";')
        self.assertLess(title, action)
        self.assertLess(action, enable)
        self.assertLess(enable, check)
        self.assertLess(check, success)
        self.assertLess(success, block.index(':put "Planning modifie.'))
        self.assertIn('($mode != "2") || ($wasDisabled = false)', block[:title])

    def test_planning_mode_no_cloud_or_secret_changes(self):
        code = self.code
        planning = code.split(':if ($mode = "2") do={', 1)[1].split('} else={', 1)[0]
        self.assertNotIn("/system backup", planning)
        self.assertNotIn("source=", planning)
        self.assertIn('($mode != "2") || ($wasDisabled = false)', code)

    def test_interrupted_exit_proposes_shared_uninstall_without_default_deletion(self):
        code = self.code
        start = code.index(':put "----- Installation interrompue -----";')
        end = code.index('# Nettoyage uniquement apres test reel', start)
        proposal = code[start:end]
        self.assertIn('0 - Quitter en conservant les elements existants', proposal)
        self.assertIn('9 - Desinstaller et nettoyer, sauvegarde Cloud comprise', proposal)
        self.assertIn(':local exitChoice "";', proposal)
        self.assertIn(':set exitChoice [/terminal ask prompt="Votre choix [0] : "];', proposal)
        self.assertIn('($exitChoice = "") || ($exitChoice = "0") || ($exitChoice = "9")', proposal)
        self.assertIn('on-error={ :set exitChoice ""; }', proposal)
        gate = proposal.index(':if ($exitChoice = "9")')
        self.assertIn(':set mode "9";', proposal[gate:])
        self.assertIn(':set dispatchAgain true;', proposal[gate:])
        self.assertNotIn('/file remove', proposal)
        self.assertNotIn('/system backup cloud remove-file', proposal)
        self.assertEqual(self.uninstall.count('prompt="Confirmer avec OUI : "'), 1)
        self.assertLess(self.installer.index(':while ($dispatchAgain)'),
                        self.installer.index(':if ($mode = "9")'))

    def test_cleanup_requires_validated_runtime_and_active_scheduler(self):
        code = self.code
        validated = code.index(':set runtimeValidated true;')
        self.assertLess(code.index('/system script run $scriptName;'), validated)
        self.assertLess(validated, code.index('/system scheduler enable $scheduleId;'))
        gate = code.index(':if (($failed = false) && ($runtimeValidated = true))')
        self.assertGreater(code.index(':set toor3869CloudInstallerLock false;'), gate)
        cleanup = code[gate:]
        self.assertLess(cleanup.index('get $scheduleId disabled'), cleanup.index('$cleanupInstaller'))
        self.assertNotIn('/system scheduler disable', cleanup)
        self.assertIn('----- Nettoyage incomplet -----', cleanup)

    def test_retry_reinventories_and_retains_inputs(self):
        code = self.code
        loop = code.index(':while ($retry) do={')
        self.assertLess(loop, code.index(':local scripts [/system script find'))
        self.assertLess(code.index(':local installedSource "";'), loop)
        self.assertEqual(code.count(':if ($inputsReady = false) do={'), 2)
        self.assertIn(':if ($initialStateKnown = false) do={', code)
        failure = code[code.index(':if ($failed) do={'):]
        self.assertIn(':local owned [/system scheduler find where name=$schedulerName]', failure)
        self.assertLess(failure.index('get $scheduleId comment'), failure.index('/system scheduler disable'))
        self.assertLess(failure.index('get $scheduleId on-event'), failure.index('/system scheduler disable'))
        self.assertIn('get $scheduleId disabled', failure)
        self.assertIn(':local answer [/terminal ask prompt="Votre choix [Entree] : "];', failure)
        self.assertIn(':if ($answer = "0") do={ :set answered true; }', failure)
        self.assertIn(':set retry true;', failure)
        self.assertNotIn('/system backup cloud remove-file', failure)
        self.assertLess(failure.index(':set retry true;'), failure.index(':set password "";'))

    def test_retry_cloud_checkpoint_and_job_safety(self):
        code = self.code
        checkpoint = code[code.index(':local cloudReady false;'):code.index(':set stage "confirmation";')]
        for field in ['name', 'status', 'date', 'size']:
            self.assertIn('get $saved ' + field, checkpoint)
        self.assertIn('= $cloudDate', checkpoint)
        self.assertIn('= $cloudSize', checkpoint)
        cloud = code[code.index(':set stage "preparation sauvegarde Cloud";'):code.index(':set stage "installation script";')]
        self.assertLess(cloud.index(':if ($cloudReady = false)'), cloud.index('/system backup cloud remove-file'))
        self.assertLess(cloud.index(':error "Sauvegarde non confirmee"'), cloud.index(':set cloudDate'))
        self.assertIn('conservation pour cette reprise', cloud)
        safety = code[code.index(':set stage "mise en securite scheduler";'):code.index(':if ($mode = "2") do={')]
        self.assertEqual(safety.count('/system script job find'), 2)
        self.assertLess(safety.index('/system script job'), safety.index('/system scheduler disable'))
        self.assertLess(safety.index('/system scheduler disable'), safety.rindex('/system script job'))

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

    def test_cleanup_short_presentation(self):
        code = self.code
        title = code.index(':put "----- Nettoyage de l\'installation -----";')
        message = code.index(':put "Suppression du fichier d\'installation.";')
        remove = code.index('/file remove ($installerIds->0);')
        self.assertLess(code.index(':if ([:len $installerIds] = 1) do={'), title)
        self.assertLess(title, message)
        self.assertLess(message, remove)
        self.assertNotIn("Fichier d'installation supprime. Script et scheduler conserves.", code)
        self.assertIn('Suppression non confirmee', code[remove:])
        self.assertIn('----- Nettoyage incomplet -----', code[remove:])

    def test_cleanup_retries_once_without_restarting_backup(self):
        cleanup = self.cleanup
        loop = cleanup
        self.assertIn('($cleanupDone = false) && ($cleanupAttempt < 2)', loop)
        self.assertIn(':set cleanupAttempt ($cleanupAttempt + 1);', loop)
        self.assertLess(loop.index(':while'), loop.index('/file find where name=$installerFile'))
        self.assertLess(loop.index('/file remove'), loop.index(':set cleanupDone true;'))
        self.assertIn(':if ($cleanupAttempt < 2)', loop)
        self.assertNotIn('/system script run', cleanup)
        self.assertNotIn('/system backup cloud', cleanup)
        self.assertNotRegex(cleanup, r'/system scheduler (?:set|enable|disable|remove)')
        self.assertIn(':return $cleanupDone;', cleanup)
        self.assertLess(self.code.index('Nettoyage non confirme apres deux essais'),
                        self.code.index('----- Nettoyage incomplet -----'))

    def test_cleanup_is_shared_and_confined(self):
        self.assertEqual(self.installer.count('/file remove'), 1)
        self.assertEqual(self.installer.count('[$cleanupInstaller $installerFile]'), 2)
        self.assertIn(':local installerFile $1;', self.cleanup)
        self.assertIn('$installerFile != "' + NAME + '.install.rsc"', self.cleanup)
        self.assertLess(self.cleanup.index(':return false;'), self.cleanup.index('/file find'))
        self.assertNotIn('/system', self.cleanup)

    def test_lock_spans_dispatch_interruption_and_cleanup(self):
        code = self.code
        acquired = code.index(':set toor3869CloudInstallerLock true;')
        released = code.index(':set toor3869CloudInstallerLock false;')
        self.assertEqual(code.count(':set toor3869CloudInstallerLock true;'), 1)
        self.assertEqual(code.count(':set toor3869CloudInstallerLock false;'), 1)
        self.assertLess(acquired, code.index(':while ($dispatchAgain)'))
        self.assertGreater(released, code.index('----- Installation interrompue -----'))
        self.assertGreater(released, code.index('----- Nettoyage incomplet -----'))
        self.assertGreater(released, code.index(':local cleanupDone [$cleanupInstaller'))

    def test_cancelled_password_bypasses_failure_retry_prompt(self):
        code = self.code
        pair = code.split(':while ($passwordsMatch = false)', 1)[1].split(':local token', 1)[0]
        self.assertEqual(pair.count(':set cancelled true;'), 2)
        self.assertLess(pair.index(':if ($password = "")'), pair.index(':local confirmation'))
        self.assertLess(pair.index(':if ($confirmation = "")'), pair.index(':if ($password = $confirmation)'))
        failure = code.split(':if ($failed) do={', 1)[1].split(':set password "";', 1)[0]
        self.assertEqual(failure.count(':if ($cancelled = false) do={'), 2)
        self.assertLess(failure.index(':if ($cancelled = false)'), failure.index('----- Echec'))
        self.assertLess(failure.rindex(':if ($cancelled = false)'),
                        failure.index('Entree : nouvelle tentative.'))

    def test_uninstall_revalidates_after_prompt_and_before_removal(self):
        code = self.uninstall
        post = code.split(':set uninstallStage "desactivation scheduler";', 1)[1]
        before_disable = post.split('/system scheduler disable', 1)[0]
        for kind in ('script', 'scheduler'):
            self.assertIn('/system ' + kind + ' find where name=', before_disable)
        for guard in ('comment] != $scriptComment', 'comment] != $schedulerComment',
                      'on-event] != $event', 'name] != $backupName',
                      '/system script job find'):
            self.assertIn(guard, before_disable)
        for kind in ('script', 'scheduler'):
            region = code.split(':set uninstallStage "suppression ' + kind + '";', 1)[1]
            before_remove = region.split('/system ' + kind + ' remove', 1)[0]
            self.assertIn('/system ' + kind + ' find where name=', before_remove)
            self.assertIn('comment] != $' + kind + 'Comment', before_remove)

    def test_failure_reasons_are_literal_not_native_errors(self):
        self.assertIn(':put ("Motif : " . $uninstallReason);', self.uninstall)
        self.assertIn(':put ("Motif : " . $failureReason);', self.code)
        for variable in ('uninstallReason', 'failureReason'):
            assignments = re.findall(r':(?:local|set) ' + variable + r' ([^\n]+)', self.installer)
            self.assertGreater(len(assignments), 4)
            for value in assignments:
                self.assertRegex(value, r'^"[^"$]*";$')

    def test_password_confirmation_separated_from_cloud_warning(self):
        lines = self.colored_installer.splitlines()
        for message in ('ATTENTION : suppression Cloud', 'La sauvegarde Cloud sera remplacee'):
            index = next(i for i, line in enumerate(lines) if message in line)
            self.assertEqual(lines[index - 1].strip(), ':put "";')
            self.assertNotEqual(lines[index - 2].strip(), ':put "";')

    def test_password_error_separated_from_retry_prompt(self):
        lines = self.colored_installer.splitlines()
        for message in ('Mot de passe invalide.', 'Mot de passe trop court.',
                        'Les mots de passe ne correspondent pas.'):
            index = next(i for i, line in enumerate(lines) if message in line)
            self.assertEqual(lines[index + 1].strip(), ':put "";')

    def test_planning_errors_spacing_and_color(self):
        lines = self.colored_installer.splitlines()
        for prefix, count in (('Heure invalide.', 1), ('Intervalle invalide.', 2)):
            index = next(i for i, line in enumerate(lines) if prefix in line)
            self.assertEqual(lines[index - 1].strip(), ':put "";')
            self.assertEqual(lines[index + count].strip(), ':put "";')
            for line in lines[index:index + count]:
                self.assertIn(r'\1B[31m', line)
                self.assertIn(r'\1B[0m', line)

    def test_zero_cancellation_before_validation_and_mutation(self):
        code = self.installer
        guard = ':if (($value = "0") && ($invalid = false)) do={ :return ""; };'
        self.assertIn(guard, code)
        self.assertLess(code.index(guard), code.index(':if ([:len $value] < 8)'))
        for prompt in ('Heure de depart [', 'Intervalle entre les sauvegardes ['):
            block = code.split(':local answer [/terminal ask prompt=("' + prompt, 1)[1]
            before_validation = block.split(':local candidate $answer;', 1)[0]
            self.assertIn(':if ($answer = "0")', before_validation)
            self.assertIn(':set cancelled true;', before_validation)
            self.assertIn(':error "Saisie annulee";', before_validation)
        self.assertNotIn('Appuyez sur Echap', code)

    def test_spacing_in_alternative_paths(self):
        code = self.installer
        self.assertIn(':if ($invalid) do={\n                :put "";', code)
        self.assertIn(':if ([:len $value] < 8) do={\n                    :put "";', code)
        self.assertIn(':put "";\n                                    :local confirmation', code)
        self.assertIn(':if ($required != "") do={\n                            :put "";', code)
        self.assertIn('remove-file number=($backups->0);\n                                    :put "";', code)
        self.assertIn(':put "";\n                        :put "Sortie sans nettoyage.', code)
        self.assertNotRegex(self.colored_installer,
                            r'(?m)^ *:put "";\n *:put "";\n *:put "";')

    def test_final_frames_have_single_inner_spacing(self):
        lines = self.colored_installer.splitlines()
        for title in ('Installation terminee', 'Desinstallation terminee'):
            index = next(i for i, line in enumerate(lines) if '----- ' + title + ' -----' in line)
            start = max(i for i in range(index) if '#' * 100 in lines[i])
            end = next(i for i in range(index + 1, len(lines)) if '#' * 100 in lines[i])
            inner = [line.strip() for line in lines[start + 1:end]]
            self.assertEqual(inner[0], ':put "";')
            self.assertEqual(inner[-1], ':put "";')
            self.assertFalse(any(a == b == ':put "";' for a, b in zip(inner, inner[1:])))
            self.assertEqual([line.strip() for line in lines[start - 2:start]], [':put "";'] * 2)
            self.assertEqual([line.strip() for line in lines[end + 1:end + 3]], [':put "";'] * 2)

    def test_final_summary_after_successful_cleanup(self):
        code = self.code
        gate = code.index(':if (($failed = false) && ($runtimeValidated = true))')
        title = code.index(':put "----- Installation terminee -----";')
        self.assertLess(gate, title)
        self.assertLess(code.index(':error "Suppression non confirmee";'), title)
        self.assertLess(title, code.index(':put "----- Nettoyage incomplet -----'))
        self.assertIn(':local summaryStartTime "";', code[:gate])
        self.assertIn(':local summaryInterval "";', code[:gate])
        self.assertIn(':set summaryStartTime $startTime;', code[:gate])
        self.assertIn(':set summaryInterval $interval;', code[:gate])
        summary = code[title:]
        for line in ('Sauvegarde Cloud : verifiee', 'Test du script   : reussi',
                     'Scheduler        : actif'):
            self.assertIn(':put "' + line + '";', summary)
        self.assertIn(':put ("Heure de depart  : " . $summaryStartTime);', summary)
        self.assertIn(':put ("Intervalle       : " . $summaryInterval);', summary)
        border = ':put "' + '#' * 100 + '";'
        self.assertEqual(code[gate:title].count(border), 1)
        self.assertEqual(summary.count(border), 1)


if __name__ == "__main__":
    unittest.main()
