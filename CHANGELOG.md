<!--
Projet : Mikrotik
Fichier : CHANGELOG.md
VERSION 2026-09-18 - BY TOOR3869
-->
# Historique des modifications

## 2026-09-18

### Modifié

- README du module Cloud aéré : lancement en premier, menu et paramètres en tableaux,
  sections dédiées aux erreurs et à la désinstallation, détails secondaires repliables.
  Commandes et avertissements de sécurité conservés ; aucun changement du script.

## 2026-09-17

### Corrigé

- Annulation de la saisie du mot de passe et refus d'une confirmation séparés des erreurs
  techniques : accès direct au menu d'interruption, sans proposition intermédiaire de réessai.
- Verrou conservé jusqu'à la sortie finale, y compris pendant les menus et le nettoyage.
- Désinstallation : nouvel inventaire après confirmation et nouvelles vérifications avant
  suppression des objets ; raisons de refus explicites sans afficher d'erreurs natives sensibles.
- Nettoyage commun à l'installation et à la désinstallation, toujours limité au fichier canonique
  et à deux essais ; tests de non-régression et consignes locales complétés.

### Ajouté

- Proposition de désinstallation après interruption, avec sortie sans nettoyage par défaut.
  Le choix 9 réutilise le même parcours et exige à nouveau la confirmation `OUI`.

- Choix 9 de désinstallation complète après confirmation exacte `OUI` : suppression de la
  sauvegarde Cloud reconnue, du scheduler, du script puis de l'installateur ; refus des objets
  étrangers et des jobs actifs, contrôle des suppressions et reprise des états partiels.

### Supprimé

- Fichier source Cloud séparé, redondant avec le script embarqué dans l'installateur autonome.
  Tests et documentation adaptés à cette source unique, sans changement de fonctionnement.

### Modifié

- Nettoyage de l'installateur : seconde tentative automatique avec nouvelle recherche du fichier,
  puis message « Nettoyage incomplet » si l'échec persiste, sans relancer la sauvegarde.

- Reprise interactive après échec : Entrée refait l'inventaire et reprend avec les paramètres
  validés ; Échap quitte. La sauvegarde déjà vérifiée est conservée si ses métadonnées concordent.
  Le scheduler reconnu est recherché à nouveau et désactivé après une mutation incomplète.
  Aucun objet étranger ni sauvegarde Cloud n'est supprimé par le traitement d'erreur.

- Présentation du nettoyage réduite au titre et à l'annonce de suppression demandés ;
  contrôles et avertissements de nettoyage conservés.

- Étape d'activation du scheduler : annonce de la mise en service après contrôle de son état actif.

- Étape de test du script présentée avec explication et attente ; message de succès affiché
  uniquement après le retour réussi de l'exécution.

- Étape d'installation de l'automatisation affichant les messages validés avant les opérations
  sur le script et le scheduler, sans changement de comportement.

- Confirmation `OUI` retirée pour les parcours sans remplacement ou suppression de sauvegarde
  existante ; confirmations `REMPLACER` et `EFFACER` conservées.

- Bloc mot de passe explicatif ; saisies invalides redemandées et double saisie reprise en cas
  de différence, sans refaire le planning. Annulation et expiration restent bloquantes.

- Bloc horaires et intervalle explicatif, menu harmonisé, nouvelle saisie limitée au champ
  invalide ; heure au format HH:MM:SS et intervalle strictement positif limité à un jour.

- Affichage de l'inventaire initial en trois lignes alignées, avec présence du script et de
  la sauvegarde Cloud ainsi que l'état actif ou désactivé du scheduler.

- Menu de choix affiché sur plusieurs lignes avec le texte validé et cinq tirets de chaque
  côté du titre ; choix et comportement inchangés.

- Source embarquée de l'installateur Cloud découpée en chaînes concaténées, une par ligne
  du script final ; contenu et retours Winbox conservés, tests adaptés.

- Commentaire identique du script Cloud et de son scheduler, préfixé `TOOR3869 ->`,
  appliqués à la création et utilisés pour reconnaître les objets lors d'une réinstallation.

- Bannière du script Cloud alignée à gauche selon le modèle MikroTik et séparateur final ajouté,
  sans modification du corps du script.

### Ajouté

- Récapitulatif final encadré de deux lignes de `#`, après test, activation et nettoyage sans
  erreur ; affiche l'heure et l'intervalle choisis sans exposer le mot de passe.

- Étape console de première sauvegarde Cloud : explication avant l'envoi et confirmation
  uniquement après les contrôles de la sauvegarde créée.

- Bannière de début affichée dans la console avant le menu de l'installateur Cloud,
  avec le nom du fichier et la version, sans modification du déroulement.

- Première publication expérimentale pour essais interactifs, sans validation native revendiquée.

- Nettoyage ciblé du fichier d'installation après test du script et activation confirmés ;
  conservation après échec, annulation ou modification du planning seul.
- Première version locale de l'installateur Cloud autonome : menu interactif, saisie du secret,
  planning, réinstallation, rotation confirmée et contrôle avant activation du scheduler.
- Modèle permanent sans identité ni SMTP propres à CPE01 ; neuf contrats statiques et TODO d'essais.
- Licence MIT à la racine, avec la mention `Copyright (c) 2026 TOOR3869`.
- README minimal de la sauvegarde Cloud avec le bloc de téléchargement et d'import prévu,
  explicitement marqué comme brouillon jusqu'à la création et publication de l'installateur.
- Conventions des scripts génériques adaptées au dépôt public dans `AGENTS.md` : bannières
  MikroTik, nommage, présentation multiligne, commentaires, sécurité et documentation locale.
