<!--
Projet : Mikrotik
Fichier : CHANGELOG.md
VERSION 2026-09-17 - BY TOOR3869
-->
# Historique des modifications

## 2026-09-17

### Supprimé

- Fichier source Cloud séparé, redondant avec le script embarqué dans l'installateur autonome.
  Tests et documentation adaptés à cette source unique, sans changement de fonctionnement.

### Modifié

- Source embarquée de l'installateur Cloud découpée en chaînes concaténées, une par ligne
  du script final ; contenu et retours Winbox conservés, tests adaptés.

- Commentaire identique du script Cloud et de son scheduler, préfixé `TOOR3869 ->`,
  appliqués à la création et utilisés pour reconnaître les objets lors d'une réinstallation.

- Bannière du script Cloud alignée à gauche selon le modèle MikroTik et séparateur final ajouté,
  sans modification du corps du script.

### Ajouté

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
