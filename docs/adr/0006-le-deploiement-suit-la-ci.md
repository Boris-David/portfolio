# 0006 — Le déploiement suit la CI, il ne court pas à côté d'elle

**Statut** : Accepté · **Date** : 2026-09-18
**Complète** : [l'ADR 0005](0005-tout-sur-cloudflare.md), dont il rend vraie une
affirmation qui ne l'était pas.

## Contexte

L'ADR 0005 écrivait : *« une modification fusionnée déclenche son déploiement […]
une à deux minutes, **sans aucune action humaine** »*.

C'était une intention, pas une description. Les deux workflows de déploiement ne
se déclenchaient que sur `workflow_dispatch` — à la main.

Le défaut s'est manifesté le 2026-09-17. Le renommage du PDF du CV
(`/v1/cv/fr.pdf` → `/v1/cv/amissan.ag-cv-fr.pdf`) a été fusionné dans
`portfolio-web` après une CI verte sur ses trois jobs. Le site est resté servi
avec l'ancienne URL. Rien ne signalait l'écart : la pull request était fermée, la
CI était verte, et le seul témoin de l'absence de déploiement était l'absence
d'une ligne dans l'onglet Actions.

C'est la forme de panne la plus coûteuse : **tous les indicateurs sont au vert et
le résultat n'existe pas.**

## Décision

Les deux dépôts déployables — `portfolio-web` et `portfolio-api` — déclenchent
leur déploiement sur **`workflow_run` à la fin du workflow `CI`**, filtré sur la
branche `main`, la conclusion `success` et l'évènement `push`.

```yaml
on:
  workflow_run:
    workflows: [CI]
    types: [completed]
    branches: [main]
  workflow_dispatch:
```

Le déclenchement manuel reste ouvert : republier sans nouveau commit (rotation de
jeton, purge d'actifs, retour arrière) est un besoin réel, distinct de la
livraison continue.

## Ce qui a été écarté

**`on: push` sur `main`.** C'est le montage le plus court, et il ne garde rien :
le déploiement part **en parallèle** de la CI. Sur ce projet, la CI web dure
entre une et deux minutes et le déploiement une cinquantaine de secondes — le
déploiement gagne la course. On publierait donc un commit dont les tests
échouent ensuite, et la garde arriverait après le mal qu'elle prétend empêcher.

**Un job `deployer` dans `ci.yml`, avec `needs:`.** Correct sur le fond, et plus
simple à lire qu'un `workflow_run`. Écarté pour une raison de sécurité, pas de
style : il ferait entrer le jeton Cloudflare dans le workflow qui s'exécute sur
**chaque pull request**. `ci.yml` déclare aujourd'hui `permissions: contents:
read` et n'a besoin d'aucun secret — c'est une propriété qu'on peut vérifier en
lisant le fichier, et qui rend une classe entière d'attaques impossible plutôt
qu'improbable. Elle vaut plus que l'économie d'un fichier.

**Un environnement GitHub avec approbation manuelle.** Ajouterait une porte
humaine à une chaîne qu'on veut précisément automatique, sur un site personnel où
le retour arrière est un `workflow_dispatch` sur le commit précédent.

## Les deux pièges de `workflow_run`, et leurs gardes

`workflow_run` est le bon outil, et il a deux comportements contre-intuitifs qui
produisent chacun une panne silencieuse.

**Il se déclenche aussi quand la CI échoue.** Le bloc `on:` n'a pas de filtre sur
la conclusion — `types: [completed]` veut dire *terminée*, pas *réussie*. Sans
garde, un déploiement partirait sur chaque CI rouge. Le filtre s'écrit dans le
`if:` du job.

**`branches:` filtre la branche *source*, pas la branche de destination.** Une
pull request ouverte depuis un fork dont la branche s'appelle `main` satisfait
`branches: [main]`. Sans garde supplémentaire, elle déclencherait un déploiement
du code du fork. D'où la condition `github.event.workflow_run.event == 'push'` :
seule une poussée sur notre `main` publie.

```yaml
if: >-
  github.event_name == 'workflow_dispatch' ||
  (github.event.workflow_run.conclusion == 'success' &&
   github.event.workflow_run.event == 'push')
```

**Et le dépôt n'est pas positionné sur le commit validé.** `workflow_run`
exécute le *fichier de workflow* de la branche par défaut, mais un `checkout`
sans `ref` prend la tête de `main` **au moment du déploiement**. Deux fusions
rapprochées suffisent à publier autre chose que ce que la CI a validé. D'où
`ref: ${{ github.event.workflow_run.head_sha || github.ref }}` — le `||` couvre
le déclenchement manuel, qui n'a pas d'objet `workflow_run`.

## Un déploiement ne réussit plus sans rien publier

Les deux workflows ouvraient sur un contrôle qui, en l'absence de jeton, passait
toutes les étapes suivantes en silence et terminait **en vert**. C'était juste
tant qu'aucun jeton n'existait : le workflow était posé d'avance et ne devait pas
rendre la CI rouge.

Depuis qu'il est automatique, ce même comportement est un mensonge : il annonce
un déploiement réussi alors que rien n'est parti. Le contrôle **échoue**
désormais, en nommant ce qui manque.

La règle générale, qui dépasse ce fichier : **une dégradation gracieuse est une
panne silencieuse dès que plus personne ne regarde.** Elle se justifie pendant
une mise en place, et se retire quand la mise en place est finie.

## Conséquences

**Ce qu'on gagne.** Fusionner devient livrer. L'affirmation de l'ADR 0005 —
« sans aucune action humaine » — devient vraie de `main` jusqu'à la production,
pour chacun des deux dépôts.

**Ce que ça coûte.** Un `workflow_run` est moins lisible qu'un `needs:`, et ses
deux pièges sont réels. Ils sont commentés à l'endroit exact où ils s'appliquent,
dans les deux fichiers.

**Ce qui reste ouvert, et qui est la dernière panne silencieuse de la chaîne.**
La propagation **entre dépôts** n'existe toujours pas. Une modification de
contenu fusionnée dans `portfolio-api` déploie l'API, et le site continue de
servir son contenu local. La seconde moitié de la phrase de l'ADR 0005 reste donc
à écrire :

1. un déclencheur inter-dépôts (`repository_dispatch` de l'API vers le web) ;
2. un **témoin de fraîcheur** — sans lui, on remplace une panne silencieuse par
   une autre, et ce document aura été écrit pour rien.
