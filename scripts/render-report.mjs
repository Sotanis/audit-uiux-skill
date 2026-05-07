#!/usr/bin/env node
/**
 * Render bao-cao.md → bao-cao.html với shell cố định (Notion-like).
 * Ảnh local trong markdown được nhúng base64 (cùng thư mục chứa .md hoặc đường dẫn tương đối).
 *
 * Usage:
 *   node scripts/render-report.mjs path/to/bao-cao.md
 *   node scripts/render-report.mjs path/to/bao-cao.md -o path/to/out.html
 *   node scripts/render-report.mjs path/to/bao-cao.md --title "Tiêu đề tùy chọn"
 *   node scripts/render-report.mjs path/to/bao-cao.md --no-embed-images
 */

import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { marked } from 'marked';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DEFAULT_SHELL = path.join(__dirname, 'report-shell.html');

const MIME = {
  png: 'image/png',
  jpg: 'image/jpeg',
  jpeg: 'image/jpeg',
  gif: 'image/gif',
  webp: 'image/webp',
  svg: 'image/svg+xml',
};

function escapeHtml(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function escapeAttr(s) {
  return escapeHtml(s).replace(/\n/g, ' ');
}

function extractTitle(md, fallback) {
  const m = md.match(/^#\s+(.+)$/m);
  if (m) return m[1].trim();
  return fallback;
}

function wrapTables(html) {
  let out = html;
  let idx = 0;
  while (true) {
    const start = out.indexOf('<table>', idx);
    if (start === -1) break;
    if (isInsidePreOrCode(out, start)) {
      idx = start + 7;
      continue;
    }
    const end = out.indexOf('</table>', start);
    if (end === -1) break;
    const block = out.slice(start, end + 8);
    if (out.slice(Math.max(0, start - 24), start).includes('table-wrap')) {
      idx = end + 8;
      continue;
    }
    const wrapped = `<div class="table-wrap">${block}</div>`;
    out = out.slice(0, start) + wrapped + out.slice(end + 8);
    idx = start + wrapped.length;
  }
  return out;
}

function isInsidePreOrCode(html, pos) {
  const before = html.slice(0, pos);
  const preOpens = (before.match(/<pre[\s>]/gi) || []).length;
  const preCloses = (before.match(/<\/pre>/gi) || []).length;
  return preOpens > preCloses;
}

function parseArgs(argv) {
  const args = { embedImages: true, shell: DEFAULT_SHELL, out: null, title: null };
  const rest = [];
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--no-embed-images') args.embedImages = false;
    else if (a === '-o' || a === '--output') args.out = argv[++i];
    else if (a === '--shell') args.shell = path.resolve(argv[++i]);
    else if (a === '--title') args.title = argv[++i];
    else if (a === '-h' || a === '--help') args.help = true;
    else if (!a.startsWith('-')) rest.push(a);
  }
  args.input = rest[0] ? path.resolve(rest[0]) : null;
  return args;
}

function embedImageHref(href, baseDir) {
  if (/^https?:\/\//i.test(href) || href.startsWith('data:')) return { src: href, ok: true };
  const abs = path.resolve(baseDir, href);
  if (!existsSync(abs)) return { src: href, ok: false, abs };
  const ext = path.extname(abs).slice(1).toLowerCase();
  const mime = MIME[ext] || 'application/octet-stream';
  const buf = readFileSync(abs);
  return { src: `data:${mime};base64,${buf.toString('base64')}`, ok: true };
}

function buildRenderer(baseDir, embedImages) {
  return {
    image({ href, title, text }) {
      let src = href;
      let missing = '';
      if (embedImages) {
        const r = embedImageHref(href, baseDir);
        src = r.src;
        if (!r.ok) {
          missing = `<!-- ảnh không đọc được: ${escapeHtml(href)} -->\n`;
        }
      }
      const t = title ? ` title="${escapeAttr(title)}"` : '';
      return `${missing}<img src="${escapeAttr(src)}" alt="${escapeAttr(text || '')}"${t}>`;
    },
  };
}

async function main() {
  const args = parseArgs(process.argv);
  if (args.help || !args.input) {
    console.error(`Usage: node scripts/render-report.mjs <bao-cao.md> [-o out.html] [--title "..."] [--shell path] [--no-embed-images]`);
    process.exit(args.help ? 0 : 1);
  }

  if (!existsSync(args.input)) {
    console.error(`File not found: ${args.input}`);
    process.exit(1);
  }
  if (!existsSync(args.shell)) {
    console.error(`Shell not found: ${args.shell}`);
    process.exit(1);
  }

  const md = readFileSync(args.input, 'utf8');
  const baseDir = path.dirname(args.input);
  const fallbackTitle = path.basename(args.input, path.extname(args.input));
  const title = args.title || extractTitle(md, fallbackTitle);

  marked.use({
    gfm: true,
    async: false,
    renderer: buildRenderer(baseDir, args.embedImages),
  });

  let content = marked.parse(md);
  content = wrapTables(content);

  const shell = readFileSync(args.shell, 'utf8');
  if (!shell.includes('{{TITLE}}') || !shell.includes('{{CONTENT}}')) {
    console.error('Shell must contain {{TITLE}} and {{CONTENT}} placeholders.');
    process.exit(1);
  }

  const html = shell.replace('{{TITLE}}', escapeHtml(title)).replace('{{CONTENT}}', content);

  const outPath =
    args.out ||
    path.join(baseDir, path.basename(args.input, path.extname(args.input)) + '.html');

  writeFileSync(outPath, html, 'utf8');
  console.log(`Wrote ${outPath}`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
