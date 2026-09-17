####################################################################################################
#####
##### Mikrotik Script
##### toor3869_auto-backup-mikrotik-cloud.install.rsc
##### VERSION 2026-09-17 - BY TOOR3869
#####
####################################################################################################

# MIT - Copyright (c) 2026 TOOR3869. Voir LICENSE a la racine du depot.
# Premiere version de laboratoire. Import interactif dans Winbox, pas depuis un scheduler.
{
    :local scriptName "toor3869_auto-backup-mikrotik-cloud.rsc";
    :local schedulerName "toor3869_auto-backup-mikrotik-cloud";
    :local installerFile "toor3869_auto-backup-mikrotik-cloud.install.rsc";
    :local backupName "toor3869-auto-backup-mikrotik-cloud";
    :local scriptComment "TOOR3869 -> Sauvegarde automatique chiffree vers MikroTik Cloud";
    :local schedulerComment "TOOR3869 -> Sauvegarde automatique chiffree vers MikroTik Cloud";
    :local event ("/system script run " . $scriptName . ";");
    # Source embarquee : une chaine par ligne du script final, avec retours Winbox.
    :local runtimeSource ( \
        "####################################################################################################\r\n" . \
        "#####\r\n" . \
        "##### Mikrotik Script\r\n" . \
        "##### toor3869_auto-backup-mikrotik-cloud.rsc\r\n" . \
        "##### VERSION 2026-09-17 - BY TOOR3869\r\n" . \
        "#####\r\n" . \
        "####################################################################################################\r\n" . \
        "\r\n" . \
        "# MIT - Copyright (c) 2026 TOOR3869. Voir LICENSE a la racine du depot.\r\n" . \
        "# Modele public : le secret est injecte uniquement dans la copie installee.\r\n" . \
        ":local backupPassword \"__TOOR3869_PASSWORD__\";\r\n" . \
        ":local scriptName \"toor3869_auto-backup-mikrotik-cloud.rsc\";\r\n" . \
        ":local backupName \"toor3869-auto-backup-mikrotik-cloud\";\r\n" . \
        ":local stage \"preparation\";\r\n" . \
        ":local failed false;\r\n" . \
        ":do {\r\n" . \
        "    :if ([:jobname] != \$scriptName) do={ :error \"Contexte incorrect\"; };\r\n" . \
        "    :if ([/system script job print count-only where script=\$scriptName] != 1) do={\r\n" . \
        "        :error \"Execution concurrente\";\r\n" . \
        "    };\r\n" . \
        "    :if (([:len \$backupPassword] = 0) || (\$backupPassword = (\"__TOOR3869_\" . \"PASSWORD__\"))) do={\r\n" . \
        "        :error \"Mot de passe non configure\";\r\n" . \
        "    };\r\n" . \
        "    :set stage \"selection sauvegarde\";\r\n" . \
        "    :local backups [/system backup cloud find];\r\n" . \
        "    :if ([:len \$backups] != 1) do={ :error \"Sauvegarde absente ou ambigue\"; };\r\n" . \
        "    :local backup (\$backups->0);\r\n" . \
        "    :if ([/system backup cloud get \$backup name] != \$backupName) do={\r\n" . \
        "        :error \"Sauvegarde non geree par cet installateur\";\r\n" . \
        "    };\r\n" . \
        "    :local previousDate [/system backup cloud get \$backup date];\r\n" . \
        "    :delay 2s;\r\n" . \
        "    :set stage \"transfert\";\r\n" . \
        "    /system backup cloud upload-file \\\r\n" . \
        "        action=create-and-upload \\\r\n" . \
        "        name=\$backupName \\\r\n" . \
        "        replace=\$backupName \\\r\n" . \
        "        password=\$backupPassword \\\r\n" . \
        "    ;\r\n" . \
        "    :set stage \"verification distante\";\r\n" . \
        "    :local after [/system backup cloud find];\r\n" . \
        "    :if ([:len \$after] != 1) do={ :error \"Sauvegarde absente ou ambigue\"; };\r\n" . \
        "    :local current (\$after->0);\r\n" . \
        "    :if (([/system backup cloud get \$current name] != \$backupName) || \\\r\n" . \
        "         ([/system backup cloud get \$current status] != \"ok\") || \\\r\n" . \
        "         ([/system backup cloud get \$current size] <= 0) || \\\r\n" . \
        "         ([/system backup cloud get \$current date] = \$previousDate)) do={\r\n" . \
        "        :error \"Nouvel envoi non confirme\";\r\n" . \
        "    };\r\n" . \
        "} on-error={\r\n" . \
        "    :set failed true;\r\n" . \
        "};\r\n" . \
        ":set backupPassword \"\";\r\n" . \
        ":if (\$failed) do={\r\n" . \
        "    # Ne jamais journaliser l'erreur native ni la cle de telechargement Cloud.\r\n" . \
        "    :log error (\"TOOR3869 Cloud status=failed stage=\" . \$stage);\r\n" . \
        "    :error \"Sauvegarde Cloud non confirmee - consulter les logs\";\r\n" . \
        "};\r\n" . \
        ":log info \"TOOR3869 Cloud status=succeeded\";\r\n" . \
        "\r\n" . \
        "####################################################################################################\r\n" . \
        "\r\n" \
    );
    :local readPassword do={
        :local alphabet " !\"#\$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_\60abcdefghijklmnopqrstuvwxyz{|}~";
        :local value "";
        :put "Mot de passe (invisible, ASCII, 8 a 128 caracteres, Echap annule) :";
        :while (true) do={
            :local key [/terminal inkey timeout=2m];
            :if (([:typeof $key] != "num") || ($key < 0) || ($key = 27) || ($key = 3)) do={
                :error "Saisie annulee ou expiree";
            };
            :if (($key = 13) || ($key = 10)) do={
                :if ([:len $value] < 8) do={ :error "Mot de passe trop court"; };
                :return $value;
            };
            :if (($key = 8) || ($key = 127)) do={
                :if ([:len $value] > 0) do={ :set value [:pick $value 0 ([:len $value] - 1)]; };
            } else={
                :if (($key < 32) || ($key > 126)) do={ :error "Caractere non pris en charge"; };
                :if ([:len $value] >= 128) do={ :error "Mot de passe trop long"; };
                :set value ($value . [:pick $alphabet ($key - 32) ($key - 31)]);
            };
        };
    };
    :local encodePassword do={
        :local encoded "";
        :for i from=0 to=([:len $1] - 1) do={
            :local char [:pick $1 $i ($i + 1)];
            :if (($char = "\\") || ($char = "\"") || ($char = "\$")) do={
                :set encoded ($encoded . "\\");
            };
            :set encoded ($encoded . $char);
        };
        :return $encoded;
    };

    :put "TOOR3869 - Sauvegarde automatique MikroTik Cloud";
    :put "1 Installer/reinstaller | 2 Modifier le planning | 3 Changer le mot de passe | 0 Quitter";
    :local mode [/terminal ask prompt="Votre choix [0] : "];
    :if (($mode = "") || ($mode = "0")) do={ :put "Aucune modification."; :return 0; };
    :if (($mode != "1") && ($mode != "2") && ($mode != "3")) do={ :error "Choix invalide"; };
    :global toor3869CloudInstallerLock;
    :if ($toor3869CloudInstallerLock = true) do={
        :error "Installation active ou interrompue : verifier avant de liberer le verrou";
    };
    :set toor3869CloudInstallerLock true;
    :local failed false;
    :local stage "inventaire";
    :local password "";
    :local scheduleId;
    :local mutated false;
    :local wasDisabled false;
    :local runtimeValidated false;
    :do {
        :local scripts [/system script find where name=$scriptName];
        :local schedules [/system scheduler find where name=$schedulerName];
        :local backups [/system backup cloud find];
        :if (([:len $scripts] > 1) || ([:len $schedules] > 1) || ([:len $backups] > 1)) do={
            :error "Etat ambigu";
        };
        :put ("Script=" . [:len $scripts] . " Scheduler=" . [:len $schedules] . \
            " Sauvegarde Cloud=" . [:len $backups]);
        :local scriptId;
        # Aucun ecrasement d'un objet homonyme ancien ou appartenant a un autre outil.
        :if ([:len $scripts] = 1) do={
            :set scriptId ($scripts->0);
            :if ([/system script get $scriptId comment] != $scriptComment) do={
                :error "Script homonyme non gere : migration a examiner";
            };
        };
        :if ([:len $schedules] = 1) do={
            :set scheduleId ($schedules->0);
            :set wasDisabled [/system scheduler get $scheduleId disabled];
            :if (([/system scheduler get $scheduleId comment] != $schedulerComment) || \
                 ([/system scheduler get $scheduleId on-event] != $event)) do={
                :error "Scheduler homonyme non gere : migration a examiner";
            };
        };
        :if (($mode != "1") && (([:len $scripts] != 1) || ([:len $schedules] != 1))) do={
            :error "Installation incomplete : utiliser le choix 1";
        };
        :local startTime "00:00:00";
        :local interval "1h";
        :if ([:len $schedules] = 1) do={
            :set startTime [:tostr [/system scheduler get $scheduleId start-time]];
            :set interval [:tostr [/system scheduler get $scheduleId interval]];
        };
        :if ($mode != "3") do={
            :set stage "saisie planning";
            :local answer [/terminal ask prompt=("Heure HH:MM:SS [" . $startTime . "] : ")];
            :if ($answer != "") do={ :set startTime $answer; };
            :set answer [/terminal ask prompt=("Intervalle RouterOS [" . $interval . "] : ")];
            :if ($answer != "") do={ :set interval $answer; };
        };
        :local timeValue [:totime $startTime];
        :local intervalValue [:totime $interval];
        :if (([:typeof $timeValue] != "time") || ($timeValue < 0s) || ($timeValue >= 1d) || \
             ([:len $startTime] != 8) || ([:pick $startTime 2 3] != ":") || \
             ([:pick $startTime 5 6] != ":") || \
             ([:typeof $intervalValue] != "time") || ($intervalValue <= 0s)) do={
            :error "Planning invalide";
        };
        :local installedSource "";
        :if ($mode != "2") do={
            :set stage "saisie mot de passe";
            :set password [$readPassword];
            :put "Confirmez le mot de passe :";
            :local confirmation [$readPassword];
            :if ($password != $confirmation) do={ :error "Mots de passe differents"; };
            :set confirmation "";
            :local token "__TOOR3869_PASSWORD__";
            :local offset [:find $runtimeSource $token];
            :if ([:typeof $offset] = "nil") do={ :error "Modele incomplet"; };
            :set installedSource ([:pick $runtimeSource 0 $offset] . [$encodePassword $password] . \
                [:pick $runtimeSource ($offset + [:len $token]) [:len $runtimeSource]]);
            # Analyse de syntaxe sans execution avant les mutations.
            :local parsed [:parse $installedSource];
        };
        :set stage "confirmation";
        :local required "OUI";
        :if (($mode = "3") && ([:len $backups] = 1)) do={
            :put "ATTENTION : suppression Cloud puis recreation avec le nouveau mot de passe.";
            :put "Un echec de recreation laissera le routeur sans sauvegarde Cloud.";
            :set required "EFFACER";
        } else={
            :if (($mode = "1") && ([:len $backups] = 1)) do={
                :put "La sauvegarde Cloud sera remplacee avec le mot de passe saisi.";
                :set required "REMPLACER";
            };
        };
        :if ([/terminal ask prompt=("Confirmer avec " . $required . " : ")] != $required) do={
            :error "Operation annulee";
        };
        :set stage "mise en securite scheduler";
        :if ([:len $schedules] = 1) do={ /system scheduler disable $scheduleId; };
        :set mutated true;
        :if ([/system script job print count-only where script=$scriptName] != 0) do={
            :error "Sauvegarde deja active : attendre sa fin";
        };
        :if ($mode = "2") do={
            /system scheduler set $scheduleId \
                start-date=2026-01-01 \
                start-time=$startTime \
                interval=$intervalValue \
            ;
        } else={
            :set stage "preparation sauvegarde Cloud";
            :if (($mode = "3") && ([:len $backups] = 1)) do={
                /system backup cloud remove-file number=0;
                :if ([:len [/system backup cloud find]] != 0) do={ :error "Suppression non confirmee"; };
                :set backups [/system backup cloud find];
            };
            :local previousDate "";
            :if ([:len $backups] = 0) do={
                /system backup cloud upload-file \
                    action=create-and-upload \
                    name=$backupName \
                    password=$password \
                ;
            } else={
                :local existing ($backups->0);
                :set previousDate [/system backup cloud get $existing date];
                :local existingName [/system backup cloud get $existing name];
                :delay 2s;
                /system backup cloud upload-file \
                    action=create-and-upload \
                    name=$backupName \
                    replace=$existingName \
                    password=$password \
                ;
            };
            :set stage "verification premiere sauvegarde";
            :local checked [/system backup cloud find];
            :if ([:len $checked] != 1) do={ :error "Sauvegarde non confirmee"; };
            :local current ($checked->0);
            :if (([/system backup cloud get $current name] != $backupName) || \
                 ([/system backup cloud get $current status] != "ok") || \
                 ([/system backup cloud get $current size] <= 0) || \
                 ([/system backup cloud get $current date] = $previousDate)) do={
                :error "Sauvegarde non confirmee";
            };
            :set stage "installation script";
            :if ([:len $scripts] = 0) do={
                /system script add \
                    name=$scriptName \
                    comment=$scriptComment \
                    policy=ftp,read,write,policy,test,password,sensitive \
                    dont-require-permissions=no \
                    source=$installedSource \
                ;
            } else={
                /system script set $scriptId \
                    source=$installedSource \
                    policy=ftp,read,write,policy,test,password,sensitive \
                    dont-require-permissions=no \
                ;
            };
            :set password "";
            :set installedSource "";
            :set stage "installation scheduler desactive";
            :if ([:len $schedules] = 0) do={
                /system scheduler add \
                    name=$schedulerName \
                    comment=$schedulerComment \
                    on-event=$event \
                    start-date=2026-01-01 \
                    start-time=$startTime \
                    interval=$intervalValue \
                    policy=ftp,read,write,policy,test,password,sensitive \
                    disabled=yes \
                ;
                :set scheduleId ([/system scheduler find where name=$schedulerName]->0);
            } else={
                /system scheduler set $scheduleId \
                    start-date=2026-01-01 \
                    start-time=$startTime \
                    interval=$intervalValue \
                    policy=ftp,read,write,policy,test,password,sensitive \
                ;
            };
            :set stage "test reel du script installe";
            /system script run $scriptName;
            :set runtimeValidated true;
        };
        :set stage "activation scheduler";
        :if (($mode != "2") || ($wasDisabled = false)) do={
            /system scheduler enable $scheduleId;
            :if ([/system scheduler get $scheduleId disabled] = true) do={ :error "Activation non confirmee"; };
            :put "Operation terminee. Scheduler actif.";
        } else={ :put "Planning modifie. Scheduler conserve desactive."; };
    } on-error={
        :set failed true;
    };
    :set password "";
    :set toor3869CloudInstallerLock false;
    :if ($failed) do={
        :put ("ECHEC ou annulation - etape : " . $stage);
        :if ($mutated) do={
            :do { /system scheduler disable $scheduleId; } on-error={
                :put "Impossible de confirmer la desactivation : verifier le scheduler.";
            };
            :put "Installation non validee. Verifier le Cloud avant de relancer.";
        } else={ :put "Aucune mutation de configuration effectuee."; };
        :error "Installation non validee";
    };
    # Nettoyage uniquement apres test reel et activation confirmee, jamais apres une erreur.
    # Le mode planning seul conserve le fichier : il ne reteste pas la sauvegarde.
    :if (($failed = false) && ($runtimeValidated = true)) do={
        :do {
            :if ([/system scheduler get $scheduleId disabled] = true) do={
                :error "Scheduler inactif : conserver l'installateur";
            };
            :local installerIds [/file find where name=$installerFile];
            :if ([:len $installerIds] > 1) do={ :error "Fichier ambigu"; };
            :if ([:len $installerIds] = 1) do={
                /file remove ($installerIds->0);
                :if ([:len [/file find where name=$installerFile]] != 0) do={
                    :error "Suppression non confirmee";
                };
                :put "Fichier d'installation supprime. Script et scheduler conserves.";
            } else={
                :put "Fichier d'installation absent a la racine : aucun fichier supprime.";
            };
        } on-error={
            # Un echec du menage ne doit pas desactiver une sauvegarde validee.
            :put "AVERTISSEMENT : nettoyage non confirme. Verifier le fichier dans Files.";
        };
    };
}

####################################################################################################

