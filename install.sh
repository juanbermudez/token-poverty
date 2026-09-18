#!/usr/bin/env bash
# token-rich-token-poor installer
# Detects installed agent harnesses, asks which to touch, and never overwrites.
set -uo pipefail

VERSION="1.0.0"
RAW="https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main"
STATE_DIR="$HOME/.token-poverty"
MANIFEST="$STATE_DIR/manifest.tsv"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MARK_BEGIN="BEGIN token-poverty v$VERSION"
MARK_END="END token-poverty"

SCOPE=""
ASSUME_YES=0
DO_UNINSTALL=0
TOGGLE=""
PICK=""

# id | label | detect path | global target | project target | mode
# mode: append (marked block in a shared file) | file (dedicated file) | style (Claude Code)
HARNESSES=(
  "claude|Claude Code|$HOME/.claude|$HOME/.claude/output-styles/token-poverty.md|.claude/output-styles/token-poverty.md|style"
  "codex|Codex|$HOME/.codex|$HOME/.codex/AGENTS.md|AGENTS.md|append"
  "grok|Grok Build|$HOME/.grok|$HOME/.grok/AGENTS.md|AGENTS.md|append"
  "prime|Prime Agent|$HOME/.prime/agent|$HOME/.prime/agent/APPEND_SYSTEM.md|.prime/agent/APPEND_SYSTEM.md|append"
  "gemini|Gemini CLI|$HOME/.gemini|$HOME/.gemini/GEMINI.md|GEMINI.md|append"
  "opencode|OpenCode|$HOME/.config/opencode|$HOME/.config/opencode/AGENTS.md|AGENTS.md|append"
  "amp|Amp|$HOME/.config/amp|$HOME/.config/amp/AGENTS.md|AGENTS.md|append"
  "crush|Crush|$HOME/.config/crush|$HOME/.config/crush/CRUSH.md|CRUSH.md|append"
  "goose|Goose|$HOME/.config/goose|$HOME/.config/goose/.goosehints|.goosehints|append"
  "pi|Pi|$HOME/.pi/agent|$HOME/.pi/agent/AGENTS.md|AGENTS.md|append"
  "hermes|Hermes|$HOME/.hermes|$HOME/.hermes/SOUL.md||append"
  "windsurf|Windsurf|$HOME/.codeium/windsurf|$HOME/.codeium/windsurf/memories/global_rules.md||append"
  "roo|Roo Code|$HOME/.roo|$HOME/.roo/rules/token-poverty.md|.roo/rules/token-poverty.md|file"
  "cline|Cline|$HOME/Documents/Cline||.clinerules/token-poverty.md|file"
  "continue|Continue|$HOME/.continue||.continue/rules/token-poverty.md|file"
  "cursor|Cursor|$HOME/.cursor||AGENTS.md|append"
)

field() { echo "$1" | cut -d'|' -f"$2"; }
say()  { printf '%s\n' "$*"; }
warn() { printf '%s\n' "$*" >&2; }
die()  { warn "error: $*"; exit 1; }

usage() {
  cat <<USAGE
token-rich-token-poor installer

  ./install.sh                 detect harnesses, ask what to do
  ./install.sh --global        install to user-level config
  ./install.sh --project       install to the current directory
  ./install.sh --only a,b,c    limit to these harness ids
  ./install.sh --yes           skip the confirmation prompt
  ./install.sh --list          show what is detected, change nothing
  ./install.sh --detect        same, machine-readable: id<TAB>label<TAB>target
  ./install.sh --uninstall     remove and restore from the manifest
  ./install.sh --on            Claude Code only: switch the style on
  ./install.sh --off           Claude Code only: switch back to your previous style

Nothing is written before you confirm. Shared files are appended to inside
markers, never overwritten, and every change is recorded so --uninstall can
reverse it exactly.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --global)    SCOPE="global" ;;
    --project)   SCOPE="project" ;;
    --only)      shift; PICK="${1:-}" ;;
    --yes|-y)    ASSUME_YES=1 ;;
    --uninstall) DO_UNINSTALL=1 ;;
    --on)        TOGGLE="on" ;;
    --off)       TOGGLE="off" ;;
    --list)      SCOPE="${SCOPE:-global}"; PICK="__list__" ;;
    --detect)    SCOPE="${SCOPE:-global}"; PICK="__detect__" ;;
    -h|--help)   usage; exit 0 ;;
    *)           die "unknown option: $1" ;;
  esac
  shift
done

# ---------------------------------------------------------------- style source

style_body() {
  local variant="$1" local_file remote
  case "$variant" in
    compact) local_file="$SRC_DIR/prompts/agents-compact.md"; remote="$RAW/prompts/agents-compact.md" ;;
    claude)  local_file="$SRC_DIR/output-styles/token-poverty.md"; remote="$RAW/output-styles/token-poverty.md" ;;
    *)       local_file="$SRC_DIR/prompts/agents.md"; remote="$RAW/prompts/agents.md" ;;
  esac
  if [ -r "$local_file" ]; then
    cat "$local_file"
  else
    curl -fsSL "$remote" || die "could not read $local_file or fetch $remote"
  fi
}

# ---------------------------------------------------------------- detection

detected=()
detect() {
  local rec id label probe
  for rec in "${HARNESSES[@]}"; do
    id="$(field "$rec" 1)"; label="$(field "$rec" 2)"; probe="$(field "$rec" 3)"
    if [ -n "$probe" ] && [ -d "$probe" ]; then
      detected+=("$rec")
    elif type -P "$id" >/dev/null 2>&1; then   # type -P ignores builtins (continue, etc)
      detected+=("$rec")
    fi
  done
  [ ${#detected[@]} -gt 0 ] || die "no agent harnesses detected. Nothing to do."
}

target_for() {
  local rec="$1"
  if [ "$SCOPE" = "project" ]; then
    local p; p="$(field "$rec" 5)"
    [ -n "$p" ] && echo "$PWD/$p" || echo ""
  else
    field "$rec" 4
  fi
}

# ---------------------------------------------------------------- writes

record() { mkdir -p "$STATE_DIR"; printf '%s\t%s\t%s\n' "$1" "$2" "${3:-}" >>"$MANIFEST"; }

markers_present() { [ -f "$1" ] && grep -qF "$MARK_BEGIN" "$1"; }

strip_block() {
  # delete BEGIN..END inclusive, leave everything else untouched
  local f="$1" tmp; tmp="$(mktemp)"
  awk -v b="$MARK_BEGIN" -v e="$MARK_END" '
    index($0,b){skip=1} !skip{print} index($0,e){skip=0}
  ' "$f" >"$tmp" && mv "$tmp" "$f"
}

append_block() {
  local f="$1" variant="${2:-full}" existed=1
  [ -f "$f" ] || existed=0
  mkdir -p "$(dirname "$f")"
  if markers_present "$f"; then
    strip_block "$f"                      # reinstall: replace in place
  fi
  {
    [ -s "$f" ] && echo ""
    echo "<!-- $MARK_BEGIN -->"
    style_body "$variant"
    echo "<!-- $MARK_END -->"
  } >>"$f"
  record "appended_block" "$f" "$existed"
}

write_file() {
  local f="$1" variant="${2:-full}"
  if [ -f "$f" ] && ! markers_present "$f"; then
    warn "  skipped $f — already exists and was not written by this installer"
    return 1
  fi
  mkdir -p "$(dirname "$f")"
  style_body "$variant" >"$f"
  record "created_file" "$f"
}

set_claude_style() {
  local settings="$HOME/.claude/settings.json"
  command -v python3 >/dev/null 2>&1 || { warn "  python3 not found — set outputStyle manually"; return 1; }
  python3 - "$settings" <<'PY'
import json, os, sys
p = sys.argv[1]
os.makedirs(os.path.dirname(p), exist_ok=True)
try:
    with open(p) as fh: cfg = json.load(fh)
except (FileNotFoundError, json.JSONDecodeError):
    cfg = {}
prev = cfg.get("outputStyle")
cfg["outputStyle"] = "Token Poverty"
with open(p, "w") as fh: json.dump(cfg, fh, indent=2); fh.write("\n")
print("" if prev is None else prev)
PY
}

restore_style() {
  # $1 = previous value; empty means the key was absent, so remove it
  command -v python3 >/dev/null 2>&1 || { warn "  python3 not found — reset outputStyle manually"; return 1; }
  python3 - "$HOME/.claude/settings.json" "${1:-}" <<'PY'
import json, sys
p, prev = sys.argv[1], sys.argv[2]
try:
    with open(p) as fh: cfg = json.load(fh)
except Exception:
    sys.exit(0)
if prev:
    cfg["outputStyle"] = prev
else:
    cfg.pop("outputStyle", None)
with open(p, "w") as fh:
    json.dump(cfg, fh, indent=2); fh.write("\n")
PY
}

# ---------------------------------------------------------------- toggle

toggle_on() {
  local f="$HOME/.claude/output-styles/token-poverty.md" prev
  if [ ! -f "$f" ]; then
    mkdir -p "$(dirname "$f")"
    style_body claude >"$f"
    record "created_file" "$f"
  fi
  prev="$(set_claude_style)" || return 1
  grep -q '^claude_style' "$MANIFEST" 2>/dev/null || \
    record "claude_style" "$HOME/.claude/settings.json" "$prev"
  say "Token poor. Style is on."
}

toggle_off() {
  local prev=""
  if [ -f "$MANIFEST" ]; then
    prev="$(awk -F'\t' '$1=="claude_style"{print $3}' "$MANIFEST" | tail -1)"
  fi
  restore_style "$prev"
  if [ -n "$prev" ]; then
    say "Token rich. Style is off, back to \"$prev\"."
  else
    say "Token rich. Style is off."
  fi
}

# ---------------------------------------------------------------- uninstall

uninstall() {
  [ -f "$MANIFEST" ] || die "no manifest at $MANIFEST — nothing recorded to remove."
  local action path extra
  while IFS=$'\t' read -r action path extra; do
    case "$action" in
      created_file)
        [ -f "$path" ] && rm -f "$path" && say "  removed  $path" ;;
      appended_block)
        if [ ! -f "$path" ]; then
          warn "  missing  $path — nothing to do"
        elif markers_present "$path"; then
          strip_block "$path"
          if [ ! -s "$path" ] && [ "$extra" = "0" ]; then
            rm -f "$path"; say "  removed  $path (we created it, now empty)"
          else
            say "  cleaned  $path"
          fi
        else
          warn "  SKIPPED  $path — our markers are gone, file was hand-edited."
          warn "           Leaving it alone. Check it yourself."
        fi ;;
      claude_style)
        restore_style "$extra"
        say "  restored outputStyle${extra:+ to \"$extra\"}" ;;
    esac
  done <"$MANIFEST"
  rm -f "$MANIFEST"
  say ""
  say "Done. You are token rich."
}

# ---------------------------------------------------------------- main

case "$TOGGLE" in
  on)  toggle_on;  exit $? ;;
  off) toggle_off; exit $? ;;
esac

if [ "$DO_UNINSTALL" = "1" ]; then
  say "Removing token-poverty..."
  uninstall
  exit 0
fi

detect

if [ "$PICK" = "__list__" ]; then
  say "Detected:"
  for rec in "${detected[@]}"; do
    printf '  %-10s %-14s %s\n' "$(field "$rec" 1)" "$(field "$rec" 2)" "$(target_for "$rec")"
  done
  exit 0
fi

# machine-readable, for an agent to parse before asking the user anything
if [ "$PICK" = "__detect__" ]; then
  for rec in "${detected[@]}"; do
    printf '%s\t%s\t%s\n' "$(field "$rec" 1)" "$(field "$rec" 2)" "$(target_for "$rec")"
  done
  exit 0
fi

# scope
if [ -z "$SCOPE" ]; then
  say "Install where?"
  say "  1) global   — your user config, applies everywhere"
  say "  2) project  — this directory only ($PWD)"
  printf 'Choice [1]: '
  read -r ans </dev/tty
  case "${ans:-1}" in
    2) SCOPE="project" ;;
    *) SCOPE="global" ;;
  esac
fi

# selection
chosen=()
if [ -n "$PICK" ]; then
  for rec in "${detected[@]}"; do
    case ",$PICK," in *",$(field "$rec" 1),"*) chosen+=("$rec") ;; esac
  done
  [ ${#chosen[@]} -gt 0 ] || die "none of those ids were detected: $PICK"
else
  say ""
  say "Detected these harnesses:"
  i=1
  for rec in "${detected[@]}"; do
    printf '  %d) %-14s %s\n' "$i" "$(field "$rec" 2)" "$(target_for "$rec")"
    i=$((i+1))
  done
  say ""
  say "Which should get the style? Numbers separated by commas, or 'all'."
  printf 'Choice [all]: '
  read -r ans </dev/tty
  ans="${ans:-all}"
  if [ "$ans" = "all" ]; then
    chosen=("${detected[@]}")
  else
    IFS=',' read -ra picks <<<"$ans"
    for n in "${picks[@]}"; do
      n="$(echo "$n" | tr -d ' ')"
      idx=$((n-1))
      [ "$idx" -ge 0 ] && [ "$idx" -lt ${#detected[@]} ] && chosen+=("${detected[$idx]}")
    done
  fi
  [ ${#chosen[@]} -gt 0 ] || die "nothing selected."
fi

# plan
say ""
say "Plan ($SCOPE):"
plan_count=0
for rec in "${chosen[@]}"; do
  t="$(target_for "$rec")"
  if [ -z "$t" ]; then
    printf '  %-14s no %s target — skipping\n' "$(field "$rec" 2)" "$SCOPE"
    continue
  fi
  mode="$(field "$rec" 6)"
  if [ -f "$t" ]; then verb="append to"; else verb="create"; fi
  printf '  %-14s %s %s\n' "$(field "$rec" 2)" "$verb" "$t"
  [ "$mode" = "style" ] && printf '  %-14s set outputStyle in ~/.claude/settings.json\n' ""
  plan_count=$((plan_count+1))
done
[ "$plan_count" -gt 0 ] || die "nothing to do."

say ""
say "Existing files are appended to inside markers. Nothing is overwritten."
if [ "$ASSUME_YES" != "1" ]; then
  printf 'Proceed? [y/N]: '
  read -r ans </dev/tty
  case "$ans" in y|Y|yes|YES) ;; *) say "Aborted. Nothing written."; exit 0 ;; esac
fi

# execute
say ""
for rec in "${chosen[@]}"; do
  t="$(target_for "$rec")"; [ -n "$t" ] || continue
  mode="$(field "$rec" 6)"; label="$(field "$rec" 2)"
  variant="full"
  [ "$(field "$rec" 1)" = "windsurf" ] && variant="compact"   # 6k character cap

  case "$mode" in
    style)
      if write_file "$t" "claude"; then
        prev="$(set_claude_style)" && record "claude_style" "$HOME/.claude/settings.json" "$prev"
      fi
      say "  installed $label -> $t" ;;
    file)
      write_file "$t" "$variant" && say "  installed $label -> $t" ;;
    append)
      append_block "$t" "$variant" && say "  installed $label -> $t" ;;
  esac
done

say ""
say "Done. Recorded in $MANIFEST"
say "Reverse it with: ./install.sh --uninstall"
