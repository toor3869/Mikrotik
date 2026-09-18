# État du projet

## Dernière actualisation

2026-09-18

## État actuel

- Présentation publiée et validée par l'utilisateur : 13 sous-titres sur trois lignes de 100 caractères,
  bordures # et ligne centrale ### avec tirets de centrage (supplément à gauche si impair).
  Tests de largeur, centrage, couleur et espacements adaptés ; rendu Winbox validé.

- Dépôt public toor3869/Mikrotik, licence MIT, un dossier autonome par fonction.
- Module travaillé : toor3869_auto-backup-mikrotik-cloud. Seul le fichier .install.rsc est
  distribué ; il embarque la source du script permanent. Aucun secret ni paramètre de site.
- Base publiée avant la correction d'espacement : 259a445759db0a9dc346ac6122fff8c600ded97e.
  Aucun workflow de déploiement ; exécution manuelle depuis le README.
- 55 tests statiques réussis, dont le contrôle des paragraphes d'erreur de désinstallation.
  Ils ne remplacent pas RouterOS.
- Documentation de reprise publiée dans 14b8ba3. Présentation publiée dans 6eda62e :
  trois récapitulatifs finaux entièrement fermés en # et centrés, valeurs variables comprises.
  Rendu Winbox observé pour la désinstallation ; présentation commune acceptée par l'utilisateur
  pour les trois sorties, sans nouvel essai visuel demandé.
  Aucun changement des opérations Cloud.
  Le statut reste expérimental : restauration et cas d'incident non validés.
- Dernière capture utilisateur : choix 2 terminé normalement, scheduler initialement désactivé
  conservé désactivé, planning 00:00:00 / 06:00:00 conservé. Aucune sauvegarde lancée selon
  le récapitulatif. Réactivation du scheduler demandée pour la suite, pas encore confirmée.
- Normalisation globale complète non réalisée ; .gitattributes absent.

## Décisions validées

- Un README, un TODO, un CHANGELOG et les tests dans le dossier de chaque module.
  Le changelog racine contient uniquement les changements transversaux.
- Conventions permanentes dans AGENTS.md ; historique détaillé dans le changelog du module.
- Script installé : toor3869_auto-backup-mikrotik-cloud.rsc.
  Scheduler : toor3869_auto-backup-mikrotik-cloud.
  Sauvegarde : toor3869-auto-backup-mikrotik-cloud.
- Commentaire des deux objets : TOOR3869 -> Sauvegarde automatique chiffree vers MikroTik Cloud.
- Nouvelle installation : date 2026-01-01, heure 00:00:00, intervalle 1h proposés.
  Heure et intervalle modifiables ; intervalle strictement positif et limité à 1d.
- Secret invisible à la saisie, ASCII imprimable de 8 à 128 caractères, enregistré en clair
  dans backupPassword sur le routeur. Aucune dépendance à un gestionnaire de secrets.
- Choix 1 : création initiale sans replace ou remplacement confirmé par REMPLACER.
  Choix 3 : suppression/recréation confirmée par EFFACER en conservant le planning.
  Choix 9 : suppression Cloud, scheduler, script et installateur après OUI.
- Annulation normale par 0 puis Entrée ; aucun nettoyage implicite.
  Expiration après une minute sans touche dans les deux saisies du mot de passe.
- Installation et rotation : test du script avant activation, puis suppression de l'installateur.
  Planning seul : pas de sauvegarde ni de nettoyage, état initial désactivé préservé.
- Ne pas toucher à CPE01 ; les essais de cette séquence concernent le RB2011 de test.

## Travail réalisé

- Refus du choix 9 devant un scheduler au commentaire non reconnu validé par capture utilisateur,
  avant confirmation. Espacement du bloc d'erreur corrigé ; publication demandée par l'utilisateur.
- Refus du choix 9 devant un script au commentaire non reconnu également validé par capture.
  Le nouvel essai utilisait encore la version publiée sans correction d'espacement : ne pas
  redemander ce test fonctionnel. Publier sur demande avant de vérifier le nouveau rendu.

Validations natives issues des captures, sorties console et confirmations utilisateur
sur RB2011 sous RouterOS 7.24.4, réalisées progressivement pendant la préparation :

- Installation initiale : création Cloud, script et scheduler, remplacement de test,
  activation, nettoyage et sortie normale.
- Rotation : nouveau mot de passe confirmé par l'utilisateur dans le script, test Cloud,
  activation et nettoyage réussis. L'agent n'a pas consulté le secret.
- Désinstallation : Cloud, script, scheduler et installateur supprimés, sortie normale.
- Planning actif : changements acceptés, borne 23:59:59 et intervalle 1d acceptés ;
  25:00:00, 0s et 2d refusés. Erreur d'intervalle sans nouvelle demande d'heure.
  Retour final à 00:00:00 / 6h et cadre de fin validés.
- Planning désactivé : conservation de l'état désactivé et récapitulatif correspondant
  validés par capture utilisateur après choix 2 avec valeurs conservées par Entrée.
- Mot de passe : vide, trop court, 129 caractères, non-ASCII et confirmation différente refusés ;
  nouvelles saisies proposées. Retour arrière et collages testés.
- Annulation 0 au menu, aux horaires et aux deux saisies du secret ; refus des confirmations
  de rotation et désinstallation. Sorties normales sans mutation annoncée.
- Expiration d'une minute validée sur les deux saisies, arrivée au menu d'interruption.
- Entrée seule au menu d'interruption : sortie sans nettoyage annoncée et fin normale de
  l'import confirmées par capture utilisateur.
- Fichier d'installation conservé après annulation : présence dans Files confirmée par
  l'utilisateur sans nouveau téléchargement. Conservation après échec technique non vérifiée.
- Cycle automatique à intervalle de 6h confirmé par l'utilisateur : compteurs de lancement
  augmentés et sauvegarde Cloud horodatée à 06:02 après la nuit. Pas de nouveau test demandé.
- Choix 9 depuis le menu d'interruption : accès à la désinstallation et attente de confirmation
  OUI validés par capture utilisateur ; aucune suppression lancée pendant ce contrôle.
- Ctrl+C : arrêt forcé avec verrou restant actif, relance bloquée, puis reprise après libération
  manuelle selon le README. Ce n'est pas une sortie propre automatique.
- Concurrence avec le même compte : second choix 3 refusé pendant la saisie du mot de passe
  puis dans le menu d'interruption du premier installateur, selon les captures utilisateur.
  Menu de reprise après échec technique et comptes distincts restent à vérifier.
- Présentation : bannière console centrée, cadres des sous-titres et de fin, couleurs et
  espacements des parcours testés validés.
- Relecture MCP antérieure du planning actif et de la présence de l'installateur après choix 2.
  Cette relecture précédait la confirmation utilisateur du cycle automatique nocturne.

Causes et corrections utiles à la reprise :

- print count-only affichait des compteurs : remplacé par len/find.
- return 0 au niveau de l'import provoquait une erreur finale : fin normale des branches.
- Suppression Cloud ciblée par l'identifiant find reconnu, pas par le numéro littéral 0.
- Collage non-ASCII interprété comme annulation : consommation jusqu'à Entrée puis refus.
  Codes exacts d'inkey non mesurés ; comportement corrigé validé avec un caractère accentué.
- Expiration ignorée par un contrôle limité aux retours négatifs : délai vérifié après chaque
  retour d'inkey, avant classification du code ; correction à une minute validée.

## Travail restant

- Le TODO du module est la liste de référence des essais restants ; ne pas recréer les tâches
  déjà validées ci-dessus.
- Restent notamment : concurrence, parcours d'incident/reprise, états partiels et objets étrangers,
  restauration et variantes de nettoyage.
- Limites de preuve : acceptation exacte de 128 caractères et droits minimaux non certifiés ;
  ne pas transformer les tests réalisés en garantie exhaustive de compatibilité.
- Publier les dernières actualisations documentaires uniquement sur demande.

## Point de reprise

Sous-titres et présentation commune des cadres validés, tâches retirées du TODO.
Poursuivre avec des tests courts et regroupés ;
inspecter en autonomie ce qui est accessible sans lui demander des copies inutiles.
Ne pas relancer de sauvegarde, désinstallation ou modification de planning sans autorisation.

Tests locaux :
`PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s toor3869_auto-backup-mikrotik-cloud/tests -q`.

## Risques et précautions

- Une sauvegarde réussie ne démontre pas qu'elle peut être restaurée ; restauration non testée.
- Rotation destructive : période sans sauvegarde Cloud si la recréation échoue.
- Le verrou est lié au contexte utilisateur ; ne pas promettre une exclusion entre comptes.
  Ne le libérer manuellement qu'après contrôle d'absence d'installation concurrente.
- Aucun secret dans les sorties, fichiers publics ou diagnostics. Mot de passe visible dans
  le script du routeur aux comptes autorisés, conformément au choix utilisateur.
- Le cache du lien raw main peut retarder une mise à jour : comparer le contenu téléchargé
  avec le fichier publié avant d'annoncer le lien à jour. Ne pas confondre push et déploiement.
