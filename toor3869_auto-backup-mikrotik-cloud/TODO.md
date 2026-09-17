# Tâches à réaliser

## À valider

- [ ] Valider dans Winbox les cadres des sous-titres : deux bordures ajustées, sans vide intérieur.
- [ ] Vérifier le dernier ajustement visuel : une ligne vide à l'intérieur des bordures du cadre,
      une après OUI et les retours Cloud ; aucun cumul entre inventaire, horaires et mot de passe.
- [ ] Vérifier les espacements des confirmations, reprises, erreurs et annulations lors des
      essais des parcours secondaires ci-dessous.
- [ ] Vérifier les sorties après choix 0 et annulation : absence de « Script Error: 0 ».
- [ ] Tester Échap sur les deux saisies de mot de passe : accès direct au menu d'interruption,
      sans message d'échec ni prompt intermédiaire de réessai.
- [ ] Tester les saisies de mot de passe invalides : vide, trop long, non-ASCII
      et confirmation différente ; vérifier Retour arrière, collage, expiration et Ctrl+C.
- [ ] Tester les limites et saisies horaires invalides : borne 23:59:59,
      intervalle nul ou supérieur à 1d, acceptation de 1d et maintien de l'heure déjà validée.
- [ ] Tester le verrou pendant les menus et les lancements concurrents, y compris entre comptes.
- [ ] Tester le menu après interruption : Entrée/Échap quittent sans nettoyage ; 9 puis Entrée
      rejoint la désinstallation avec nouvel inventaire et confirmation OUI obligatoire.
- [ ] Tester les protections du choix 9 : objets étrangers, jobs actifs, objet modifié pendant
      la confirmation, refus sans suppression indue et reprise après désinstallation partielle.
- [ ] Tester la reprise par Entrée après échec réseau, droits insuffisants, création partielle
      ou activation refusée ; vérifier conservation Cloud et absence d'activation indue.
- [ ] Vérifier le premier cycle planifié.
- [ ] Tester les états partiels, doublons, objets homonymes et mise à jour sans doublon.
- [ ] Tester le planning seul avec un scheduler initialement désactivé : préserver cet état.
- [ ] Tester la rotation du mot de passe avec confirmation de suppression.
- [ ] Vérifier la restauration d'une sauvegarde de test et son ouverture avec le mot de passe saisi.
- [ ] Vérifier la conservation du fichier d'installation après échec ou annulation.
- [ ] Tester le second essai de nettoyage : succès, fichier déjà absent et échec persistant,
      sans nouvelle sauvegarde ni modification du scheduler.

## À faire

- [ ] Finaliser le README après validation des essais ; version publiée encore expérimentale.
