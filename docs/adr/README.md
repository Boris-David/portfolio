# Décisions d'architecture (ADR)

Un ADR fige **une** décision : son contexte, ce qui a été tranché, ce que ça
coûte, et ce qui a été écarté — avec le pourquoi. Il n'est jamais réécrit : une
décision qui change donne un **nouvel** ADR qui remplace l'ancien, et l'ancien
passe en `Remplacé par`.

Ce format existe pour une raison précise : dans six mois, la question ne sera pas
« qu'est-ce qu'on a fait ? » — le code le dit — mais « **pourquoi**, et qu'est-ce
qu'on avait déjà éliminé ? ». Sans trace, on refait le débat, ou pire, on défait
un choix sans connaître la contrainte qui l'avait imposé.

| # | Décision | Statut |
|---|---|---|
| [0001](0001-quatre-depots.md) | Quatre dépôts plutôt qu'un monorepo | Accepté |
| [0002](0002-source-unique-de-contenu.md) | Une source unique de contenu, servie par une API | Accepté |
| [0003](0003-choix-des-stacks.md) | Choix des stacks web, API et iOS | Accepté — volet déploiement remplacé par [0005](0005-tout-sur-cloudflare.md) |
| [0004](0004-le-cv-est-genere-par-l-api.md) | Le CV en PDF est généré par l'API, pas par chaque client | Accepté |
| [0005](0005-tout-sur-cloudflare.md) | Tout sur Cloudflare, contenu propagé par reconstruction | Accepté |
