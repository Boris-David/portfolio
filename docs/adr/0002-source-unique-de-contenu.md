# 0002 — Une source unique de contenu, servie par une API

**Statut** : Accepté · **Date** : 2026-09-13

## Contexte

Le web et l'app iOS affichent le **même** contenu : profil, parcours,
réalisations, concepts. Ce contenu bouge — un projet livré, un intitulé qui
change, une formulation qu'on affine.

Deux copies de ce contenu, c'est deux vérités. Elles divergent toujours, et la
divergence se découvre au pire moment : quand quelqu'un compare les deux en
entretien.

Contrainte propre au mobile : une app dont le contenu est **compilé dedans** exige
une soumission App Store à chaque correction de virgule. Délai de revue, version à
gérer, et en pratique : on ne corrige pas.

## Décision

Le contenu vit **en code** dans `portfolio-api`, validé par un schéma Zod, et
publié en JSON versionné avec `ETag`.

- **Web** : consommé au *build* → aucune requête au runtime, performance intacte.
- **iOS** : consommé au *runtime*, **offline-first** — cache disque validé par
  `ETag`, et un instantané embarqué qui garantit un premier lancement utile même
  hors ligne.

## Conséquences

**Ce qu'on gagne.** Mettre à jour le contenu = une PR, zéro release App Store.
Le schéma Zod est la seule définition : les types TypeScript s'en dérivent, et le
contrat OpenAPI aussi — rien n'est écrit deux fois, donc rien ne peut diverger.

**Ce que ça coûte.** Une dépendance réseau côté iOS, et donc toute la matière à
traiter correctement : cache, invalidation, états d'erreur, mode dégradé. C'est un
coût réel, mais c'est exactement le travail qu'une app sérieuse doit montrer —
ici il est nécessaire, pas décoratif.

**Ce qu'il faut tenir.** L'instantané embarqué doit être régénéré à chaque
release, sinon il devient une seconde source de vérité périmée. La CI iOS le
régénère et **échoue** s'il dérive du schéma publié.

## Alternatives écartées

**Contenu dupliqué dans chaque client.** Zéro infrastructure. Écarté : deux
vérités qui divergent, et toute correction de texte devient une release App Store.

**Dépôt de contenu partagé, consommé au build par les deux.** Zéro serveur, zéro
coût. Écarté pour une seule raison, mais dirimante : côté iOS, « au build » veut
dire « à la soumission App Store ». On garde l'idée pour l'instantané embarqué —
en filet, pas en source.
