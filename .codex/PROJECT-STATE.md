# État du projet

## Dernière actualisation

2026-09-18

## État actuel

- Dernier choix 9 en échec : MCP confirme une sauvegarde Cloud présente et un scheduler Cloud
  désactivé. Aucun nouvel effacement déclenché par l'agent. Cause native non connue.
  Documentation officielle vérifiée : `number=0` est le slot gratuit, pas un numéro de console.
  Diagnostic de suppression détaillé et vérification bornée à dix secondes préparés pour
  publication ; ligne d'avertissement Cloud colorée. Prochain essai manuel du choix 9.

- TODO réconcilié avec les sorties console fournies : parcours initial avec valeurs par défaut,
  double saisie valide, première sauvegarde, remplacement de test, activation et nettoyage réussis.
  Choix 9 : confirmation et suppressions vérifiées ; ancienne sortie « Script Error: 0 » isolée.
  Les dernières corrections restent à tester en natif ; variantes et échecs non encore validés.

- Espacement console augmenté par double `:put "";` ; publication autorisée avec le libellé
  du choix 1 et le TODO réconcilié. Prochain essai utilisateur : choix 9 depuis le README.

- Libellé du choix 1 corrigé en « Installer ou mettre à jour » ; documentation et test du menu
  alignés, sans changement de fonctionnement. Inclus dans cette publication de test.

- Habillage ANSI local : titres cyan, succès verts, avertissements jaunes et erreurs rouges.
  Reset sur chaque message ; opérations de sauvegarde inchangées.
  Publication autorisée avec les corrections de sortie et de comptage ; rendu Winbox à tester.

- Deuxième essai utilisateur : désinstallation sur RB2011 arrivée aux confirmations d'absence
  Cloud, scheduler et script, puis nettoyage. Sortie « Script Error: 0 » corrigée statiquement ;
  ne pas confondre ce défaut de sortie avec une preuve d'échec des suppressions.
  Encadrement du message de fin et branches de sortie normale prêts pour publication.
  Installation suivante réussie selon la console utilisateur : Cloud créé, test de remplacement
  réussi, scheduler activé et installateur supprimé. Pas de nouveau contrôle MCP pendant cette passe.
  Sept comptages de jobs remplacés par `:len [find ...]`, dont un dans le script permanent.
  Trois retours globaux supprimés ; retours des fonctions conservés. Vérification native restante.

- README du module restructuré pour la lecture : sept sections avec sommaire, tableaux courts,
  détails repliables et risques visibles. Documentation uniquement, script inchangé par cette passe.

- Deuxième publication expérimentale autorisée le 2026-09-18 pour les essais sur le RB2011.
  Pas de workflow de construction ni de déploiement : lancement manuel depuis le README.
- Module Cloud autonome : seul l'installateur interactif `.install.rsc` est conservé ; le script
  permanent est embarqué, sans fichier source séparé ni configuration propre à CPE01.
- Quarante et un tests statiques pour la reprise, les diagnostics, les couleurs et l'espacement.
  Premier parcours terminé selon l'utilisateur ; état Cloud,
  script et scheduler contrôlés via MCP. Premier cycle automatique et restauration restent à tester.
- Bannière de début en console intégrée avant le menu ; deuxième parcours à tester en natif.
- Premier menu multilignes intégré selon le texte validé, titre entouré de cinq tirets.
  Inventaire initial intégré : trois libellés alignés, états détectés et scheduler actif/désactivé.
  Bloc horaires/intervalle intégré : boucles indépendantes de saisie, exceptions de conversion
  traitées, valeurs proposées conservées sur Entrée, intervalle dans ]0,1d]. Tests natifs à faire.
  Bloc mot de passe intégré : reprises locales après longueur/caractère invalide, double saisie
  reprise après différence. Échap/Ctrl+C/expiration annulent. Aucun mot de passe affiché.
  Une saisie trop longue est consommée jusqu'à Entrée puis entièrement refusée, jamais tronquée
  en mot de passe accepté ; comportement de collage et touches à vérifier en natif.
- Confirmation OUI retirée ; seules les confirmations de remplacement/suppression d'une
  sauvegarde existante sont conservées. Choix 9 implémenté localement avec confirmation OUI :
  suppression Cloud, scheduler, script et installateur ; objets étrangers et jobs actifs refusés.
  Suppressions vérifiées, reprise partielle possible ; essai RouterOS encore nécessaire.
- Après abandon, proposition 0/9 : sortie sans nettoyage par défaut, 9 puis Entrée redispatche
  vers le même bloc de désinstallation, avec nouvel inventaire et confirmation OUI.
  Pas de suppression sur Échap ; tests de touches à réaliser en natif.
- Revue globale appliquée : annulation de mot de passe distincte d'une panne, verrou détenu
  jusqu'à la sortie finale, nettoyage commun, motifs explicites sans erreur native affichée.
  Désinstallation : inventaire relu après confirmation et objets revérifiés avant suppression.
- Étape première sauvegarde Cloud intégrée : message d'attente, puis succès après vérification.
  Étape installation de l'automatisation intégrée : « Creation du script. » puis
  « Creation du scheduler. » avant chaque opération, selon les textes validés.
  Étape de test du script intégrée selon le texte validé, succès après exécution réussie.
  Étape d'activation intégrée, « Sauvegarde automatique en service. » après relecture active.
  Le parcours planning seul préserve toujours un scheduler initialement désactivé.
  Nettoyage : titre et annonce courte validés, sans message de succès supplémentaire ;
  suppression ciblée, seconde tentative automatique avec nouvelle recherche du fichier ;
  message « Nettoyage incomplet » seulement après échec persistant. Aucun nouveau test Cloud.
  Récapitulatif final encadré intégré, valeurs choisies conservées hors du bloc principal ;
  affichage après test/activation et nettoyage sans erreur, absent pour le planning seul.
  Présentation des parcours de remplacement/recréation encore à revoir avec l'utilisateur.
  Aucun nouveau déploiement sur un routeur pendant cette préparation.
- Source embarquée présentée en chaînes concaténées multilignes, sans changement du contenu
  généré ; tests adaptés au décodage et à l'exclusion du bloc dans les contrôles de l'installateur.
- Commentaire identique script/scheduler : `TOOR3869 -> Sauvegarde automatique chiffree vers
  MikroTik Cloud`, texte exact demandé par l'utilisateur, intégré à la création
  ainsi qu'aux contrôles de reconnaissance ; aucun changement sur le routeur.
- Publication de la préparation demandée ; source CPE01 et routeurs inchangés.
- Conventions des scripts génériques reprises et adaptées dans `AGENTS.md` pour ce dépôt public.
- Normalisation complète du nouveau dépôt non réalisée ; `.gitattributes` absent.

## Décisions validées

- Licence MIT choisie par l'utilisateur ; fichier `LICENSE` présent dans le premier commit publié.
- Un changement ultérieur de licence ne retire pas les droits des versions déjà distribuées.
- Préparer un installateur réutilisable sur différents sites, public et sans secret embarqué.
- Installation par import manuel ou téléchargement depuis une commande de README.
- Détecter séparément le script, le scheduler et la sauvegarde Cloud existants.
- Prévoir installation, réinstallation, modification du planning ou du mot de passe.
- Planning proposé : date fixe 2026-01-01, heure 00:00:00 et intervalle 1h ; heure et intervalle
  modifiables par saisie interactive, Entrée acceptant la valeur proposée.
- Intervalle limité à un jour dans cet installateur ; une valeur héritée supérieure à un jour
  n'est pas modifiée implicitement en mode mot de passe et provoque le refus avant mutation.
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
- Nettoyer le fichier d'installation après test réel réussi et scheduler actif, ou en dernier
  après désinstallation explicitement confirmée avec OUI et suppressions vérifiées.

## Travail réalisé

- Reprise locale après erreur : Entrée refait l'inventaire, réutilise les saisies validées et
  conserve le Cloud déjà vérifié si ses métadonnées concordent. Échap rejoint le menu de sortie,
  sans nettoyage par défaut ; choix 9 explicite et confirmation OUI pour désinstaller.
  Traitement d'erreur limité au scheduler reconnu, avec nouvelle recherche et contrôle d'arrêt.
  Vérification des jobs avant et après désactivation ; aucun job interrompu automatiquement.
  Tests natifs de reprise encore requis ; aucun déploiement ni changement sur CPE01.

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

Deuxième passe interactive sur le RB2011 depuis le README publié ; ne pas importer sur CPE01.
Tests : `python3 -m unittest discover -s toor3869_auto-backup-mikrotik-cloud/tests -v`.

## Risques et précautions

- Contrôler l'absence de secrets avant toute publication de ce dépôt public.
- Toute suppression Cloud demande confirmation ; signaler une période sans sauvegarde si la
  recréation échoue. Ne pas supprimer automatiquement une sauvegarde lors d'une réinstallation.
- Aucun commit, push, déploiement ou nettoyage supplémentaire sans autorisation correspondante.
- Le verrou d'installation peut rester posé après Ctrl+C ; récupération manuelle documentée.
  Il ne garantit pas l'exclusion entre comptes. Les tests locaux ne sont pas un moteur RouterOS.
- Saisie V1 limitée à 8-128 caractères ASCII ; prise en charge réelle du terminal à confirmer.
