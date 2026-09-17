# Tâches à réaliser

## À valider

- [ ] Valider Échap sur les deux saisies de mot de passe : accès direct au menu d'interruption,
      sans message d'échec ni prompt intermédiaire de réessai.
- [ ] Tester le verrou jusqu'à la sortie, la routine commune de nettoyage et la désinstallation
      après modification d'un objet pendant la confirmation ; vérifier les motifs de refus.

- [ ] Tester le menu après interruption : Entrée/Échap quittent sans nettoyage ; 9 puis Entrée
      rejoint la désinstallation avec nouvel inventaire et confirmation OUI obligatoire.

- [ ] Tester le choix 9 : confirmation OUI, refus des objets étrangers et des jobs actifs,
      suppression Cloud, reprise partielle et nettoyage du fichier après deux essais maximum.

- [ ] Tester la reprise par Entrée après échec Cloud, création partielle et activation refusée ;
      vérifier Échap, conservation Cloud, paramètres saisis et refus des objets étrangers.

- [ ] Tester les reprises de mot de passe : vide, trop court, plus de 128 caractères, non-ASCII,
      confirmation différente et annulation ; vérifier les collages et fins de ligne du terminal.

- [ ] Tester les nouvelles boucles de saisie horaire et intervalle : erreurs répétées, Entrée,
      limites 00:00:00/23:59:59 et 0/1d, rejet au-delà de 1d, maintien de l'heure déjà validée.

- [ ] Valider la syntaxe native et les permissions sur un MikroTik de test autorisé.
- [ ] Tester dans Winbox la saisie invisible, Entrée, Retour arrière, Echap, expiration et Ctrl+C.
- [ ] Tester la première sauvegarde, le remplacement, le test immédiat et le premier cycle planifié.
- [ ] Tester les états partiels, doublons, objets homonymes et réinstallation sans doublon.
- [ ] Tester le planning seul et la rotation du mot de passe avec confirmation de suppression.
- [ ] Simuler un échec réseau, de droits et d'envoi Cloud ; vérifier l'arrêt sans activation indue.
- [ ] Tester les lancements concurrents et préciser la protection entre comptes utilisateurs.
- [ ] Vérifier la restauration d'une sauvegarde de test et son ouverture avec le mot de passe saisi.
- [ ] Tester l'auto-suppression après succès et la conservation après échec, annulation
      ou planning seul.
- [ ] Tester le second essai de nettoyage : succès, fichier déjà absent et échec persistant,
      sans nouvelle sauvegarde ni modification du scheduler.

## À faire

- [ ] Finaliser le README après validation des essais ; version publiée encore expérimentale.
