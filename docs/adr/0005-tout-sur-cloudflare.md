# 0005 — Tout sur Cloudflare, et le contenu propagé par reconstruction

**Statut** : Accepté · **Date** : 2026-09-17
**Remplace** : la partie « déploiement » de [l'ADR 0003](0003-choix-des-stacks.md)
(Cloud Run pour l'API, Vercel pour le web).

## Contexte

L'ADR 0003 avait retenu **Cloud Run** pour l'API et **Vercel** pour le web. Deux
contraintes, apparues depuis, invalident ce choix.

**L'hébergement doit être totalement gratuit, sans carte bancaire.** Le quota
gratuit de Cloud Run est réel, mais il exige un compte de facturation Google,
donc un moyen de paiement. Ce n'est pas la même chose que gratuit.

**Et le site s'est révélé entièrement statique.** Toutes ses routes sont
pré-rendues ; rien n'est calculé à la requête. Or sur Cloudflare, les fichiers
statiques sont **gratuits et illimités** — ils ne comptent même pas dans le quota
de 100 000 requêtes par jour.

## Décision

**Tout sur Cloudflare**, sur un seul compte, celui qui héberge déjà le domaine
`amissan.dev` acheté chez Cloudflare Registrar.

| | |
|---|---|
| `amissan.dev` | le site, en fichiers statiques |
| `api.amissan.dev` | l'API, un Worker, plus ses CV en fichiers statiques |
| DNS | déjà sur le compte : `wrangler deploy` crée les domaines lui-même |

**Le contenu se propage par reconstruction, pas au runtime.** Une modification de
contenu fusionnée dans `portfolio-api` déclenche son déploiement, qui déclenche à
son tour la reconstruction et le redéploiement de `portfolio-web`. Délai bout en
bout : **une à deux minutes, sans aucune action humaine**.

> ⚠️ **Ce paragraphe décrivait une intention, pas un état.** Au moment où il a
> été écrit, aucun des deux déploiements ne se déclenchait autrement qu'à la
> main, et la propagation entre dépôts n'existait pas. Le 2026-09-18,
> [l'ADR 0006](0006-le-deploiement-suit-la-ci.md) en a rendu la **première
> moitié** vraie — fusionner sur `main` déploie. La seconde, le déclencheur
> inter-dépôts et son témoin de fraîcheur, **reste à écrire**.

## Conséquences

**Ce qu'on gagne.** Un seul fournisseur, un seul compte, aucune configuration
DNS entre deux services. Zéro euro sans plafond. Et un site déployé qui est un
**artefact figé** : rien ne peut échouer à l'instant où un visiteur arrive — pas
de rendu à la volée, pas d'état intermédiaire où une page serait régénérée et
l'autre non.

**Ce que ça coûte.** Le contenu n'est pas frais à la seconde. Corriger une faute
de frappe et la voir en trois secondes est impossible : on la voit en quatre-vingt-dix.

**Ce qu'il faut tenir.** Le déclencheur entre les deux dépôts est le seul point
de couplage de tout le système. S'il casse en silence, le site affiche un contenu
périmé **sans que rien ne le signale** — c'est la panne la plus vicieuse possible
ici. Il doit donc être surveillé : le site expose la version de contenu qu'il
porte, et on doit pouvoir la comparer à celle que sert l'API.

**Et la politique de cache doit être vérifiée, pas supposée.** Le HTML se
revalide à chaque visite ; les fichiers nommés par empreinte se mettent en cache
pour un an. Un HTML mis en cache trop longtemps produit exactement le symptôme
qu'on cherche à éviter : « j'ai déployé, mais je vois encore l'ancien ».

## Alternatives écartées

**Vercel et la régénération incrémentale.** C'est **techniquement la meilleure
réponse** à la fraîcheur du contenu : une page se régénère seule après un délai
choisi, et peut être invalidée à la demande. C'est aussi une ligne de
configuration contre un pipeline à écrire.

Écartée parce que le besoin n'existe pas : ce contenu change quelques fois par
mois, et un délai de deux minutes y est sans conséquence observable. On paierait
un second fournisseur et un runtime serveur pour une fraîcheur inutilisée.

**Ce choix se renverse** si le contenu devient fréquent, si une page doit
dépendre du visiteur, ou si le déclencheur de reconstruction s'avère fragile à
l'usage. Le site n'est qu'un client de l'API : la bascule resterait locale.

**Récupérer l'API depuis le navigateur.** Contenu frais au rafraîchissement.
Écartée : du JavaScript en plus, un temps d'affichage dégradé, un état de
chargement visible, et la perte du score parfait — pour une fraîcheur dont on n'a
pas l'usage.
