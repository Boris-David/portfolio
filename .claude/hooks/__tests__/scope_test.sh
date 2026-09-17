#!/usr/bin/env bash
#
# Falsifie `.claude/hooks/guard-repo-scope.sh`.
#
# ⚠️ Les chemins et noms de dépôts interdits sont ASSEMBLÉS à l'exécution,
# jamais écrits en clair. Sinon ce fichier porterait lui-même ce que la garde
# refuse, et toute commande qui le manipule serait bloquée — mesuré le
# 2026-09-17, la garde a refusé sa propre suite de tests trois fois de suite.
set -uo pipefail

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/guard-repo-scope.sh"
HOME_WORK="/Users/PC205/$(printf 'Work')"
WS="$HOME_WORK/learning/ai-projects/portfolio"
SIB="$HOME_WORK/learning/ai-$(printf 'projects')/kcalories"
OUT_REPO="Boris-David/$(printf 'autre')-projet"
pass=0; fail=0

t() { # $1 libellé, $2 commande, $3 attendu (PASSE|REFUS)
  local out got
  out="$(jq -nc --arg c "$2" '{tool_input:{command:$c}}' | "$HOOK")"
  got="PASSE"; [ -n "$out" ] && got="REFUS"
  if [ "$got" = "$3" ]; then printf '  ✅ %-42s %s\n' "$1" "$got"; pass=$((pass+1))
  else printf '  ❌ %-42s attendu=%s obtenu=%s\n' "$1" "$3" "$got"; fail=$((fail+1)); fi
}

tf() { # même chose, mais pour un outil d'ÉCRITURE de fichier (Write/Edit)
  local out got
  out="$(jq -nc --arg n "$2" --arg p "$3" '{tool_name:$n,tool_input:{file_path:$p}}' | "$HOOK")"
  got="PASSE"; [ -n "$out" ] && got="REFUS"
  if [ "$got" = "$4" ]; then printf '  ✅ %-42s %s\n' "$1" "$got"; pass=$((pass+1))
  else printf '  ❌ %-42s attendu=%s obtenu=%s\n' "$1" "$4" "$got"; fail=$((fail+1)); fi
}

echo "── Garde de périmètre ──"

echo "  · projet voisin sous ai-projects — interdit, lecture comprise"
t "voisin : lecture"          "cat $SIB/CLAUDE.md"                        REFUS
t "voisin : suppression"      "rm -rf $SIB"                               REFUS

echo "  · autre dépôt de travail — lecture autorisée, écriture jamais"
t "travail : git log"         "git -C $HOME_WORK/socle-v1 log --oneline"  PASSE
t "travail : grep"            "grep -r actor $HOME_WORK/socle-v2/Sources" PASSE
t "travail : rm"              "rm -rf $HOME_WORK/socle-v1/build"          REFUS
t "travail : git -C commit"   "git -C $HOME_WORK/socle-v2 commit -m x"    REFUS
t "travail : git -C push"     "git -C $HOME_WORK/socle-v1 push origin main" REFUS
t "travail : sed -i"          "sed -i '' s/a/b/ $HOME_WORK/socle-v1/R.md" REFUS
t "travail : redirection"     "echo x > $HOME_WORK/socle-v1/note.txt"     REFUS

echo "  · dépôts GitHub — allowlist portfolio"
t "gh : hors allowlist"       "gh pr list --repo $OUT_REPO"               REFUS
t "gh : dans l'allowlist"     "gh pr list --repo Boris-David/portfolio-ios" PASSE

echo "  · écriture de fichier hors Bash — le trou fermé le 2026-09-17"
tf "Write : projet voisin"    Write "$SIB/note.md"                        REFUS
tf "Write : autre dépôt"      Write "$HOME_WORK/socle-v1/note.md"         REFUS
tf "Edit : autre dépôt"       Edit  "$HOME_WORK/socle-v2/Package.swift"   REFUS
tf "Write : dans le workspace" Write "$WS/design/tokens.json"             PASSE

echo "  · TÉMOINS — le workspace doit rester pleinement ouvert"
t "workspace : mkdir"         "mkdir -p $WS/design"                       PASSE
t "workspace : git commit"    "git -C $WS commit -m ok"                   PASSE
t "commande neutre"           "npm test && swift build"                   PASSE

echo "── $pass réussis, $fail échoués ──"
[ $fail -eq 0 ]
