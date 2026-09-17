# 0007 — La propagation du contenu entre dépôts, poussée et tirée

**Statut** : Accepté · **Date** : 2026-09-18
**Achève** : [l'ADR 0002](0002-source-unique-de-contenu.md), dont il réalise la
source unique, et [l'ADR 0006](0006-le-deploiement-suit-la-ci.md), dont il ferme
la dernière panne silencieuse nommée.

## Contexte

L'ADR 0002 décidait une source unique de contenu, servie par une API. L'ADR 0005
décrivait sa propagation — *« une modification fusionnée dans `portfolio-api`
déclenche […] la reconstruction de `portfolio-web` »*.

Rien de tout cela n'existait. `portfolio-web` portait sa **propre copie** du
contenu : 855 lignes de français et d'anglais, plus un `apps.json` dupliqué et
une table d'URL. Deux vérités, donc, et elles avaient déjà divergé :

| | `portfolio-api` | `portfolio-web` |
|---|---|---|
| Le « 33 » | **une** fois, dans le titre que la grille démontre | **quatre** fois : tuile, titre d'étude, titre de section, description |
| Le chiffre d'audience | « ~5 M […] applications auxquelles j'ai contribué » | « ~1 M d'utilisateurs sur Mail Orange » — retiré par l'auteur |

La seconde ligne est la plus parlante : l'arbitrage avait été appliqué d'un côté
et pas de l'autre, et c'est le **site public** qui portait la version périmée.

## Décision

### 1. Le site consomme l'API au build

`portfolio-web` ne contient plus **aucun fait**. Il récupère
`/v1/portfolio?lang=…` au `next build`, l'adapte, et fige le résultat dans
l'export statique. Le visiteur ne fait aucune requête : le HTML servi porte déjà
le contenu (ADR 0005, l'hébergement gratuit tient à ce que rien ne s'exécute à la
requête).

### 2. La ligne de partage : contenu contre chrome

> **Est du contenu ce qui resterait vrai si le site n'existait pas.**

Un fait du parcours, un chiffre, une phrase, une URL de profil : vrai avec ou
sans site, donc à l'API — qui le sert aussi bien au CV en PDF qu'à la future app
iOS. « Aller au contenu », « Changer de thème », le choix d'une icône, l'ordre
des ancres : ça n'existe que parce qu'il y a une page web. Ça reste dans
`src/content/chrome/`.

Le critère n'est pas « ce que l'API sert aujourd'hui » — ce serait laisser
l'outil décider de l'architecture.

### 3. Deux modèles, et une couche qui traduit

L'API décrit des **faits** : `{ start: "2023-05", end: null }`. Le site affiche
« mai 2023 → aujourd'hui ». On aurait pu faire porter l'un par l'autre ; les deux
options étaient mauvaises.

- Une API qui sait comment un site s'affiche devrait aussi savoir comment un PDF
  et une app native s'affichent. Elle cesserait d'être une source de faits.
- Un site qui reçoit des chaînes déjà mises en forme ne peut plus rien en faire
  d'autre — et la deuxième langue, le PDF et l'app auraient chacun leur variante.

`api/adapt.ts` traduit donc, côté client, là où la présentation est décidée. Il
**dérive** ce que l'API n'a aucune raison de connaître : la numérotation des
sections depuis leur rang, le « +28 » depuis le nombre réel d'applications, les
dates lisibles via `Intl`, le nom de fichier d'une capture depuis l'identifiant
de son média.

### 4. La propagation : un chemin poussé, un chemin tiré

| | Déclencheur | Délai | Secret |
|---|---|---|---|
| **Poussé** | `portfolio-api` déploie → `repository_dispatch` | quelques secondes | un PAT à portée fine |
| **Tiré** | témoin de fraîcheur, toutes les 3 h | 3 h au pire | **aucun** |

Le chemin tiré n'est pas une roue de secours qu'on espère ne jamais utiliser :
c'est ce qui rend le système **correct sans secret partagé**. Le chemin poussé
n'ajoute que de la vitesse. Si le jeton expire, est révoqué ou n'a jamais été
posé, la propagation ralentit — elle ne casse pas.

### 5. Le témoin de fraîcheur, et sa vérification

Chaque page publie `<meta name="content-version">`, l'empreinte du contenu sur
lequel elle a été construite ; l'API sert la sienne. Les comparer répond en une
requête à la question qu'on ne pouvait pas poser : *le site en ligne a-t-il été
construit sur le contenu courant ?*

Le workflow `fraicheur.yml` compare, **republie** si les empreintes divergent,
puis **revérifie**. La troisième étape n'est pas du zèle : une réparation qu'on
ne contrôle pas remplace une panne muette par une autre. Si l'empreinte n'a
toujours pas bougé après republication, la chaîne est cassée — pas en retard — et
le workflow échoue en le disant.

## Ce qui a été écarté

**Consommer l'API à la requête, côté visiteur.** Coûterait l'export statique,
donc l'hébergement gratuit (ADR 0005), et rendrait le contenu dépendant de la
disponibilité de l'API au moment où un recruteur ouvre la page. Un site qui
affiche un squelette parce qu'une API est lente est pire qu'un site figé.

**Recopier le schéma Zod de l'API dans le web pour valider.** C'eût été une
seconde source de vérité sur la **forme**, alors qu'on venait d'en supprimer une
sur le **fond**. `api/field.ts` valide donc **en lisant** : chaque accès connaît
son chemin et lève en le nommant. Un champ jamais lu ne peut pas casser la
construction ; un champ lu ne peut pas valoir `undefined` sans qu'on l'apprenne.

**Un repli sur du contenu local quand l'API ne répond pas.** C'est précisément la
seconde copie qu'on supprime, et elle serait pire : invisible tant que tout va
bien, servie au pire moment. La construction **échoue**.

**Un `gh workflow run` depuis le témoin pour republier.** GitHub refuse qu'un
workflow déclenché par le `GITHUB_TOKEN` en déclenche un autre — protection
contre les boucles. Le témoin appelle donc le déploiement comme **workflow
réutilisable** (`workflow_call`), ce qui évite en prime d'avoir deux descriptions
du même déploiement.

## Conséquences

**Ce qu'on gagne.** Une seule vérité. Corriger une phrase dans `portfolio-api`
la corrige sur le site, dans le CV en PDF et — demain — dans l'app iOS, sans
qu'aucune des trois n'ait à être touchée. Le « 33 » n'est plus répétable par
accident : il est écrit une fois, à la source.

**Ce que ça coûte.** Le site ne se construit plus hors ligne : `npm run build` a
besoin de l'API. C'est le prix assumé de l'absence de copie locale, et le message
d'erreur le dit.

**Un piège nommé, pour ne pas le repayer.** Un test de comportement ne doit
connaître aucun slug de contenu. `disclosure.spec.ts` désignait un chantier par
`workstream-authentification` ; la bascule a renommé le slug en `authentication`
sans rien changer à l'écran, et **onze tests de comportement sont tombés** pour
une raison qui ne les regardait pas. Ils désignent désormais par la structure.

**Ce qui reste ouvert.** Le jeton du chemin poussé doit être créé par l'auteur —
un PAT à portée fine, limité à `portfolio-web`, permission « Contents: read and
write », posé en secret `PORTFOLIO_WEB_DISPATCH_TOKEN` sur `portfolio-api`. Tant
qu'il n'existe pas, le workflow le signale en avertissement et le chemin tiré
fait le travail.
