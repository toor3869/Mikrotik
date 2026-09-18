<h1 align="center">Sauvegarde automatique MikroTik Cloud</h1>
<h3 align="center">VERSION 2026-09-18 - BY TOOR3869</h3>
<h4 align="center">Source : https://github.com/toor3869/Mikrotik</h4>

&nbsp;

Un installateur interactif pour créer une sauvegarde chiffrée et programmer son renouvellement.

> **Version expérimentale — essais uniquement.**
> Cette deuxième version est prête pour les essais, mais reste à valider sur RouterOS.
> La commande de lancement télécharge la version actuellement publiée sur `main`.

- [01 Lancement](#01-lancement)
- [02 Menu](#02-menu)
- [03 Paramètres](#03-paramètres)
- [04 Désinstallation](#04-désinstallation)
- [05 En cas de problème](#05-en-cas-de-problème)
- [06 Détails pratiques](#06-détails-pratiques)
- [07 Sources](#07-sources)

&nbsp;

## 01 Lancement

**Sur le MikroTik à configurer, dans le terminal de Winbox.**

Prévoir un compte administrateur, RouterOS 7 avec `terminal ask` et `terminal inkey`,
ainsi qu'une heure et des certificats de confiance permettant la connexion HTTPS.
Les permissions exactes et la compatibilité restent à valider sur la cible de test.

Copier le bloc entier :

```routeros
{
    /tool fetch \
        url="https://raw.githubusercontent.com/toor3869/Mikrotik/main/toor3869_auto-backup-mikrotik-cloud/toor3869_auto-backup-mikrotik-cloud.install.rsc" \
        check-certificate=yes \
        dst-path="toor3869_auto-backup-mikrotik-cloud.install.rsc" \
    ;
    /import \
        file-name="toor3869_auto-backup-mikrotik-cloud.install.rsc" \
    ;
}
```

Le fichier est téléchargé puis exécuté. Si le téléchargement échoue, l'import ne démarre pas.
Suivre ensuite les questions affichées dans le terminal.

L'habillage couleur distingue les titres (cyan), succès (vert), avertissements
(jaune) et erreurs (rouge). Les explications et saisies gardent le style normal.
Les séquences ANSI sont réinitialisées après chaque message ; leur rendu reste à tester dans Winbox.

&nbsp;

## 02 Menu

| Choix | Action |
| :---: | --- |
| **1** | Installer ou mettre à jour la sauvegarde automatique |
| **2** | Modifier les horaires et l'intervalle |
| **3** | Changer le mot de passe de la sauvegarde |
| **9** | Désinstaller et nettoyer, **sauvegarde Cloud comprise** |
| **0** | Quitter sans modification |

Lors d'une première installation, l'outil crée la sauvegarde Cloud, installe le script et
le scheduler, puis exécute un test réel avant d'activer l'automatisation.

Sur une installation existante, le choix 1 met à jour les éléments en place et remplace la
sauvegarde après confirmation `REMPLACER`, sans suppression préalable.
La première création et le changement d'horaires ne demandent pas de confirmation `OUI`.

&nbsp;

## 03 Paramètres

| Paramètre | Proposition pour une nouvelle installation | Valeurs |
| --- | --- | --- |
| Heure de départ | `00:00:00` | `HH:MM:SS`, de `00:00:00` à `23:59:59` |
| Intervalle | `1h` | Supérieur à zéro, maximum `1d` / `24h` |
| Date de départ | `2026-01-01` | Fixée par l'installateur |

**Entrée conserve la valeur proposée.** Un planning existant est proposé à la place des valeurs
initiales. Une erreur redemande uniquement le champ concerné.

Exemples d'intervalles : `30m`, `1h`, `6h`, `1h30m` ou `1d`.

**Mot de passe**

- Saisie invisible, demandée deux fois.
- De 8 à 128 caractères ASCII imprimables.
- Saisie invalide ou confirmation différente : nouvelle saisie, sans refaire le planning.
- Une saisie trop longue ou non ASCII est refusée, jamais tronquée.

> **Conserver le mot de passe : il est nécessaire à la restauration.**
> Il est enregistré en clair dans la variable `backupPassword` du script installé.
> Les utilisateurs autorisés à lire ce script peuvent donc le consulter.

Le choix **3** conserve le planning mais demande `EFFACER` pour supprimer puis recréer la
sauvegarde avec le nouveau mot de passe. **Un échec de recréation peut laisser le routeur sans
sauvegarde Cloud.** Un ancien intervalle supérieur à un jour doit d'abord être corrigé via le choix 2.

&nbsp;

## 04 Désinstallation

> **Le choix 9 supprime aussi la sauvegarde Cloud, sans en conserver de copie de secours.**

La saisie exacte **`OUI`** est obligatoire. Toute autre réponse annule.

Après contrôle des objets, l'outil désactive le scheduler, vérifie qu'aucune sauvegarde ne tourne,
puis supprime la sauvegarde Cloud, le scheduler, le script et enfin le fichier d'installation.
Chaque suppression est vérifiée.

Les objets étrangers, les homonymes non reconnus et les sauvegardes en cours sont refusés.
L'inventaire est relu après confirmation ; une modification concurrente détectée bloque l'étape.

Une erreur arrête la procédure **sans annuler les suppressions déjà réalisées**.
Le choix 9 peut être relancé pour traiter les éléments restants. Aucun job n'est interrompu.

&nbsp;

## 05 En cas de problème

**Annuler**

Tapez **0 puis Entrée** pendant la saisie de l'heure, de l'intervalle ou du mot de passe
pour rejoindre le menu d'interruption. Seul le mot de passe exact `0` annule ; les mots de
passe contenant des zéros restent acceptés. Une saisie vide conserve le planning proposé,
mais n'autorise jamais un mot de passe vide. Ne pas compter sur Échap dans Winbox.
Un refus de remplacement rejoint aussi ce menu ; un refus de désinstallation quitte sans agir.

- **0 puis Entrée, ou Entrée seule** : quitter sans nettoyage.
- **9 puis Entrée** : proposer la désinstallation, avec confirmation `OUI` obligatoire.

**Reprendre après une erreur**

Entrée relance un inventaire et une tentative ; **0 puis Entrée** rejoint le menu d'interruption.
Ces menus attendent une réponse explicite ; la saisie invisible du mot de passe conserve son
délai d'une minute sans touche. Aucune annulation ne supprime automatiquement des éléments.

Les paramètres validés sont conservés. Une sauvegarde déjà vérifiée dans la session est
réutilisée si son nom, son état, sa date et sa taille concordent encore. Sinon, les confirmations
de remplacement ou suppression restent nécessaires. Le script est retesté avant activation.

Après une modification incomplète, le scheduler est maintenu désactivé autant que les permissions
le permettent. **Ne pas le réactiver sans vérifier la sauvegarde.**

**Nettoyage incomplet**

Le nettoyage tente deux fois de supprimer uniquement le fichier d'installation.
Un fichier déjà absent est considéré comme nettoyé. Un échec persistant affiche un avertissement,
sans relancer la sauvegarde ni désactiver une automatisation validée.

<details>
<summary>Verrou conservé après une interruption forcée</summary>

Ne pas lancer plusieurs installations ou une sauvegarde manuelle en parallèle.
Le verrou couvre toute la session, menus et nettoyage compris, mais reste lié au contexte
utilisateur : il ne garantit pas l'exclusion entre comptes.

**Avant de le libérer, vérifier qu'aucune installation n'est encore en cours.**
Dans le terminal RouterOS du même utilisateur :

```routeros
:global toor3869CloudInstallerLock; :set toor3869CloudInstallerLock false;
```

</details>

&nbsp;

## 06 Détails pratiques

<details>
<summary>Fichiers et objets créés</summary>

- Installateur : `toor3869_auto-backup-mikrotik-cloud.install.rsc`
- Script installé : `toor3869_auto-backup-mikrotik-cloud.rsc`
- Scheduler : `toor3869_auto-backup-mikrotik-cloud`

L'installateur embarque le script permanent : aucun second fichier n'est à télécharger.
Il ne migre pas automatiquement une ancienne installation non reconnue.

Après installation ou changement de mot de passe réussi, l'installateur se supprime après
test réel et activation vérifiée. Il est conservé après erreur, annulation ou planning seul,
sauf désinstallation explicitement confirmée.

Le nettoyage concerne uniquement son nom exact à la racine de Files.
Un fichier renommé ou placé dans un sous-dossier n'est pas supprimé.

</details>

<details>
<summary>Installation manuelle depuis Files</summary>

Déposer l'installateur à la racine de Files, sans le renommer, puis lancer dans le terminal RouterOS :

```routeros
/import file-name=toor3869_auto-backup-mikrotik-cloud.install.rsc;
```

</details>

<details>
<summary>Journaux et confidentialité</summary>

Le script permanent journalise le résultat localement, sans mot de passe ni clé de téléchargement.
Il n'envoie pas de mail et ne dépend d'aucune configuration SMTP.

Les refus connus affichent des motifs prédéfinis ; les erreurs natives ne sont pas reproduites
pour éviter d'exposer des secrets.

</details>

&nbsp;

## 07 Sources

Documentation officielle MikroTik :

- [Sauvegarde Cloud](https://help.mikrotik.com/docs/spaces/ROS/pages/97779929/Cloud)
- [Téléchargement — Fetch](https://help.mikrotik.com/docs/spaces/ROS/pages/8978514/Fetch)
- [Import de configuration](https://help.mikrotik.com/docs/spaces/ROS/pages/328155/Configuration+Management)
- [Langage de script](https://help.mikrotik.com/docs/spaces/ROS/pages/47579229/Scripting)
- [Scheduler](https://help.mikrotik.com/docs/spaces/ROS/pages/40992881/Scheduler)
