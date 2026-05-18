#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/Sotanis/audit-uiux-skill/main"

AGENT_FILES=(
  claude-agent.md
  gate-rules.md
  heuristics.md
  jtbd-framework.md
  checklist.md
  report-template.md
  html-template.md
  PHAM-VI-TIEU-CHI-VA-THAM-CHIEU.md
  SELF-TEST-BAO-CAO.md
)

SCRIPT_FILES=(
  contrast-checker.md
  destructive-action-scanner.md
  friction-scanner.md
  metadata-stat-counter.md
  naming-scanner.md
  spacing-scanner.md
  tap-target-checker.md
  ux-flow-scanner.md
  ux-state-scanner.md
  ux-writing-lint.md
)

# Render HTML cố định (npm run render-report)
RENDER_FILES=(
  render-report.mjs
  report-shell.html
)

green()  { printf '\033[32m%s\033[0m\n' "$1"; }
yellow() { printf '\033[33m%s\033[0m\n' "$1"; }
red()    { printf '\033[31m%s\033[0m\n' "$1"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USE_REMOTE=false

is_local() {
  for f in "${AGENT_FILES[@]}"; do
    [[ ! -f "$SCRIPT_DIR/$f" ]] && return 1
  done
  return 0
}

if ! is_local; then
  USE_REMOTE=true
  TMPDIR_DL="$(mktemp -d)"
  trap 'rm -rf "$TMPDIR_DL"' EXIT
  SCRIPT_DIR="$TMPDIR_DL"

  echo ""
  echo "Dang tai file tu GitHub..."
  echo ""

  for f in "${AGENT_FILES[@]}"; do
    if ! curl -fsSL "$REPO_URL/$f" -o "$TMPDIR_DL/$f" 2>/dev/null; then
      red "Khong tai duoc: $f"
      red "Kiem tra lai REPO_URL trong install.sh hoac ket noi mang."
      exit 1
    fi
    echo "  $f"
  done

  mkdir -p "$TMPDIR_DL/scripts"
  for f in "${SCRIPT_FILES[@]}"; do
    if ! curl -fsSL "$REPO_URL/scripts/$f" -o "$TMPDIR_DL/scripts/$f" 2>/dev/null; then
      yellow "Khong tai duoc scripts/$f (bo qua)"
    else
      echo "  scripts/$f"
    fi
  done

  if ! curl -fsSL "$REPO_URL/package.json" -o "$TMPDIR_DL/package.json" 2>/dev/null; then
    yellow "Khong tai duoc package.json (bo qua render npm)"
  else
    echo "  package.json"
  fi
  for f in "${RENDER_FILES[@]}"; do
    if ! curl -fsSL "$REPO_URL/scripts/$f" -o "$TMPDIR_DL/scripts/$f" 2>/dev/null; then
      yellow "Khong tai duoc scripts/$f (bo qua render)"
    else
      echo "  scripts/$f"
    fi
  done

  green "Tai xong!"
fi

KB_FILES=(
  gate-rules.md
  heuristics.md
  jtbd-framework.md
  checklist.md
  report-template.md
  html-template.md
  PHAM-VI-TIEU-CHI-VA-THAM-CHIEU.md
  SELF-TEST-BAO-CAO.md
)

copy_scripts() {
  local dest="$1"
  mkdir -p "$dest/scripts"
  for f in "${SCRIPT_FILES[@]}"; do
    if [[ -f "$SCRIPT_DIR/scripts/$f" ]]; then
      cp "$SCRIPT_DIR/scripts/$f" "$dest/scripts/"
    fi
  done
}

copy_render_tooling() {
  local dest="$1"
  mkdir -p "$dest/scripts"
  if [[ -f "$SCRIPT_DIR/package.json" ]]; then
    cp "$SCRIPT_DIR/package.json" "$dest/"
  fi
  for f in "${RENDER_FILES[@]}"; do
    if [[ -f "$SCRIPT_DIR/scripts/$f" ]]; then
      cp "$SCRIPT_DIR/scripts/$f" "$dest/scripts/"
    fi
  done
}

npm_install_render() {
  local dest="$1"
  [[ -f "$dest/package.json" ]] || return 0
  if command -v npm >/dev/null 2>&1; then
    echo ""
    yellow "Cai dependency render-report (marked)..."
    if (cd "$dest" && npm install --silent); then
      green "  npm install xong. Chay: cd $dest && npm run render-report -- /path/bao-cao.md"
    else
      yellow "  npm install that bai. Thu tay: cd $dest && npm install"
    fi
  else
    yellow "  Khong co npm trong PATH — bo qua. Cai Node.js (LTS) roi chay: cd $dest && npm install"
  fi
}

install_claude() {
  local dest="$HOME/.claude/agents"
  mkdir -p "$dest"
  cp "$SCRIPT_DIR/claude-agent.md" "$dest/audit-uiux.md"
  for f in "${KB_FILES[@]}"; do
    cp "$SCRIPT_DIR/$f" "$dest/"
  done
  copy_scripts "$dest"
  copy_render_tooling "$dest"
  green "  Claude Code: da copy vao $dest/"
  npm_install_render "$dest"
}

print_mcp_guide() {
  echo ""
  yellow "=== Buoc tiep: Ket noi Figma MCP (official, OAuth) ==="
  echo ""
  echo "Luu y: Claude app (chat truc tiep) KHONG ho tro MCP."
  echo "Ban can dung Claude Code de ket noi Figma MCP."
  echo ""
  echo "Claude Code (preferred):"
  echo "    - Chay: claude plugin install figma@claude-plugins-official"
  echo "    - Mo session Claude Code moi, go /mcp va Authenticate (neu duoc hoi)"
  echo ""
  echo "Claude Code (manual):"
  echo "    - Chay: claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp"
  echo "    - Trong Claude Code: /mcp > figma > Authenticate > Allow Access"
  echo ""
}

echo ""
echo "========================================="
echo "  Audit UI/UX — Cai dat Agent (Claude Code)"
echo "========================================="
echo ""

install_claude
print_mcp_guide

green "=== Cai dat hoan tat! ==="
echo ""
echo "Thu nghiem: mo Claude Code, go:"
echo '  Audit UI/UX cho: https://figma.com/design/XXX/App?node-id=1-2'
echo ""
