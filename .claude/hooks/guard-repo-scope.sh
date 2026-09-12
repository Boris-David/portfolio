#!/usr/bin/env bash
#
# Garde de PÉRIMÈTRE — rend `.claude/rules/scope-isolation.md` exécutable.
#
# Refuse deux classes de gestes :
#   1. toucher un projet VOISIN sous ai-projects/ (lecture comprise : la règle
#      interdit de s'en servir comme source, pas seulement d'y écrire) ;
#   2. viser un dépôt GitHub hors de l'allowlist portfolio.
#
# Ce que cette garde NE fait PAS : elle lit du texte de commande. Elle protège
# de l'ACCIDENT, pas de l'évasion délibérée — un chemin construit dynamiquement
# lui échappe. C'est une limite documentée, pas un défaut à corriger sans fin.
set -euo pipefail

input="$(cat)"
command_text="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
[ -z "$command_text" ] && exit 0

WORKSPACE="/Users/PC205/Work/learning/ai-projects/portfolio"
SIBLINGS_ROOT="/Users/PC205/Work/learning/ai-projects"

deny() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# ── 1. Projet voisin ───────────────────────────────────────────────────
# Tout chemin sous ai-projects/ qui ne descend pas dans portfolio/.
while read -r hit; do
  [ -z "$hit" ] && continue
  case "$hit" in
    "$WORKSPACE"|"$WORKSPACE"/*) continue ;;
  esac
  deny "Périmètre portfolio : la commande touche « $hit », qui appartient à un autre projet. La règle .claude/rules/scope-isolation.md interdit d'y lire comme d'y écrire — un autre projet n'est ni une source ni un modèle ici."
done < <(printf '%s' "$command_text" | grep -oE "${SIBLINGS_ROOT}/[A-Za-z0-9._-]+" | sort -u || true)

# ── 2. Dépôt GitHub hors allowlist ─────────────────────────────────────
ALLOWED="portfolio portfolio-web portfolio-ios portfolio-api portfolio-certificates"
while read -r repo; do
  [ -z "$repo" ] && continue
  name="${repo##*/}"
  case " $ALLOWED " in
    *" $name "*) continue ;;
  esac
  deny "Périmètre portfolio : la commande vise le dépôt « $repo », hors de l'allowlist (${ALLOWED// /, })."
done < <(printf '%s' "$command_text" \
  | grep -oE '(--repo[= ]|-R )[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' \
  | sed -E 's/^(--repo[= ]|-R )//' | sort -u || true)

exit 0
