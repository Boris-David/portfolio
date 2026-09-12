# 0003 — Choix des stacks

**Statut** : Accepté · **Date** : 2026-09-13

## Contexte

Trois produits, trois choix de stack. Le critère n'est pas la familiarité : ces
dépôts sont publics et jugés sur pièce. Une stack se justifie par ce qu'elle
permet **ici**, et le choix doit rester défendable à l'oral.

## Décision

### Web — Next.js (App Router) · React · TypeScript strict · Tailwind

Le rendu serveur et le streaming permettent une vitrine réellement applicative,
pas une page statique animée, sans sacrifier le temps d'affichage. C'est aussi la
stack la plus immédiatement lisible par un lecteur front.

### API — Hono · Zod · OpenAPI dérivé · Cloud Run

Hono plutôt qu'Express : typage de bout en bout et surface minimale. Le point
décisif est le **contrat dérivé** — l'OpenAPI se génère depuis le schéma Zod au
lieu d'être maintenu à côté. Un contrat écrit à la main est un contrat qui ment
un jour. Cloud Run pour le scale-to-zero, et un déploiement par **fédération
d'identité** : aucune clé de service à stocker dans les secrets du dépôt.

### iOS — Swift 6 · concurrence stricte · SwiftUI · modules SPM locaux

Cible minimale **N-1** : les API de la version courante sont utilisées derrière
des tests de disponibilité. C'est ce que fait une application réelle, et ça se
voit.

Le point structurant : les couches (`Domain`, `Data`, `Presentation`,
`DesignSystem`) sont des **modules SPM séparés**, pas des dossiers. Une
dépendance interdite — la couche Domain qui importerait SwiftUI, la Presentation
qui atteindrait le réseau — devient une **erreur de compilation**. Une convention
qu'on espère respectée finit par ne plus l'être ; une frontière que le compilateur
refuse de franchir tient toute seule.

## Conséquences

**Ce qu'on gagne.** Les invariants d'architecture sont mécaniques : le découpage
en modules et le contrat dérivé ne dépendent de la vigilance de personne.

**Ce que ça coûte.** Le découpage en modules SPM ralentit le premier écran livré —
il faut poser les frontières avant d'avoir de quoi les remplir. C'est un coût payé
d'avance, assumé : le remettre à plus tard revient à ne jamais le faire.

**Ce qu'il faut tenir.** « Cible N-1 » n'est pas une intention : la CI compile et
teste sur la version minimale déclarée, sinon la cible dérive sans qu'on le voie.

## Alternatives écartées

**Astro pour le web.** Meilleur outil pour un site de contenu pur, et moins de
JavaScript par défaut. Écarté parce que la partie interactive du portfolio — la
passerelle vers l'app, les transitions — relève de l'applicatif.

**Couches en dossiers plutôt qu'en modules.** Plus rapide à démarrer. Écarté :
une frontière non compilée n'est pas une frontière.

**Cible minimale sur la dernière version d'iOS uniquement.** Écarté : ça exclut
une partie du parc réel, et ça évite précisément le travail — la compatibilité
progressive — qu'un lecteur technique cherche.
