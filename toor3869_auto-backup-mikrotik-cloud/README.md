<h1 align="center">Sauvegarde automatique MikroTik Cloud</h1>
<h3 align="center">VERSION 2026-09-17 - BY TOOR3869</h3>
<h4 align="center">Source : https://github.com/toor3869/Mikrotik</h4>

&nbsp;

- [01 Lancement](#01-lancement)

&nbsp;

## 01 Lancement

Dans le terminal RouterOS de Winbox, sur le MikroTik à configurer.

**Version expérimentale pour essais — non validée sur RouterOS. Ne pas lancer en production.**
La commande ci-dessous utilise la version publiée sur la branche `main`.
Le reste de cette documentation sera complété après les essais.

Installateur : `toor3869_auto-backup-mikrotik-cloud.install.rsc`.
Script installé : `toor3869_auto-backup-mikrotik-cloud.rsc`.
Scheduler : `toor3869_auto-backup-mikrotik-cloud`.

Le dépôt ne contient qu'un fichier RouterOS : l'installateur autonome. Il embarque le script
permanent et le crée dans Winbox ; aucun second fichier n'est à télécharger.

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

Le bloc télécharge l'installateur en HTTPS puis l'exécute ; une erreur de téléchargement
interrompt le bloc avant l'import. L'heure et les certificats de confiance du routeur doivent
permettre la validation HTTPS. Conserver le nom exact de l'installateur et le placer à la racine
de Files pour permettre son nettoyage automatique.

Après une installation/réinstallation ou un changement de mot de passe réussi, l'installateur
supprime uniquement son propre fichier, après le test du script et la confirmation du scheduler actif.
En cas d'échec, d'annulation ou de modification du planning seul, le fichier est conservé.
Un échec du nettoyage produit un avertissement sans désactiver la sauvegarde validée.
Un fichier renommé ou placé dans un sous-dossier n'est pas recherché ni supprimé automatiquement.

Pour les futurs essais par dépôt manuel dans Files, importer uniquement l'installateur :

```routeros
/import file-name=toor3869_auto-backup-mikrotik-cloud.install.rsc;
```

Prévoir un compte administrateur et RouterOS 7 avec `terminal ask` et `terminal inkey`.
La compatibilité et les permissions exactes restent à valider sur la version de test.
Le menu propose installation/réinstallation, planning, changement du mot de passe ou sortie.
Le mot de passe est saisi deux fois sans écho, puis conservé dans la source installée, visible
aux administrateurs. Cette première version accepte 8 à 128 caractères ASCII imprimables.
Le planning neuf propose `2026-01-01`, `00:00:00` et `1h`. Un planning existant est proposé
par défaut ; le mode mot de passe en conserve l'heure et l'intervalle.

Une réinstallation remplace la sauvegarde avec confirmation, sans suppression préalable.
Le choix de changement du mot de passe demande `EFFACER` avant suppression/recréation Cloud :
un échec après suppression peut laisser le routeur sans sauvegarde. Un objet homonyme non reconnu
est refusé : cette première version ne migre pas automatiquement une ancienne installation.
Après un échec ayant commencé à modifier la configuration, le scheduler reste désactivé
autant que les permissions le permettent. Ne pas le réactiver sans vérifier la sauvegarde.
Le script permanent n'envoie pas de mail et ne dépend d'aucune configuration SMTP ; il journalise
le résultat sans mot de passe ni clé de téléchargement.

Ne pas lancer plusieurs installations ni une sauvegarde manuelle pendant l'installation.
Le verrou global est lié au contexte utilisateur ; il ne garantit pas l'exclusion entre comptes.
Après une interruption forcée, vérifier l'absence de toute installation en cours avant de libérer
le verrou dans le terminal du même utilisateur :

```routeros
:global toor3869CloudInstallerLock; :set toor3869CloudInstallerLock false;
```

Références : [Fetch](https://help.mikrotik.com/docs/spaces/ROS/pages/8978514/Fetch) et
[Import RouterOS](https://help.mikrotik.com/docs/spaces/ROS/pages/328155/Configuration+Management),
[Cloud](https://help.mikrotik.com/docs/spaces/ROS/pages/97779929/Cloud),
[Scripting](https://help.mikrotik.com/docs/spaces/ROS/pages/47579229/Scripting) et
[Scheduler](https://help.mikrotik.com/docs/spaces/ROS/pages/40992881/Scheduler).
