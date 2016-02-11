# SobokanLike 
Dans un entrepôt divisé en cases carrées, vous incarnez un gardien et devez ranger des caisses sur des cases cibles.

Le joueur peut  se déplacer dans les quatre directions, et pousser (_mais pas tirer_) une seule caisse à la fois. 

Vous trouverez dans cette distribution deux codes réalisés avec le langagePureBasic.

## MainEditor.pb
Ce code permet de créer un niveau pour SobokanLike en plaçant les différentes piéces de la scéne avec l'aide du gardien que vous déplacez avec les fléches de votre clavier.

**Comment placer les élements ?**
* La touche 1 permet de placer un mur
* La touche 2 permet de placer une caisse 
* La touche 8 permet de placer une cible.

N'oubliez pas de placer autant de caisses (ou plus) qu'il y a de cibles.

Quand vous avez terminé la création du niveau, Vous placerez le gardien en position de départ.

Avec la touche Escape, vous quittez l'éditeur de niveau. La sauvegarde du niveau est automatique et se décline en deux fichiers JSON.

-**grid.json** C'est le niveau que vous venez de créer.

-**gridsetup.json** C'est le paramétrage du joueur (Position x & y de départ et direction initial).

##MainPlay.pb
Avec ce code vous allez pouvoir jouer votre unique niveau.

Ces deux codes sont des templates minimum. A vous de créer l'interface permettant de donner un nom au niveau, choisir un niveau, etc ...

## Licence.

La licence MIT donne à toute personne recevant le logiciel le droit illimité de l'utiliser, le copier, le modifier, le fusionner, le publier, le distribuer, le vendre et de changer sa licence. La seule obligation est de mettre le nom des auteurs avec la notice de copyright.
