#!/usr/bin/env bash
#
# Garde de PÉRIMÈTRE — rend `.claude/rules/scope-isolation.md` exécutable.
#
# Refuse trois classes de gestes :
#   1. toucher un projet VOISIN sous ai-projects/ — lecture comprise, parce que
#      la règle interdit de s'en servir comme source, pas seulement d'y écrire ;
#   2. ÉCRIRE dans un autre dépôt de travail sous ~/Work — la lecture y est
#      autorisée (extraction de faits sur le travail de l'auteur pour le contenu
#      du portfolio, cf. scope-isolation.md § exceptions), l'écriture jamais ;
#   3. viser un dépôt GitHub hors de l'allowlist portfolio.
#
# Couvre `Bash` (analyse du texte de commande) ET les outils d'écriture de
# fichiers `Write` / `Edit` / `NotebookEdit` (analyse du chemin cible). Ne
# couvrir que Bash laissait un trou béant : un agent écrit des fichiers sans
# passer par un shell. Trou mesuré et fermé le 2026-09-17.
#
# ⚠️ Ce que cette garde NE fait PAS : sur Bash, elle lit du TEXTE de commande.
# Elle protège de l'accident, pas de l'évasion — un chemin assemblé à
# l'exécution lui échappe. C'est une limite documentée, pas un défaut à
# corriger sans fin. Sur Write/Edit, en revanche, le chemin est structuré :
# là, elle ne se contourne pas par une astuce de chaîne.
set -euo pipefail

WORKSPACE="/Users/PC205/Work/learning/ai-projects/portfolio"
SIBLINGS_ROOT="/Users/PC205/Work/learning/ai-projects"
WORK_ROOT="/Users/PC205/Work"
ALLOWED="portfolio portfolio-web portfolio-ios portfolio-api portfolio-certificates"
# Projets voisins dont la LECTURE est autorisée : ceux que le portfolio CITE,
# et dont il doit donc pouvoir établir les faits (dates, volumes). L'écriture
# et la reprise de leur setup restent interdites — cf. scope-isolation.md.
READABLE_SIBLINGS="kcalories"

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"

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

in_workspace() {
  case "$1" in "$WORKSPACE"|"$WORKSPACE"/*) return 0 ;; *) return 1 ;; esac
}

# ══ Outils d'écriture de fichier : le chemin cible suffit ════════════════
case "$tool_name" in
  Write|Edit|NotebookEdit)
    target="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')"
    [ -z "$target" ] && exit 0
    case "$target" in
      /*) ;;                       # absolu : on l'évalue
      *)  exit 0 ;;                # relatif : résolu dans le cwd du workspace
    esac
    # PORTÉE de cette garde, explicitement : elle protège les AUTRES PROJETS,
    # qui vivent sous ~/Work. Un répertoire temporaire de session, un scratchpad
    # ou /tmp ne sont pas des projets — les y interdire n'apporte aucune
    # protection et bloque du travail légitime. Une garde qui gêne le travail
    # normal finit désactivée, et ne protège alors plus rien du tout.
    # Faux positif mesuré le 2026-09-17 sur le scratchpad de session.
    case "$target" in
      "$WORK_ROOT"/*) ;;           # territoire protégé
      *) exit 0 ;;                 # hors remit : on ne se prononce pas
    esac
    if ! in_workspace "$target"; then
      deny "Périmètre portfolio : écriture de fichier visant « $target », qui appartient à un autre projet sous ~/Work. Le portfolio n'écrit que chez lui — voir .claude/rules/scope-isolation.md."
    fi
    exit 0
    ;;
esac

# ══ Bash : analyse du texte de commande ═════════════════════════════════
command_text="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
[ -z "$command_text" ] && exit 0

# ── 0. La commande mute-t-elle quelque chose ? (sert aux sections 1 et 2) ─
MUTATORS='(^|[;&|[:space:]])(rm|rmdir|mv|cp|tee|touch|mkdir|chmod|chown|ln|truncate|dd)([[:space:]]|$)|>>?[[:space:]]*/Users|sed[[:space:]]+-i|git([[:space:]]+-[A-Za-z-]+([[:space:]]+[^[:space:]]+)?)*[[:space:]]+(commit|push|add|checkout|switch|reset|clean|rebase|merge|restore|stash|apply|rm|mv|tag|init)'
mutates=0
printf '%s' "$command_text" | grep -Eq -e "$MUTATORS" && mutates=1

# ── 1. Projet voisin sous ai-projects ───────────────────────────────────
# Fermé par défaut, lecture comprise. Seuls les projets CITÉS par le
# portfolio sont lisibles — et en lecture seule.
while read -r hit; do
  [ -z "$hit" ] && continue
  in_workspace "$hit" && continue
  name="${hit##*/}"
  case " $READABLE_SIBLINGS " in
    *" $name "*)
      [ "$mutates" -eq 0 ] && continue
      deny "Périmètre portfolio : « $hit » est lisible parce que le portfolio le cite, mais le portfolio n'y ÉCRIT jamais."
      ;;
  esac
  deny "Périmètre portfolio : la commande touche « $hit », qui appartient à un autre projet. La règle .claude/rules/scope-isolation.md interdit d'y lire comme d'y écrire — un autre projet n'est ni une source ni un modèle ici."
done < <(printf '%s' "$command_text" | grep -oE "${SIBLINGS_ROOT}/[A-Za-z0-9._-]+" | sort -u || true)

# ── 2. Écriture ailleurs sous ~/Work — lecture OK, écriture jamais ──────
if [ "$mutates" -eq 1 ]; then
  while read -r hit; do
    [ -z "$hit" ] && continue
    in_workspace "$hit" && continue
    deny "Périmètre portfolio : geste d'ÉCRITURE visant « $hit », hors du workspace. Lire un dépôt de travail personnel pour en extraire des faits est autorisé ; y écrire ne l'est jamais."
  done < <(printf '%s' "$command_text" | grep -oE "${WORK_ROOT}/[A-Za-z0-9._/-]+" | sort -u || true)
fi

# ── 3. Dépôt GitHub hors allowlist ──────────────────────────────────────
while read -r repo; do
  [ -z "$repo" ] && continue
  name="${repo##*/}"
  case " $ALLOWED " in *" $name "*) continue ;; esac
  deny "Périmètre portfolio : la commande vise le dépôt « $repo », hors de l'allowlist (${ALLOWED// /, })."
done < <(printf '%s' "$command_text" \
  | grep -oE '(--repo[= ]|-R )[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' \
  | sed -E 's/^(--repo[= ]|-R )//' | sort -u || true)

exit 0
