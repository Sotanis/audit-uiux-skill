#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/Sotanis/audit-uiux/main"

AGENT_FILES=(
  SKILL.md
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

install_cursor() {
  local dest="$HOME/.cursor/skills/audit-uiux"
  mkdir -p "$dest"
  cp "$SCRIPT_DIR/SKILL.md" "$dest/"
  for f in "${KB_FILES[@]}"; do
    cp "$SCRIPT_DIR/$f" "$dest/"
  done
  green "  Cursor: da copy vao $dest/"
}

install_claude() {
  local dest="$HOME/.claude/agents"
  mkdir -p "$dest"
  cp "$SCRIPT_DIR/claude-agent.md" "$dest/audit-uiux.md"
  for f in "${KB_FILES[@]}"; do
    cp "$SCRIPT_DIR/$f" "$dest/"
  done
  green "  Claude Code: da copy vao $dest/"
}

print_mcp_guide() {
  echo ""
  yellow "=== Buoc tiep: Ket noi Figma MCP (moi nguoi 1 token) ==="
  echo ""
  echo "1. Tao Figma token:"
  echo "   Figma > Settings > Personal Access Tokens > Generate new token"
  echo "   Quyen: File content — read (them write neu muon dung COOK NOW mode)"
  echo ""

  if [[ "$1" == "cursor" || "$1" == "both" ]]; then
    echo "2a. Cursor: Settings > MCP > + Add new MCP server"
    echo "    Name: figma"
    echo "    Command: npx -y @anthropic-ai/figma-mcp@latest"
    echo "    Environment: FIGMA_ACCESS_TOKEN = <token>"
    echo ""
  fi

  if [[ "$1" == "claude" || "$1" == "both" ]]; then
    echo "2b. Claude Code: go /mcp > Add new MCP server"
    echo "    Name: figma | Command: npx -y @anthropic-ai/figma-mcp@latest"
    echo "    Env: FIGMA_ACCESS_TOKEN = <token> | Scope: User"
    echo ""
  fi
}

echo ""
echo "========================================="
echo "  Audit UI/UX — Cai dat Agent"
echo "========================================="
echo ""
echo "Ban dung cong cu nao?"
echo ""
echo "  1) Cursor"
echo "  2) Claude Code"
echo "  3) Ca hai"
echo ""
if [[ -t 0 ]]; then
  read -rp "Chon (1/2/3): " choice
else
  exec < /dev/tty
  read -rp "Chon (1/2/3): " choice
fi

echo ""

case "$choice" in
  1)
    install_cursor
    print_mcp_guide "cursor"
    ;;
  2)
    install_claude
    print_mcp_guide "claude"
    ;;
  3)
    install_cursor
    install_claude
    print_mcp_guide "both"
    ;;
  *)
    red "Lua chon khong hop le. Chay lai script."
    exit 1
    ;;
esac

green "=== Cai dat hoan tat! ==="
echo ""
echo "Thu nghiem: mo Cursor hoac Claude Code, go:"
echo '  Audit UI/UX cho: https://figma.com/design/XXX/App?node-id=1-2'
echo ""
