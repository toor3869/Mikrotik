# Tâches à réaliser

## À valider

- [ ] Tester les limites et saisies horaires invalides : borne 23:59:59,
      intervalle nul ou supérieur à 1d, acceptation de 1d et maintien de l'heure déjà validée.
- [ ] Tester le verrou pendant les menus et les lancements concurrents, y compris entre comptes.
- [ ] Tester le menu après interruption : Entrée seule quitte sans nettoyage ; 9 puis Entrée
      rejoint la désinstallation avec nouvel inventaire et confirmation OUI obligatoire.
- [ ] Tester les protections du choix 9 : objets étrangers, jobs actifs, objet modifié pendant
      la confirmation et reprise après désinstallation partielle.
- [ ] Tester la reprise par Entrée après échec réseau, droits insuffisants, création partielle
      ou activation refusée ; vérifier conservation Cloud, absence d'activation indue et affichage.
- [ ] Vérifier le premier cycle planifié.
- [ ] Tester les états partiels, doublons, objets homonymes et mise à jour sans doublon.
- [ ] Tester le planning seul avec un scheduler initialement désactivé : préserver cet état.
- [ ] Vérifier la restauration d'une sauvegarde de test et son ouverture avec le mot de passe saisi.
- [ ] Vérifier la conservation du fichier d'installation après échec ou annulation.
- [ ] Tester le second essai de nettoyage : succès, fichier déjà absent et échec persistant,
      sans nouvelle sauvegarde ni modification du scheduler.

## À faire

- [ ] Finaliser le README après validation des essais ; version publiée encore expérimentale.
