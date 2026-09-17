# 0004 — Le CV en PDF est généré par l'API, pas par chaque client

**Statut** : Accepté · **Date** : 2026-09-17

## Contexte

Le portfolio doit fournir un CV en PDF. Deux clients doivent pouvoir le donner :
le site web, et l'application iOS.

Une première approche mettait une **feuille de style d'impression** dans le site :
`Cmd+P` reformatait la page en CV A4. Elle a un vrai mérite — le contenu imprimé
étant le DOM de la page, il ne peut pas diverger d'elle.

Elle a surtout un défaut rédhibitoire : **elle n'existe que sur le web.**
L'application iOS n'a pas de feuille de style d'impression. Si elle devait
produire un CV, elle le redessinerait avec ses propres moyens — et on aurait
**deux CV différents** pour une seule personne, ce qui est exactement le
problème qu'on voulait éviter.

## Décision

**La génération du PDF vit dans `portfolio-api`.** Elle produit **un seul
fichier**, servi en **blob** aux deux clients, qui ne font que le relayer.

```
contenu (source unique)
        │
        ▼
  portfolio-api ── gabarit de CV ── rendu ──► blob PDF (+ ETag)
        │
        ├──────────────► web  : un lien de téléchargement
        └──────────────► iOS  : téléchargement puis partage natif
```

**Le rendu est déclenché par le changement de contenu, pas par la requête.** Le
PDF est fabriqué quand le contenu change, stocké, puis servi comme un fichier
statique validé par `ETag`. Une requête de lecture ne paie donc jamais le coût
d'un rendu, et le démarrage à froid de l'API n'a aucun effet sur le temps de
téléchargement.

Une version par langue : `fr` et `en`, dérivées du même contenu.

## Conséquences

**Ce qu'on gagne.** Un seul moteur de rendu, donc un seul résultat. Le CV que
télécharge un recruteur depuis l'app iOS est **le même octet** que celui du site.
Ajouter un troisième client ne coûte rien — il relaie le même blob.

**Ce que ça coûte.** Le gabarit du CV devient du code dans l'API, et non plus du
CSS partagé avec le site. Il faut donc que **la mise en page du PDF et celle du
site boivent à la même source de design** — les tokens générés — sinon on a
déplacé le risque de dérive du contenu vers la forme.

**Ce qu'il faut tenir.** La feuille de style d'impression du site est
**retirée**. Garder les deux, c'est garder deux CV : celui qu'on imprime et celui
qu'on télécharge, qui se ressembleraient au début puis plus du tout. Le site
imprimé reste évidemment lisible — ce n'est simplement plus « le CV ».

## Alternatives écartées

**Feuille de style d'impression côté web uniquement.** Zéro infrastructure, et
aucune dérive de *contenu* possible. Écartée pour une seule raison, mais elle
suffit : l'app iOS ne peut pas s'en servir, donc elle ne résout pas le problème
posé.

**Génération à la demande, à chaque requête.** Plus simple à écrire. Écartée :
sur une API qui descend à zéro instance, le premier téléchargement paierait le
démarrage du moteur de rendu. Un recruteur qui clique sur « CV » et attend huit
secondes est un recruteur qu'on a perdu.

**Un PDF écrit à la main et déposé à côté.** Écartée sans discussion : c'est
littéralement la deuxième source de vérité qu'on refuse partout ailleurs. Il
mentirait dès la première mise à jour du portfolio.
