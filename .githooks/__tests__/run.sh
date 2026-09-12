#!/usr/bin/env bash
#
# Falsifie `.githooks/pre-commit`. Une garde que personne ne lance ne protège
# rien : ce script échoue si un motif cesse d'être détecté.
#
# Chaque cas monte un dépôt jetable, y indexe un fichier piégé, et vérifie que
# le hook REFUSE. Un cas témoin vérifie qu'il LAISSE PASSER du contenu sain —
# sans quoi « tout refuser » passerait la suite.
set -uo pipefail

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/pre-commit"
EMAIL="amissan.ag@outlook.fr"
pass=0; fail=0

run_case() { # $1 = libellé, $2 = attendu (refuse|passe), $3 = contenu, $4 = email
  local label="$1" expected="$2" content="$3" email="${4:-$EMAIL}"
  local tmp; tmp="$(mktemp -d)"
  (
    cd "$tmp" || exit 1
    git init -q -b main
    git config user.name "Test"; git config user.email "$email"
    printf '%s\n' "$content" > fichier.txt
    git add fichier.txt
    "$HOOK" >/dev/null 2>&1
  )
  local rc=$?
  rm -rf "$tmp"
  local actual="passe"; [ $rc -ne 0 ] && actual="refuse"
  if [ "$actual" = "$expected" ]; then
    printf '  ✅ %-46s %s\n' "$label" "$actual"; pass=$((pass+1))
  else
    printf '  ❌ %-46s attendu=%s obtenu=%s\n' "$label" "$expected" "$actual"; fail=$((fail+1))
  fi
}

# Les motifs interdits sont ASSEMBLÉS à l'exécution, jamais écrits en clair.
# Sans ça, ce fichier porterait lui-même ce que la garde refuse — et il aurait
# fallu l'exempter, c'est-à-dire creuser un trou dans la garde pour pouvoir la
# tester. On préfère un fichier qui ne contient aucun littéral interdit : il
# n'y a alors plus rien à exempter.
DASHES="$(printf -- '-%.0s' 1 2 3 4 5)"
EMPLOYER="instant""-system"".com"
ESN="ine""tum"".com"
pem() { printf '%sBEGIN %s PRIV%s KEY%s' "$DASHES" "$1" "ATE" "$DASHES"; }

echo "── Garde pre-commit ──"
run_case "identité employeur"        refuse "contenu sain" "quelquun@$EMPLOYER"
run_case "domaine employeur indexé"  refuse "contact: quelquun@$EMPLOYER"
run_case "domaine ESN indexé"        refuse "voir https://www.$ESN/fr"
run_case "clé privée PEM"            refuse "$(pem RSA)"
run_case "clé privée OpenSSH"        refuse "$(pem OPENSSH)"
run_case "jeton GitHub (ghp_)"       refuse "token=ghp_$(printf 'a%.0s' {1..36})"
run_case "clé Google (AIza)"         refuse "key=AIza$(printf 'b%.0s' {1..35})"
run_case "clé OpenAI (sk-)"          refuse "sk-$(printf 'c%.0s' {1..24})"
run_case "TÉMOIN — contenu sain"     passe  "# Un fichier parfaitement anodin"

echo "── $pass réussis, $fail échoués ──"
[ $fail -eq 0 ]
