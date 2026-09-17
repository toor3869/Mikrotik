# Instructions propres au dépôt Mikrotik

## Périmètre et organisation

- Ce dépôt public contient les scripts génériques de déploiement TOOR3869, réutilisables sur
  différents sites. Ne pas y importer les paramètres privés d'un équipement ou de l'infrastructure.
- Pour les configurations correspondant à un menu RouterOS, nommer le dossier avec des mots
  séparés par `_`, sans espaces, par exemple `System_NTP_Client`.
- Nommer leurs variantes `<nom_du_dossier>_XX_<precision>.rsc`, avec exactement la casse du
  dossier, un numéro sur deux chiffres et une précision sans espaces. Exemple :
  `System_NTP_Client_01_fr.pool.ntp.org.rsc`. Ce numéro n'autorise aucun ordre d'exécution.
- Pour une automatisation nommée, conserver un dossier portant le nom du script sans extension,
  avec le préfixe `toor3869_`. Le dossier existant `toor3869_auto-backup-mikrotik-cloud` respecte
  cette convention ; ne pas lui ajouter de préfixe numérique ni de niveau `Scripts/`.
- Regrouper les variantes, la documentation et les tests dans leur dossier fonctionnel. Ne pas
  créer de dossiers par équipement, de répertoire `docs/` doublonnant les README ou de copies inutiles.
- Vérifier les appelants, noms installés et importeurs lors d'un renommage autorisé. Les règles
  ne constituent pas une autorisation de renommage ou de reformatage global.
- Pour le module Cloud, conserver uniquement le fichier `.install.rsc` : sa source embarquée
  est la référence du script permanent. Ne pas recréer un fichier `.rsc` séparé en doublon.
  Les tests décodent et contrôlent directement cette source, y compris sa bannière et son nom final.

## Bannières des scripts MikroTik

- Exception locale au modèle global centré : utiliser exclusivement le modèle aligné à gauche
  ci-dessous pour les sources RouterOS TOOR3869, les installateurs et les importeurs `.rsc`.
- Conserver exactement sept lignes sans indentation : lignes 1 et 7 égales à 100 caractères `#`,
  lignes 2 et 6 égales à `#####`, ligne 3 exactement égale à `##### Mikrotik Script`.
- Ligne 4 : `##### ` suivi du nom réel complet du fichier, extension comprise.
- Ligne 5 : `##### VERSION YYYY-MM-DD - BY TOOR3869`. Actualiser uniquement la date lors d'une
  modification réelle ; les autres lignes fixes ne changent pas.
- La ligne 8 est entièrement vide et le contenu commence à la ligne 9.
- Ne pas centrer le texte, ajouter de bordure à droite ou utiliser des espaces de remplissage.
  La largeur de 100 caractères concerne uniquement les bordures.

```text
####################################################################################################
#####
##### Mikrotik Script
##### toor3869_auto-backup-mikrotik-cloud.rsc
##### VERSION 2026-09-17 - BY TOOR3869
#####
####################################################################################################
```

- En fin de script, après la dernière ligne de contenu : exactement une ligne vide, une ligne
  de 100 caractères `#`, puis une dernière ligne vide. Le séparateur final est suivi de deux LF.
- Vérifier automatiquement les sept lignes, le nom réel du fichier, la date, la ligne 8 vide,
  le début du contenu et la terminaison. Ne pas appliquer les tests de centrage des dépôts Docker.
- Dans un importeur, la bannière extérieure porte son propre nom ; celle de la source embarquée
  conserve le nom du script source. Synchroniser la source et son importeur après modification.
- Ne pas appliquer ces bannières aux Markdown, références figées ou sources tierces. Une copie
  ou un déplacement à contenu identique n'autorise pas leur reformatage.

## Présentation et syntaxe RouterOS

- Conserver des sources lisibles, indentées, en UTF-8 sans BOM et avec des fins de ligne LF.
- Écrire les scripts, commentaires et messages en français sans accents, en ASCII. La
  documentation Markdown peut conserver ses accents. Ne pas altérer une donnée externe ou un secret
  pour satisfaire cette règle ; traiter explicitement les contraintes d'encodage correspondantes.
- Pour les commandes simples génériques, placer le chemin RouterOS et l'action sur la première
  ligne, puis chaque paramètre ou élément de liste sur sa propre ligne, même pour un seul élément.
- Terminer les lignes poursuivies par `\`, sans espace après. Conserver les virgules des listes
  immédiatement avant `\`, sauf pour le dernier élément. Terminer le dernier argument par une
  espace puis `\`, puis placer le seul `;` sur la dernière ligne.
- Le point-virgule est une convention de présentation, pas une obligation lorsque le retour à
  la ligne termine déjà la commande. Exemple :

```routeros
/ip service disable \
api,\
api-ssl,\
ftp \
;
```

- Ne pas appliquer mécaniquement cette présentation aux chaînes, expressions ou blocs. Préserver
  les valeurs, guillemets, séparateurs, ordre et espaces significatifs ; ne pas convertir une liste
  en plusieurs commandes. Placer les commentaires hors des commandes poursuivies.
- Vérifier la commande logique reconstituée ; distinguer contrôle statique et exécution RouterOS.
- Pour compter les objets sans affichage, utiliser `:len [find ...]`, pas `print count-only` :
  ce dernier peut afficher les compteurs internes dans la console pendant un import.
- Terminer normalement les branches d'un installateur importé ; ne pas utiliser `:return 0`
  comme sortie globale. Réserver les retours de valeur aux fonctions et les erreurs aux échecs.
- Ne jamais compacter le corps d'un script. Distinguer le fichier source de sa sérialisation dans
  `source="..."` : des séparateurs encodés en `\r\n` peuvent préserver les lignes dans Winbox.
  Une API attendant le corps brut doit recevoir de vrais retours à la ligne.
- Échapper correctement guillemets, antislashs et dollars à chaque couche, sans double encodage.
  Ne jamais remplacer globalement les `\n` applicatifs, notamment ceux des messages.
- Une relecture API ne suffit pas à certifier le rendu visuel de l'éditeur Winbox.
- Pour l'affichage de l'installateur : une ligne vide entre les parties d'une étape, deux entre
  les étapes. Ne pas cumuler les séparateurs de fin et de début de deux étapes successives.
  Dans les cadres finaux, conserver une seule ligne vide près des bordures et entre paragraphes,
  deux à l'extérieur. Tester les vrais `:put` avant toute normalisation du texte par les tests.
- Encadrer chaque sous-titre console par deux lignes de tirets, immédiatement au-dessus et
  au-dessous, sans ligne vide dans ce cadre. Leur longueur égale celle du titre `----- Texte -----`
  et leur couleur est identique au titre. Ne pas remplacer ce cadre par une ligne isolée.
- Pour la bannière de début affichée en console uniquement, utiliser sept lignes de 100
  caractères : bordures pleines, intérieur de 90 caractères entre cinq `#` de chaque côté.
  Centrer les trois textes, avec l'espace supplémentaire à gauche si nécessaire ; conserver
  les deux lignes intérieures vides bordées. Les bannières des sources restent alignées à gauche.

## Installation, commentaires et sécurité

- Renseigner un `comment` descriptif, sans accents ni secret, sur chaque script et chaque scheduler
  créé ou travaillé. Conserver ces commentaires dans les installateurs/importeurs correspondants.
- Une modification du seul commentaire ne doit pas désactiver le script ou le scheduler, modifier
  ses droits, son planning ou son comportement. Respecter les autorisations de la cible.
- Préserver les noms installés préfixés `toor3869_` et vérifier leurs références dans les schedulers.
- Ne jamais embarquer de mot de passe, jeton, clé privée ou configuration sensible dans ce dépôt
  public. Contrôler les fichiers destinés à Git sans afficher les valeurs sensibles.
- Les secrets saisis pendant une installation ne doivent apparaître ni dans les journaux ni dans
  la documentation. Leur conservation locale suit le scénario validé, pas un stockage public.
- Ne pas recopier les paramètres CPE01 sur d'autres sites ; garder les scripts portables.
- Aucun import, lancement, déploiement, suppression Cloud, commit ou push sans autorisation
  correspondante. Une préparation locale ne constitue pas une validation en production.
- Dans l'installateur Cloud, distinguer une annulation de saisie d'un échec technique :
  l'annulation rejoint le menu de sortie, sans imposer le prompt de nouvelle tentative.
- Conserver le verrou pendant toute la session, menus de reprise et nettoyage compris ;
  ne le libérer que sur une sortie finale contrôlée. Documenter séparément l'arrêt forcé.
- Réutiliser la routine de nettoyage ciblée pour installation et désinstallation. Après un prompt
  destructif, relire les objets et leurs marqueurs avant mutation ; ne pas réutiliser aveuglément
  les identifiants antérieurs. Afficher des motifs prédéfinis, jamais l'erreur native potentiellement
  sensible. Couvrir ces contrats par des tests sans prétendre remplacer les essais RouterOS.

## Documentation et contrôles

- Lors du travail fonctionnel sur une automatisation, maintenir dans son dossier un `README.md`
  humain et concis, un `TODO.md` limité aux actions restantes et des tests sous `tests/`.
  Documenter les fichiers réellement présents ; ne pas inventer d'importeur ou de commande publiée.
- Réserver `AGENTS.md` aux règles, `.codex/PROJECT-STATE.md` à l'état et au point de reprise,
  et `CHANGELOG.md` à l'historique. Ne pas doubler le README par un second document du même rôle.
- Pour les TODO, limiter les lignes à 100 caractères et indenter les continuations de six espaces.
  Retirer les tâches terminées uniquement après vérification ; ne pas inventer de tâches de remplissage.
- Contrôler les bannières, ASCII, UTF-8/LF, noms, commentaires, références et concordance entre
  source et importeur lorsque celui-ci existe. Tester aussi les chemins d'échec, reprises,
  doublons et échappements lorsque le fonctionnement concerné est implémenté.
- Préserver les références tierces et copies figées ; ne pas leur appliquer nos conventions.
- Actualiser le suivi dans la même séquence et vérifier le diff final. Ne pas annoncer une
  validation RouterOS à partir des seuls tests locaux.
