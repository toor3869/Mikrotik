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
        :while (true) do={
            :local value "";
            :local submitted false;
            :local invalid false;
            :put $1;
            :while ($submitted = false) do={
                :local key [/terminal inkey timeout=2m];
                :if (([:typeof $key] != "num") || ($key < 0) || ($key = 27) || ($key = 3)) do={
                    :return "";
                };
                :if (($key = 13) || ($key = 10)) do={
                    :set submitted true;
                } else={
                    :if (($key = 8) || ($key = 127)) do={
                        :if ([:len $value] > 0) do={ :set value [:pick $value 0 ([:len $value] - 1)]; };
                    } else={
                        :if (($key < 32) || ($key > 126)) do={
                            :set invalid true;
                        } else={
                            :if ([:len $value] >= 128) do={
                                :set invalid true;
                            } else={
                                :set value ($value . [:pick $alphabet ($key - 32) ($key - 31)]);
                            };
                        };
                    };
                };
            };
            :if ($invalid) do={
                :put "Mot de passe invalide. Utilisez 8 a 128 caracteres ASCII imprimables.";
            } else={
                :if ([:len $value] < 8) do={
                    :put "Mot de passe trop court. Saisissez au moins 8 caracteres.";
                } else={ :return $value; };
            };
            :set value "";
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
    # Routine commune : ne supprime que l'installateur canonique, avec deux essais maximum.
    :local cleanupInstaller do={
        :local installerFile $1;
        :if ($installerFile != "toor3869_auto-backup-mikrotik-cloud.install.rsc") do={
            :return false;
        };
        :local cleanupDone false;
        :local cleanupAttempt 0;
        :while (($cleanupDone = false) && ($cleanupAttempt < 2)) do={
            :set cleanupAttempt ($cleanupAttempt + 1);
            :do {
                :local installerIds [/file find where name=$installerFile];
                :if ([:len $installerIds] > 1) do={ :error "Fichier ambigu"; };
                :if ([:len $installerIds] = 1) do={
                    :put "";
                    :put "----- Nettoyage de l'installation -----";
                    :put "";
                    :put "Suppression du fichier d'installation.";
                    /file remove ($installerIds->0);
                    :if ([:len [/file find where name=$installerFile]] != 0) do={
                        :error "Suppression non confirmee";
                    };
                } else={
                    :put "Fichier d'installation absent a la racine : aucun fichier supprime.";
                };
                :set cleanupDone true;
            } on-error={
                :if ($cleanupAttempt < 2) do={ :put "Nouvelle tentative de nettoyage."; };
            };
        };
        :return $cleanupDone;
    };

    :put "";
    :put "####################################################################################################";
    :put "#####";
    :put "##### Installation - Sauvegarde automatique MikroTik Cloud";
    :put "##### toor3869_auto-backup-mikrotik-cloud.install.rsc";
    :put "##### VERSION 2026-09-17 - BY TOOR3869";
    :put "#####";
    :put "####################################################################################################";
    :put "";
    :put "----- Choix de l'operation -----";
    :put "";
    :put "1 - Installer ou reinstaller la sauvegarde automatique sur le cloud Mikrotik";
    :put "2 - Modifier les horaires et l'intervalle de sauvegarde";
    :put "3 - Changer le mot de passe de la sauvegarde";
    :put "9 - Desinstaller la sauvegarde automatique et nettoyer";
    :put "0 - Quitter sans modification";
    :put "";
    :local mode [/terminal ask prompt="Votre choix [0] : "];
    :if (($mode = "") || ($mode = "0")) do={ :put "Aucune modification."; :return 0; };
    :if (($mode != "1") && ($mode != "2") && ($mode != "3") && ($mode != "9")) do={ :error "Choix invalide"; };
    :global toor3869CloudInstallerLock;
    :if ($toor3869CloudInstallerLock = true) do={
        :error "Installation active ou interrompue : verifier avant de liberer le verrou";
    };
    :set toor3869CloudInstallerLock true;
    :local dispatchAgain true;
    :while ($dispatchAgain) do={
        :set dispatchAgain false;
        # Parcours de desinstallation independant : aucune creation ni activation.
        :if ($mode = "9") do={
            :local uninstallFailed false;
            :local uninstallStage "inventaire";
            :local uninstallReason "Lecture impossible : verifier les droits et la disponibilite du Cloud.";
            :do {
                :local scripts [/system script find where name=$scriptName];
                :local schedules [/system scheduler find where name=$schedulerName];
                :local backups [/system backup cloud find];
                :local files [/file find where name=$installerFile];
                :if (([:len $scripts] > 1) || ([:len $schedules] > 1) || \
                     ([:len $backups] > 1) || ([:len $files] > 1)) do={
                    :set uninstallReason "Plusieurs objets correspondent : aucune suppression autorisee.";
                    :error "Etat ambigu";
                };
                :if ([:len $scripts] = 1) do={
                    :if ([/system script get ($scripts->0) comment] != $scriptComment) do={
                        :set uninstallReason "Le script homonyme n'est pas reconnu comme notre installation.";
                        :error "Script homonyme non gere";
                    };
                };
                :if ([:len $schedules] = 1) do={
                    :if (([/system scheduler get ($schedules->0) comment] != $schedulerComment) || \
                         ([/system scheduler get ($schedules->0) on-event] != $event)) do={
                        :set uninstallReason "Le scheduler homonyme n'est pas reconnu comme notre installation.";
                        :error "Scheduler homonyme non gere";
                    };
                };
                :if ([:len $backups] = 1) do={
                    :if ([/system backup cloud get ($backups->0) name] != $backupName) do={
                        :set uninstallReason "La sauvegarde Cloud porte un autre nom : elle est protegee.";
                        :error "Sauvegarde Cloud etrangere : suppression refusee";
                    };
                };
                :if ([/system script job print count-only where script=$scriptName] != 0) do={
                    :set uninstallReason "Une sauvegarde est en cours : attendre sa fin puis recommencer.";
                    :error "Sauvegarde en cours : attendre sa fin";
                };
                :put "";
                :put "----- Desinstallation et nettoyage -----";
                :put "";
                :put "Cette operation supprimera :";
                :put "- Le scheduler de sauvegarde automatique.";
                :put "- Le script de sauvegarde automatique.";
                :put "- La sauvegarde presente sur le cloud MikroTik.";
                :put "- Le fichier d'installation.";
                :put "";
                :put "Aucune sauvegarde Cloud ne sera conservee.";
                :put "";
                :if ([/terminal ask prompt="Confirmer avec OUI : "] != "OUI") do={
                    :set toor3869CloudInstallerLock false;
                    :put "Desinstallation annulee. Aucune modification.";
                    :return 0;
                };
                :set uninstallStage "desactivation scheduler";
                :set uninstallReason "Etat modifie ou verification impossible depuis la confirmation.";
                # Refaire l'inventaire apres le prompt ; aucun identifiant ancien n'est reutilise.
                :set scripts [/system script find where name=$scriptName];
                :set schedules [/system scheduler find where name=$schedulerName];
                :set backups [/system backup cloud find];
                :if (([:len $scripts] > 1) || ([:len $schedules] > 1) || ([:len $backups] > 1)) do={
                    :error "Etat devenu ambigu";
                };
                :if ([:len $scripts] = 1) do={
                    :if ([/system script get ($scripts->0) comment] != $scriptComment) do={
                        :set uninstallReason "Le script a change : suppression refusee.";
                        :error "Script non gere";
                    };
                };
                :if ([:len $schedules] = 1) do={
                    :if (([/system scheduler get ($schedules->0) comment] != $schedulerComment) || \
                         ([/system scheduler get ($schedules->0) on-event] != $event)) do={
                        :set uninstallReason "Le scheduler a change : suppression refusee.";
                        :error "Scheduler non gere";
                    };
                };
                :if ([:len $backups] = 1) do={
                    :if ([/system backup cloud get ($backups->0) name] != $backupName) do={
                        :set uninstallReason "La sauvegarde Cloud a change : suppression refusee.";
                        :error "Cloud non gere";
                    };
                };
                :if ([/system script job print count-only where script=$scriptName] != 0) do={
                    :set uninstallReason "Une sauvegarde a demarre : attendre sa fin puis recommencer.";
                    :error "Sauvegarde en cours";
                };
                :set uninstallReason "Impossible de desactiver le scheduler ou de confirmer son etat.";
                :if ([:len $schedules] = 1) do={
                    /system scheduler disable ($schedules->0);
                    :if ([/system scheduler get ($schedules->0) disabled] = false) do={
                        :error "Desactivation non confirmee";
                    };
                };
                :if ([/system script job print count-only where script=$scriptName] != 0) do={
                    :set uninstallReason "Une sauvegarde a demarre : elle n'a pas ete interrompue.";
                    :error "Sauvegarde en cours : aucune execution interrompue";
                };
                :set uninstallStage "suppression sauvegarde Cloud";
                :set uninstallReason "Suppression Cloud refusee ou absence non confirmee.";
                # Relire apres la confirmation : ne jamais supprimer une autre sauvegarde.
                :set backups [/system backup cloud find];
                :if ([:len $backups] > 1) do={ :error "Cloud ambigu"; };
                :if ([:len $backups] = 1) do={
                    :if ([/system backup cloud get ($backups->0) name] != $backupName) do={
                        :error "Sauvegarde Cloud etrangere";
                    };
                    /system backup cloud remove-file number=0;
                };
                :if ([:len [/system backup cloud find]] != 0) do={ :error "Suppression Cloud non confirmee"; };
                :put "Sauvegarde Cloud : absente.";
                :set uninstallStage "suppression scheduler";
                :set uninstallReason "Scheduler modifie, suppression refusee ou absence non confirmee.";
                :set schedules [/system scheduler find where name=$schedulerName];
                :if ([:len $schedules] > 1) do={ :error "Scheduler ambigu"; };
                :if ([:len $schedules] = 1) do={
                    :if (([/system scheduler get ($schedules->0) comment] != $schedulerComment) || \
                         ([/system scheduler get ($schedules->0) on-event] != $event) || \
                         ([/system scheduler get ($schedules->0) disabled] = false)) do={
                        :error "Scheduler modifie";
                    };
                };
                :if ([:len $schedules] = 1) do={ /system scheduler remove ($schedules->0); };
                :if ([:len [/system scheduler find where name=$schedulerName]] != 0) do={
                    :error "Suppression scheduler non confirmee";
                };
                :put "Scheduler : absent.";
                :set uninstallStage "suppression script";
                :set uninstallReason "Script modifie, actif, suppression refusee ou absence non confirmee.";
                :set scripts [/system script find where name=$scriptName];
                :if ([:len $scripts] > 1) do={ :error "Script ambigu"; };
                :if ([:len $scripts] = 1) do={
                    :if ([/system script get ($scripts->0) comment] != $scriptComment) do={
                        :error "Script modifie";
                    };
                };
                :if ([/system script job print count-only where script=$scriptName] != 0) do={
                    :error "Script actif";
                };
                :if ([:len $scripts] = 1) do={ /system script remove ($scripts->0); };
                :if ([:len [/system script find where name=$scriptName]] != 0) do={
                    :error "Suppression script non confirmee";
                };
                :put "Script : absent.";
                :set uninstallStage "nettoyage fichier d'installation";
                :set uninstallReason "Fichier non supprime ou absence non confirmee apres deux essais.";
                :local cleaned [$cleanupInstaller $installerFile];
                :if ($cleaned = false) do={ :error "Nettoyage incomplet"; };
                :put "";
                :put "----- Desinstallation terminee -----";
                :put "Script, scheduler, sauvegarde Cloud et fichier d'installation supprimes.";
            } on-error={
                :set uninstallFailed true;
                :put ("Desinstallation incomplete ou refusee - etape : " . $uninstallStage);
                :put ("Motif : " . $uninstallReason);
                :put "Aucune sauvegarde en cours n'a ete interrompue.";
                :put "Les suppressions deja effectuees ne sont pas annulees.";
                :put "Conservez l'installateur et relancez le choix 9 apres verification.";
            };
            :set toor3869CloudInstallerLock false;
            :if ($uninstallFailed) do={ :error "Desinstallation non validee"; };
            :return 0;
        };
        # Fin du parcours de desinstallation.
        :local failed false;
        :local cancelled false;
        :local failureReason "Operation refusee ou resultat non confirme ; verifier les droits et le reseau.";
        :local stage "inventaire";
        :local password "";
        :local scheduleId;
        :local mutated false;
        :local wasDisabled false;
        :local runtimeValidated false;
        :local summaryStartTime "";
        :local summaryInterval "";
        :local retry true;
        :local inputsReady false;
        :local initialStateKnown false;
        :local startTime "00:00:00";
        :local interval "1h";
        :local installedSource "";
        :local cloudDate "";
        :local cloudSize 0;
        :while ($retry) do={
            :set retry false;
            :set failed false;
            :set cancelled false;
            :set failureReason "Operation refusee ou resultat non confirme ; verifier les droits et le reseau.";
            :set runtimeValidated false;
            :set stage "inventaire";
            :do {
                :put "";
                :put "----- Verification de l'installation -----";
                :put "";
                :put "Recherche des elements deja presents sur ce MikroTik";
                :put "";
                :local scripts [/system script find where name=$scriptName];
                :local schedules [/system scheduler find where name=$schedulerName];
                :local backups [/system backup cloud find];
                :if (([:len $scripts] > 1) || ([:len $schedules] > 1) || ([:len $backups] > 1)) do={
                    :set failureReason "Plusieurs objets correspondent : inventaire ambigu, aucune modification autorisee.";
                    :error "Etat ambigu";
                };
                :local scriptState "absent";
                :local schedulerState "absent";
                :local backupState "absente";
                :if ([:len $scripts] = 1) do={ :set scriptState "present"; };
                :if ([:len $schedules] = 1) do={
                    :set schedulerState "present (actif)";
                    :if ([/system scheduler get ($schedules->0) disabled] = true) do={
                        :set schedulerState "present (desactive)";
                    };
                };
                :if ([:len $backups] = 1) do={ :set backupState "presente"; };
                :put ("Script sur le Mikrotik    : " . $scriptState);
                :put ("Scheduler sur le Mikrotik : " . $schedulerState);
                :put ("Sauvegarde sur le cloud   : " . $backupState);
                :put "";
                :local scriptId;
                # Aucun ecrasement d'un objet homonyme ancien ou appartenant a un autre outil.
                :if ([:len $scripts] = 1) do={
                    :set scriptId ($scripts->0);
                    :if ([/system script get $scriptId comment] != $scriptComment) do={
                        :set failureReason "Le script homonyme n'est pas reconnu comme notre installation.";
                        :error "Script homonyme non gere : migration a examiner";
                    };
                };
                :if ([:len $schedules] = 1) do={
                    :set scheduleId ($schedules->0);
                    :if ($initialStateKnown = false) do={
                        :set wasDisabled [/system scheduler get $scheduleId disabled];
                    };
                    :if (([/system scheduler get $scheduleId comment] != $schedulerComment) || \
                         ([/system scheduler get $scheduleId on-event] != $event)) do={
                        :set failureReason "Le scheduler homonyme n'est pas reconnu comme notre installation.";
                        :error "Scheduler homonyme non gere : migration a examiner";
                    };
                };
                :if (($mode != "1") && (([:len $scripts] != 1) || ([:len $schedules] != 1))) do={
                    :set failureReason "Installation incomplete : utiliser le choix 1 pour la reparer.";
                    :error "Installation incomplete : utiliser le choix 1";
                };
                :set initialStateKnown true;
                :if ($inputsReady = false) do={
                    :if ([:len $schedules] = 1) do={
                        :set startTime [:tostr [/system scheduler get $scheduleId start-time]];
                        :set interval [:tostr [/system scheduler get $scheduleId interval]];
                    };
                    :if ($mode != "3") do={
                        :set stage "saisie planning";
                        :put "----- Horaires et intervalle de sauvegarde -----";
                        :put "";
                        :put "Appuyez sur Entree pour conserver les valeurs proposees entre crochets.";
                        :put "Sinon, saisissez vos propres valeurs.";
                        :put "";
                        :put "Heure de depart : utilisez le format HH:MM:SS sur 24 heures.";
                        :put "Exemples : 00:00:00 pour minuit, 05:30:00 pour 5 h 30.";
                        :put "";
                        :local hourAccepted false;
                        :while ($hourAccepted = false) do={
                            :local answer [/terminal ask prompt=("Heure de depart [" . $startTime . "] : ")];
                            :local candidate $answer;
                            :if ($candidate = "") do={ :set candidate $startTime; };
                            :do {
                                :if (([:len $candidate] = 8) && \
                                     ($candidate ~ "^[0-2][0-9]:[0-5][0-9]:[0-5][0-9]")) do={
                                    :local parsedTime [:totime $candidate];
                                    :if ([:typeof $parsedTime] = "time") do={
                                        :if (($parsedTime >= 0s) && ($parsedTime < 1d)) do={
                                            :set startTime $candidate;
                                            :set hourAccepted true;
                                        };
                                    };
                                };
                            } on-error={ :set hourAccepted false; };
                            :if ($hourAccepted = false) do={
                                :put "Heure invalide. Saisissez une heure entre 00:00:00 et 23:59:59.";
                            };
                        };
                        :put "";
                        :put "Intervalle : utilisez d pour les jours, h pour les heures,";
                        :put "m pour les minutes et s pour les secondes.";
                        :put "Exemples : 30m, 1h, 6h ou 1h30m.";
                        :put "Pour une sauvegarde quotidienne, indiquez 1d ou 24h.";
                        :put "";
                        :put "L'intervalle doit etre superieur a zero et ne pas depasser 1d.";
                        :put "";
                        :local intervalAccepted false;
                        :while ($intervalAccepted = false) do={
                            :local answer [/terminal ask prompt=("Intervalle entre les sauvegardes [" . $interval . "] : ")];
                            :local candidate $answer;
                            :if ($candidate = "") do={ :set candidate $interval; };
                            :do {
                                :local parsedInterval [:totime $candidate];
                                :if ([:typeof $parsedInterval] = "time") do={
                                    :if (($parsedInterval > 0s) && ($parsedInterval <= 1d)) do={
                                        :set interval $candidate;
                                        :set intervalAccepted true;
                                    };
                                };
                            } on-error={ :set intervalAccepted false; };
                            :if ($intervalAccepted = false) do={
                                :put "Intervalle invalide. Saisissez une duree superieure a zero";
                                :put "et inferieure ou egale a 1d, par exemple 30m, 1h, 6h ou 1d.";
                            };
                        };
                        :put "";
                    };
                    :local timeValue [:totime $startTime];
                    :local intervalValue [:totime $interval];
                    :if (([:typeof $timeValue] != "time") || ($timeValue < 0s) || ($timeValue >= 1d) || \
                         ([:len $startTime] != 8) || ([:pick $startTime 2 3] != ":") || \
                         ([:pick $startTime 5 6] != ":") || \
                         ([:typeof $intervalValue] != "time") || ($intervalValue <= 0s) || \
                         ($intervalValue > 1d)) do={
                        :set failureReason "Planning invalide : corriger l'heure et l'intervalle via le choix 2.";
                        :error "Planning invalide";
                    };
                };
                :local intervalValue [:totime $interval];
                :if ($inputsReady = false) do={
                    :if ($mode != "2") do={
                        :set stage "saisie mot de passe";
                        :put "----- Mot de passe de la sauvegarde -----";
                        :put "";
                        :put "Ce mot de passe protege votre sauvegarde chiffree.";
                        :put "Conservez-le : il sera necessaire pour la restaurer.";
                        :put "";
                        :put "Il sera enregistre en clair dans le script installe sur ce MikroTik.";
                        :put "Vous pourrez le retrouver dans la variable backupPassword.";
                        :put "Les utilisateurs autorises a lire le script pourront aussi le consulter.";
                        :put "";
                        :put "Utilisez entre 8 et 128 caracteres ASCII imprimables.";
                        :put "La saisie est invisible. Appuyez sur Echap pour annuler.";
                        :put "";
                        :local passwordsMatch false;
                        :while ($passwordsMatch = false) do={
                            :set password [$readPassword "Saisissez votre mot de passe :"];
                            :if ($password = "") do={
                                :set cancelled true;
                                :error "Saisie annulee";
                            };
                            :local confirmation [$readPassword "Confirmez votre mot de passe :"];
                            :if ($confirmation = "") do={
                                :set password "";
                                :set cancelled true;
                                :error "Saisie annulee";
                            };
                            :if ($password = $confirmation) do={
                                :set passwordsMatch true;
                            } else={
                                :set password "";
                                :put "Les mots de passe ne correspondent pas. Recommencez la saisie.";
                            };
                            :set confirmation "";
                        };
                        :local token "__TOOR3869_PASSWORD__";
                        :local offset [:find $runtimeSource $token];
                        :if ([:typeof $offset] = "nil") do={ :error "Modele incomplet"; };
                        :set installedSource ([:pick $runtimeSource 0 $offset] . [$encodePassword $password] . \
                            [:pick $runtimeSource ($offset + [:len $token]) [:len $runtimeSource]]);
                        # Analyse de syntaxe sans execution avant les mutations.
                        :local parsed [:parse $installedSource];
                    };
                    :set inputsReady true;
                };
                # Une reprise ne reutilise que la sauvegarde deja verifiee dans cette session.
                :local cloudReady false;
                :if (([:len $backups] = 1) && ($cloudDate != "")) do={
                    :local saved ($backups->0);
                    :set cloudReady (([/system backup cloud get $saved name] = $backupName) && \
                        ([/system backup cloud get $saved status] = "ok") && \
                        ([/system backup cloud get $saved date] = $cloudDate) && \
                        ([/system backup cloud get $saved size] = $cloudSize));
                };
                :set stage "confirmation";
                :local required "";
                :if ($cloudReady = false) do={
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
                };
                :if ($required != "") do={
                    :if ([/terminal ask prompt=("Confirmer avec " . $required . " : ")] != $required) do={
                        :set cancelled true;
                        :error "Operation annulee";
                    };
                };
                :set stage "mise en securite scheduler";
                :if ([/system script job print count-only where script=$scriptName] != 0) do={
                    :set failureReason "Une sauvegarde est en cours : attendre sa fin avant de reprendre.";
                    :error "Sauvegarde deja active : attendre sa fin";
                };
                :set mutated true;
                :if ([:len $schedules] = 1) do={ /system scheduler disable $scheduleId; };
                :if ([/system script job print count-only where script=$scriptName] != 0) do={
                    :set failureReason "Une sauvegarde vient de demarrer : attendre sa fin avant de reprendre.";
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
                    :local firstBackup ([:len $backups] = 0);
                    :if ($cloudReady = false) do={
                        :if ($firstBackup) do={
                            :put "";
                            :put "----- Premiere sauvegarde Cloud -----";
                            :put "";
                            :put "Creation et envoi de la sauvegarde chiffree vers le cloud Mikrotik.";
                            :put "Cette operation peut prendre plusieurs minutes. Merci de patienter.";
                            :put "";
                        };
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
                        :set cloudDate [/system backup cloud get $current date];
                        :set cloudSize [/system backup cloud get $current size];
                        } else={
                            :put "Sauvegarde Cloud deja verifiee : conservation pour cette reprise.";
                    };
                    :set stage "installation script";
                    :if ($firstBackup) do={ :put "Sauvegarde Cloud creee et verifiee."; };
                    :put "";
                    :put "----- Installation de l'automatisation -----";
                    :put "";
                    :put "Creation du script.";
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
                    :set stage "installation scheduler desactive";
                    :put "Creation du scheduler.";
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
                    :put "";
                    :put "----- Test du script de sauvegarde -----";
                    :put "";
                    :put "Execution du script pour verifier son fonctionnement.";
                    :put "Cette operation peut prendre plusieurs minutes. Merci de patienter.";
                    :put "";
                    /system script run $scriptName;
                    :set runtimeValidated true;
                    :local tested [/system backup cloud find];
                    :if ([:len $tested] != 1) do={ :error "Sauvegarde de test introuvable"; };
                    :set cloudDate [/system backup cloud get ($tested->0) date];
                    :set cloudSize [/system backup cloud get ($tested->0) size];
                    :put "Test termine avec succes.";
                };
                :set stage "activation scheduler";
                :if (($mode != "2") || ($wasDisabled = false)) do={
                    :put "";
                    :put "----- Activation de la sauvegarde automatique -----";
                    :put "";
                    :put "Activation du scheduler.";
                    /system scheduler enable $scheduleId;
                    :if ([/system scheduler get $scheduleId disabled] = true) do={ :error "Activation non confirmee"; };
                    :put "";
                    :put "Sauvegarde automatique en service.";
                    :set summaryStartTime $startTime;
                    :set summaryInterval $interval;
                } else={ :put "Planning modifie. Scheduler conserve desactive."; };
            } on-error={
                :set failed true;
            };
            :if ($failed) do={
                :if ($cancelled = false) do={
                    :put "";
                    :put "----- Echec de l'operation -----";
                    :put "";
                    :put ("Etape concernee : " . $stage);
                    :put "L'operation n'a pas pu etre terminee.";
                    :put ("Motif : " . $failureReason);
                };
                :if ($mutated) do={
                    :do {
                        # Rechercher de nouveau l'objet, meme si sa creation a echoue apres ecriture.
                        :local owned [/system scheduler find where name=$schedulerName];
                        :if ([:len $owned] > 1) do={ :error "Scheduler ambigu"; };
                        :if ([:len $owned] = 1) do={
                            :set scheduleId ($owned->0);
                            :if (([/system scheduler get $scheduleId comment] != $schedulerComment) || \
                                 ([/system scheduler get $scheduleId on-event] != $event)) do={
                                :error "Scheduler non gere";
                            };
                            /system scheduler disable $scheduleId;
                            :if ([/system scheduler get $scheduleId disabled]) do={
                                :put "Scheduler conserve desactive tant que l'installation n'est pas validee.";
                            } else={ :error "Desactivation non confirmee"; };
                        };
                    } on-error={
                        :put "Impossible de confirmer la desactivation : verifier le scheduler.";
                    };
                } else={ :put "Aucune mutation de configuration effectuee."; };
                :put "";
                :if ($cancelled = false) do={
                    :put "Appuyez sur Entree pour une nouvelle tentative.";
                    :put "Appuyez sur Echap pour quitter.";
                    :local answered false;
                    :do {
                        :while ($answered = false) do={
                            :local key [/terminal inkey timeout=2m];
                            :if ([:typeof $key] != "num") do={ :set answered true; } else={
                                :if (($key < 0) || ($key = 27) || ($key = 3)) do={ :set answered true; };
                                :if (($key = 13) || ($key = 10)) do={
                                    :set answered true;
                                    :set retry true;
                                };
                            };
                        };
                    } on-error={ :set retry false; };
                    :if ($retry) do={
                        :put "Nouvelle verification de l'etat avant la reprise.";
                    } else={ :put "Operation interrompue. Fichier d'installation conserve."; };
                };
            };
        };
        :set password "";
        :set installedSource "";
        :if ($failed) do={
            :put "";
            :put "----- Installation interrompue -----";
            :put "";
            :put "0 - Quitter en conservant les elements existants";
            :put "9 - Desinstaller et nettoyer, sauvegarde Cloud comprise";
            :put "";
            :put "Votre choix [0] :";
            :local exitChoice "";
            :local choiceDone false;
            :do {
                :while ($choiceDone = false) do={
                    :local key [/terminal inkey timeout=2m];
                    :if ([:typeof $key] != "num") do={
                        :set exitChoice "";
                        :set choiceDone true;
                    } else={
                        :if (($key < 0) || ($key = 27) || ($key = 3)) do={
                            :set exitChoice "";
                            :set choiceDone true;
                        } else={
                            :if (($key = 13) || ($key = 10)) do={
                                :set choiceDone true;
                            } else={
                                :if (($key = 8) || ($key = 127)) do={
                                    :set exitChoice "";
                                } else={
                                    :if (($key = 57) && ($exitChoice = "")) do={
                                        :set exitChoice "9";
                                    } else={ :set exitChoice "0"; };
                                };
                            };
                        };
                    };
                };
            } on-error={ :set exitChoice ""; };
            :if ($exitChoice = "9") do={
                # Reutiliser le choix 9 : nouvel inventaire et confirmation OUI obligatoires.
                :set mode "9";
                :set dispatchAgain true;
            } else={ :put "Sortie sans nettoyage. Elements existants conserves."; };
        };
        # Nettoyage uniquement apres test reel et activation confirmee, jamais apres une erreur.
        # Le mode planning seul conserve le fichier : il ne reteste pas la sauvegarde.
        :if (($failed = false) && ($runtimeValidated = true)) do={
            :do {
                :if ([/system scheduler get $scheduleId disabled] = true) do={
                    :error "Scheduler inactif : conserver l'installateur";
                };
                :local cleanupDone [$cleanupInstaller $installerFile];
                :if ($cleanupDone = false) do={ :error "Nettoyage non confirme apres deux essais"; };
                :put "";
                :put "####################################################################################################";
                :put "";
                :put "----- Installation terminee -----";
                :put "";
                :put "Sauvegarde Cloud : verifiee";
                :put "Test du script   : reussi";
                :put "Scheduler        : actif";
                :put ("Heure de depart  : " . $summaryStartTime);
                :put ("Intervalle       : " . $summaryInterval);
                :put "";
                :put "Conservez votre mot de passe pour pouvoir restaurer la sauvegarde.";
                :put "";
                :put "####################################################################################################";
            } on-error={
                # Un echec du menage ne doit pas desactiver une sauvegarde validee.
                :put "";
                :put "----- Nettoyage incomplet -----";
                :put "";
                :do {
                    :if ([/system scheduler get $scheduleId disabled] = false) do={
                        :put "La sauvegarde automatique est en service.";
                    } else={ :put "Le scheduler est desactive : verifier son etat."; };
                } on-error={ :put "Etat actuel du scheduler non confirme."; };
                :put "Le nettoyage du fichier d'installation n'a pas pu etre confirme.";
                :put "";
                :put "Vous pouvez verifier sa presence dans Files et le supprimer :";
                :put $installerFile;
            };
        };
    };
    :set toor3869CloudInstallerLock false;
}

####################################################################################################

