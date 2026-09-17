# État du projet

## Dernière actualisation

2026-09-17

## État actuel

- Première publication expérimentale autorisée par l'utilisateur pour les essais interactifs.
- Module Cloud autonome : seul l'installateur interactif `.install.rsc` est conservé ; le script
  permanent est embarqué, sans fichier source séparé ni configuration propre à CPE01.
- Douze tests statiques réussis ; aucune validation native de cet installateur réalisée.
- Source embarquée présentée en chaînes concaténées multilignes, sans changement du contenu
  généré ; tests adaptés au décodage et à l'exclusion du bloc dans les contrôles de l'installateur.
- Commentaire identique script/scheduler : `TOOR3869 -> Sauvegarde automatique chiffree vers
  MikroTik Cloud`, texte exact demandé par l'utilisateur, intégré à la création
  ainsi qu'aux contrôles de reconnaissance ; aucun changement sur le routeur.
- Copie de travail uniquement ; source CPE01 et routeur inchangés.
- Conventions des scripts génériques reprises et adaptées dans `AGENTS.md` pour ce dépôt public.
- Normalisation complète du nouveau dépôt non réalisée ; `.gitattributes` absent.

## Décisions validées

- Licence MIT choisie par l'utilisateur ; fichier `LICENSE` préparé localement, non publié.
- Un changement ultérieur de licence ne retire pas les droits des versions déjà distribuées.
- Préparer un installateur réutilisable sur différents sites, public et sans secret embarqué.
- Installation par import manuel ou téléchargement depuis une commande de README.
- Détecter séparément le script, le scheduler et la sauvegarde Cloud existants.
- Prévoir installation, réinstallation, modification du planning ou du mot de passe.
- Planning proposé : date fixe 2026-01-01, heure 00:00:00 et intervalle 1h ; heure et intervalle
  modifiables par saisie interactive, Entrée acceptant la valeur proposée.
- Mot de passe saisi interactivement, conservé dans le script installé et consultable dans Winbox ;
  aucune dépendance à un gestionnaire de secrets externe.
- Première sauvegarde sans replace si absente, validation, installation du script permanent et
  scheduler désactivé, lancement de test du remplacement, activation du scheduler après réussite.
- Ne pas poursuivre silencieusement après un échec, ni créer de doublons.
- Noms finaux : script `toor3869_auto-backup-mikrotik-cloud.rsc`, scheduler
  `toor3869_auto-backup-mikrotik-cloud`. Installateur distinct portant le suffixe `.install.rsc`.
- Un dossier autonome par fonction, sans socle commun requis entre les modules.
- Suppression du doublon `.rsc` demandée : la source embarquée est désormais l'unique référence.
  Essais prévus sur un autre MikroTik ; ne pas toucher à CPE01.
- Nettoyer le fichier d'installation seulement après test réel réussi et scheduler actif.

## Travail réalisé

- Déplacement local vérifié par comparaison binaire, sans exécution ni modification du script.
- Instructions définies pour les bannières MikroTik, le nommage, les commandes multilignes,
  les commentaires des scripts/schedulers, la documentation et les contrôles sans secrets.
- Menu installation/réinstallation, planning seul, rotation du mot de passe et sortie.
- Source permanente embarquée, secret échappé à l'installation ; premier envoi sans replace si
  absent, vérification distante, test immédiat du script avant activation du scheduler.
- Réinstallation par mise à jour en place ; homonymes non reconnus refusés. Rotation destructive
  uniquement après saisie EFFACER. Erreur : maintien du scheduler désactivé, sans rollback Cloud.
- Configuration SMTP CPE01 retirée de ce module public ; résultat écrit dans les logs locaux.
- Identité source/embarqué vérifiée avant suppression du fichier séparé ; installateur inchangé.
  Les tests statiques contrôlent maintenant directement le contenu embarqué.
- Auto-suppression ciblée du fichier canonique à la racine de Files ; planning seul, erreur et
  annulation le conservent. Échec de nettoyage : avertissement sans désactivation du scheduler.

## Travail restant

- Relecture de publication : installateur et source embarquée préparés dans cette conversation ;
  aucune source tierce copiée ni référence figée incluse dans les fichiers publiés.
- Réaliser la matrice d'essais du TODO du module sur une cible explicitement autorisée.
- Vérifier si une rotation par replace permet d'éviter la suppression ; cette V1 conserve le
  scénario suppression/recréation demandé et affiche son risque avant confirmation.
- Ne pas présenter cette première publication de test comme une version validée en production.

## Point de reprise

Premier test interactif autorisé sur l'équipement de test choisi par l'utilisateur ; ne pas importer
sur CPE01. Tests : `python3 -m unittest discover -s toor3869_auto-backup-mikrotik-cloud/tests -v`.

## Risques et précautions

- Contrôler l'absence de secrets avant toute publication de ce dépôt public.
- Toute suppression Cloud demande confirmation ; signaler une période sans sauvegarde si la
  recréation échoue. Ne pas supprimer automatiquement une sauvegarde lors d'une réinstallation.
- Aucun commit, push, déploiement ou nettoyage supplémentaire sans autorisation correspondante.
- Le verrou d'installation peut rester posé après Ctrl+C ; récupération manuelle documentée.
  Il ne garantit pas l'exclusion entre comptes. Les tests locaux ne sont pas un moteur RouterOS.
- Saisie V1 limitée à 8-128 caractères ASCII ; prise en charge réelle du terminal à confirmer.
