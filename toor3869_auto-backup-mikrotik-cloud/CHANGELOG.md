<!--
Projet : toor3869_auto-backup-mikrotik-cloud
Fichier : CHANGELOG.md
VERSION 2026-09-18 - BY TOOR3869
-->
# Historique des modifications

## 2026-09-18

### Corrigé

- Erreur de désinstallation aérée : séparation du motif, des précautions et de la consigne,
  puis deux lignes vides avant l'erreur finale RouterOS.

- Erreurs d'heure et d'intervalle séparées de la saisie par une ligne vide avant et après.
  Les deux lignes du message d'intervalle invalide sont désormais rouges.

- Expiration du mot de passe : contrôle du temps écoulé avant toute classification du retour
  clavier, y compris positif. Délai ramené à une minute d'inactivité avec message explicite.
  Première saisie et confirmation validées dans Winbox : expiration puis menu d'interruption
  sans mutation. Test retiré du TODO.

- Ligne vide ajoutée après le refus d'une confirmation différente, avant la nouvelle saisie.
  Détection de la différence, reprise et espacement validés par les captures utilisateur.

- Saisie non-ASCII : une valeur négative ou non numérique reçue immédiatement ne déclenche
  plus l'annulation. L'expiration est distinguée par le temps d'attente ; la saisie invalide
  est consommée jusqu'à Entrée puis refusée, sans transférer la fin du collage au menu suivant.
  Comportement confirmé dans Winbox par l'essai utilisateur avec un caractère accentué.

- Ligne vide après les erreurs de mot de passe invalide ou trop court, avant la nouvelle saisie.
  Rendu après le message de mot de passe invalide confirmé par la capture utilisateur.

- Annulation explicite par `0` puis Entrée pour les horaires et les deux saisies de mot de
  passe. Menus de reprise et de sortie unifiés avec `terminal ask`, sans dépendre d'Échap.
  Annulation sans suppression automatique ; valeurs vides du planning conservées.
- Heure et intervalle du récapitulatif final affichés en vert comme les autres résultats.

- Ligne vide entre la confirmation du mot de passe et les avertissements de rotation ou
  de remplacement Cloud ; aucun espace supplémentaire sur l'installation initiale.

- Revue des espacements des parcours secondaires : confirmations, mots de passe invalides,
  rotation Cloud, planning conservé désactivé, reprises et annulations. Suppression d'un
  séparateur cumulé sur le parcours d'annulation ; opérations et garde-fous inchangés.

- Espacement console : suppression des cumuls entre inventaire, horaires et mot de passe,
  une ligne entre paragraphes et après les retours Cloud d'installation et de test.

- Avertissements du bloc mot de passe uniformément colorés, sans lignes blanches au milieu
  des paragraphes orange ; consignes et saisies conservées dans leur style normal.

- Suppression Cloud : ciblage par l'identifiant de l'objet déjà trouvé et reconnu, au lieu du
  numéro littéral 0, pour la désinstallation et la rotation du mot de passe. À valider sur RouterOS.
- Désinstallation : diagnostic séparé de la commande Cloud et de sa vérification, catégories
  d'erreur sans affichage du message natif et attente bornée de dix secondes pour constater
  l'absence. L'essai terrain a ensuite isolé un refus de cible ou d'argument par `remove-file`.
- Couleur jaune appliquée aussi à la ligne annonçant la suppression de la sauvegarde Cloud.

- Comptages de tâches silencieux dans l'installateur et le script permanent : suppression
  des nombres parasites issus de `print count-only`, sans retirer les contrôles de concurrence.
- Sorties normales par fin de branche pour quitter, annuler ou terminer la désinstallation,
  sans `return 0` global ; erreurs réelles conservées. Confirmation native encore à réaliser.

### Modifié

- Sous-titres sur trois lignes de 100 caractères : bordures en `#`, ligne médiane bordée
  de `###`, texte centré entre des tirets, tiret supplémentaire à gauche si nécessaire.
  Couleurs et espacement extérieur conservés ; aucun changement fonctionnel.
  Rendu Winbox confirmé par l'utilisateur ; validation retirée du TODO et README actualisé.

- Nouveau cadre final de désinstallation validé par la capture utilisateur : suppressions
  confirmées, message centré et sortie normale.

- Récapitulatifs de fin d'installation, de planning et de désinstallation entièrement encadrés
  de `#` sur 100 caractères ; textes et valeurs centrés, couleurs préservées. Présentation seule.
  Présentation commune acceptée par l'utilisateur après l'essai de désinstallation ; retrait
  des essais visuels redondants du TODO, sans étendre les validations fonctionnelles.

- README actualisé avec le périmètre réellement testé dans Winbox, les validations restantes,
  le récapitulatif du choix 2 et la récupération du verrou après Ctrl+C.
  Conservation d'un scheduler désactivé et récapitulatif du choix 2 confirmés dans Winbox ;
  README et TODO réconciliés avec cette validation.

- Cadre final du choix 2 validé par capture utilisateur avec scheduler actif et planning
  00:00:00 / 6h ; TODO limité à la variante initialement désactivée.

- Choix 2 : récapitulatif final encadré de lignes de 100 caractères `#`, avec heure,
  intervalle et état actif ou désactivé conservé. Aucun test Cloud ni nettoyage supplémentaire.
- Intervalle maximal 1d accepté lors de l'essai utilisateur et fin normale confirmée.

- Horaires validés par capture utilisateur : 25:00:00 refusé, 23:59:59 accepté, 0s et 2d
  refusés sans redemander l'heure. Espacements corrects et annulation sans mutation annoncée.

- Retour arrière pendant le mot de passe validé par l'essai utilisateur, puis confirmation
  acceptée et refus de rotation sans mutation annoncée. TODO limité au test d'expiration.

- Reprise après Ctrl+C confirmée par l'utilisateur : verrou conservé, relance protégée puis
  déblocage manuel selon le README. Ne constitue pas une annulation automatique propre.

- Mot de passe vide : refus et espacement de la nouvelle saisie validés par la capture
  utilisateur. Contrôles visuels restants intégrés aux tests fonctionnels du TODO.

- TODO visuel nettoyé à partir des captures et sorties déjà validées : cadres finaux,
  retours Cloud, confirmations et annulations ; seuls les parcours non testés restent à vérifier.

- Refus d'un mot de passe de 129 caractères et reprise de la saisie validés par l'essai
  utilisateur ; cas retiré du TODO.

- Essais d'annulation validés par les sorties utilisateur : menu principal, saisie de l'heure,
  intervalle, deux saisies du mot de passe, sortie sans nettoyage et refus de désinstallation.
  Sorties normales sans erreur ; TODO réduit aux variantes restant à tester.

- Rotation du mot de passe validée par l'essai utilisateur : recréation Cloud, test du script,
  réactivation et nettoyage réussis ; nouveau mot de passe confirmé dans le script par
  l'utilisateur et planning conservé. Point retiré du TODO ; restauration encore à tester.

- Bannière de début en console fermée à droite et textes centrés sur 100 caractères ;
  bannières des fichiers source inchangées. Rendu validé dans Winbox par l'utilisateur ;
  contrôle retiré du TODO.

- Sous-titres encadrés par deux lignes de tirets ajustées à leur largeur, sans ligne vide
  intérieure, conformément à l'exemple visuel ; couleurs conservées. Rendu validé par
  l'utilisateur dans Winbox ; validation retirée du TODO.

- Choix 2 validé par essai utilisateur et relecture MCP : heure 00:10:00, intervalle 6h,
  scheduler actif et installateur conservé. TODO limité aux variantes encore non testées.

- Essai visuel : ligne horizontale de tirets au-dessus de chaque sous-titre, dans sa couleur,
  séparée du titre par une ligne vide ; aucun marqueur Markdown affiché dans RouterOS.

- Parcours complet d'installation confirmé par la sortie utilisateur, sans compteur parasite
  ni erreur finale ; TODO actualisé. Espacement intérieur des deux cadres finaux couvert
  explicitement par un test sur les commandes d'affichage non normalisées.

- TODO : refus d'un mot de passe trop court et reprise locale de la saisie validés par
  l'essai utilisateur ; autres cas invalides conservés à tester.

- Espacement des cadres finaux resserré à une ligne près des bordures ; ajout d'une ligne
  après OUI et après le retour de suppression Cloud. Désinstallation validée par l'essai
  utilisateur sur RB2011 avec la version 7ddf121, sans erreur finale ni compteur parasite.

- TODO réconcilié avec les essais utilisateur : installation initiale, remplacement de test,
  activation et nettoyage réussis ; suppression Cloud/script/scheduler confirmée au choix 9.
  Les contrôles restants ciblent les dernières corrections, les variantes et les échecs.

- Espacement console doublé entre les blocs et paragraphes, avec lignes vides après les cadres
  de fin ; aucun changement des opérations.

- Choix 1 renommé « Installer ou mettre à jour » dans le menu et la documentation, sans
  changement de fonctionnement.

- Messages de l'installateur colorés : cyan pour les titres, vert pour les succès, jaune pour
  les avertissements et rouge pour les erreurs ; reset ANSI après chaque message, saisies normales.
  Rendu Winbox à valider ; script permanent et opérations de sauvegarde inchangés.

- Fin de désinstallation encadrée par les mêmes séparateurs que la fin d'installation,
  avec des lignes vides pour démarquer le résultat.

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
- README minimal de la sauvegarde Cloud avec le bloc de téléchargement et d'import prévu,
  explicitement marqué comme brouillon jusqu'à la création et publication de l'installateur.
