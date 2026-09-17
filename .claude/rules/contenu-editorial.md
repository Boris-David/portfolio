# Contenu éditorial — ce qui a été tranché

> Règle racine, chargée à chaque session : elle régit **tout** ce qui s'écrit
> pour le portfolio, dans les trois dépôts.
>
> Chaque ligne ci-dessous est un **arbitrage rendu par l'auteur**, souvent après
> une première version rejetée. Ce fichier existe pour qu'aucune ne se reperde.

## Comment il se présente

| | |
|---|---|
| Nom affiché | **Amissan Amoussou-G.** — la forme longue est réservée au pied de page et au CV |
| Accroche | **Ingénieur iOS senior** |
| Métier, en une phrase | il développe la **billettique mobile** chez Instant System, et c'est son domaine d'expertise |
| Localisation | Alpes-Maritimes |
| Disponibilité | « Opportunités de télétravail complet et fréquent » |
| Langues | français · anglais professionnel (TOEIC 840) |
| Contact | `amissan.ag@outlook.fr`, **seul canal** |

⚠️ Ne pas écrire « développeur confirmé » en accroche : ça contredit « senior »
dans le même écran. « Référent technique billettique » reste juste comme
**étiquette de rôle** dans l'expérience — c'est son employeur qui l'écrit.

## Les chiffres publiables — et eux seuls

- **33** applications de transport en production embarquent sa couche de billettique
- **~1 M** d'utilisateurs sur Mail Orange
- **> 99,8 %** de sessions sans crash sur KCalories
- **6 ans** d'ingénierie iOS, depuis octobre 2020
- **4 stacks / 5 mois** sur KCalories, de la première ligne à l'App Store
- **30 → 92 %** de Swift migré — **uniquement** dans l'expérience STIILT, jamais
  en chiffre-phare : c'est un résultat d'alternance, pas un accomplissement de carrière

**Interdits, chacun refusé explicitement :**
- « 41 % du module porte ma signature » — *« ça veut pas dire grand-chose »*
- « 12 ans d'historique de la base de code » — *« qu'est-ce que les recruteurs s'en fichent »*
- tout **nombre total de commits** — le volume ferait soupçonner du code généré
- le **nombre d'utilisateurs de KCalories** — l'app est récente
- « plus d'une vingtaine de réseaux » — le compte réel est établi et vérifié

## Ce qui se dit du travail chez Instant System

À ne pas diluer, ce sont les faits les plus forts du dossier :

- **TCL / Lyon** : il a développé **quasiment seul** le rechargement de carte de
  transport sur iOS. Il est **l'un des référents techniques** de cette
  application, dont il est l'**expert**, et il porte le lancement du m-ticket.
- **Nouveau socle (Oùra, Toscane)** : catalogue d'achat, panier, produits à
  paramètres, historiques d'achat, gestion de bénéficiaires, achat pour autrui.
- **Bibliothèque anti-fraude** — le problème : les fraudeurs capturaient le QR
  code d'un titre et le transmettaient, et rien ne distinguait la copie au
  contrôle. **Née d'une initiative personnelle** en sprint d'innovation, elle
  masque le contenu de l'écran dès qu'une capture est en cours. Déployée partout,
  **reprise sur le nouveau socle**, et devenue une **fonctionnalité que les
  clients paient**.
- **Bibliothèque de génération de QR code** à partir d'un payload encodé — la
  brique Usage : validation du titre et contrôle.
- **Architecture d'abstraction par prestataire** : ⚠️ **il n'en est PAS à
  l'initiative — c'est le tech lead.** Ce qui est à lui : avoir **créé le module
  d'un nouveau prestataire** malgré son peu de spécificités, pour que
  l'architecture reste cohérente de bout en bout ; et avoir **milité pour, puis
  obtenu**, la remontée au niveau du produit des implémentations indépendantes du
  prestataire, les prestataires ne surchargeant plus que leur différence.
  *(Correction apportée par l'auteur lui-même le 2026-09-17. Une revendication
  trop large se retourne en entretien — ne jamais la réintroduire.)*
- **Refonte de l'authentification** : le code datait de 2019 et personne ne
  voulait y toucher. Plusieurs requêtes recevant un 401 simultanément lançaient
  chacune leur rafraîchissement de jeton ; les rafraîchissements concurrents
  s'invalidaient et **déconnectaient l'utilisateur sans raison**. Il a pris
  l'initiative de la refonte : acteur portant l'état d'authentification, et
  **mémorisation de la tâche de rafraîchissement en cours** — les appels
  concurrents attendent la même au lieu d'en créer une nouvelle. **Résultat :
  l'authentification sur TCL est devenue nettement plus stable.**
  *(Vérifiable dans le code : `ISAuthenticationManager`, cinq commits de
  février 2025.)*
- Deux outils écrits pour son équipe, **repris par une autre équipe produit**.

## 🔴 Ce qui ne sort jamais

Salaires · noms de collègues, managers, prestataires · tensions internes · cas RH ·
mentions de santé · notes d'évaluation · **verbatims de documents RH** ·
identifiants de tickets · noms de modules internes · numéros de réseau internes.

⚠️ **La bibliothèque anti-fraude se décrit par ce qu'elle fait, jamais par
comment elle le fait.** C'est une contre-mesure : en publier le mécanisme, c'est
publier de quoi le contourner.

## Ton

Un portfolio, **pas une biographie**. Pas de récit, pas de thèse, pas de jeu de
mots dans les titres. Les faits portent la personnalité mieux que les adjectifs :
*« j'ai tenu seul la billettique d'un portefeuille entier pendant un an »* dit
l'autonomie mieux que le mot « autonome ».

Un recruteur **scanne**. Une information doit se trouver en trois secondes, le
détail se déplie à la demande.

## Forme — refus explicites

Le style « généré par IA » a une signature : polices par défaut (Inter, Poppins,
Space Grotesk), dégradé violet-bleu, verre dépoli, crème + serif + terracotta,
cartes toutes identiques, même rayon et même ombre partout, emojis en titres,
animations d'apparition sur chaque bloc, superlatifs sans preuve.

**Rien de tout ça.** Le thème retenu : Fraunces + Instrument Sans, papier chaud
`#FAF8F3`, encre `#1A1712`, accent indigo `#2743D6`.

Le site est **bilingue français / anglais dès la première version** — la cible
inclut le remote parisien et international.
