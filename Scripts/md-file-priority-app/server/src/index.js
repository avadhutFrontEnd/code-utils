import fs from "node:fs";
import path from "node:path";
import express from "express";
import cors from "cors";

const app = express();
const PORT = 4177;
const appRoot = path.resolve(process.cwd(), "..");
const stateDir = path.join(appRoot, "state");
const settingsPath = path.join(stateDir, "settings.json");
const marksPath = path.join(stateDir, "marks.json");

app.use(cors());
app.use(express.json({ limit: "2mb" }));

function ensureStateFiles() {
  if (!fs.existsSync(stateDir)) fs.mkdirSync(stateDir, { recursive: true });
  if (!fs.existsSync(settingsPath)) {
    fs.writeFileSync(
      settingsPath,
      JSON.stringify(
        {
          reportPath: "",
          backupOutputPath: ""
        },
        null,
        2
      ),
      "utf8"
    );
  }
  if (!fs.existsSync(marksPath)) {
    fs.writeFileSync(
      marksPath,
      JSON.stringify(
        {
          version: 1,
          updatedAt: null,
          items: {}
        },
        null,
        2
      ),
      "utf8"
    );
  }
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJson(filePath, data) {
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2), "utf8");
}

function normalizeSlashes(value) {
  return value.replaceAll("/", "\\");
}

function parseTreeLine(line) {
  const normalized = line.replace(/\t/g, "    ");
  const connectorIndex = normalized.search(/(\|-- |\\-- )/);
  if (connectorIndex < 0) return null;
  const indentPart = normalized.slice(0, connectorIndex);
  const depth = Math.floor(indentPart.length / 4);
  const name = normalized.slice(connectorIndex + 4).trim();
  const isDirectory = name.endsWith("/");
  return { depth, name, isDirectory };
}

function parseMarkdownTreeReport(mdText) {
  const lines = mdText.split(/\r?\n/);
  const roots = [];
  let current = null;
  let inTreeCode = false;
  let stack = [];

  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];

    if (line.startsWith("### ")) {
      current = {
        title: line.replace(/^###\s+\d+\.\s*/, "").trim(),
        rootPath: "",
        fileCount: 0,
        children: []
      };
      roots.push(current);
      inTreeCode = false;
      stack = [];
      continue;
    }

    if (!current) continue;

    if (line.startsWith("| Root Path |")) {
      const match = line.match(/\|\s*Root Path\s*\|\s*`(.+?)`\s*\|/);
      if (match) current.rootPath = normalizeSlashes(match[1]);
      continue;
    }

    if (line.startsWith("| Markdown Files |")) {
      const match = line.match(/\|\s*Markdown Files\s*\|\s*(\d+)/);
      if (match) current.fileCount = Number(match[1]);
      continue;
    }

    if (line.trim() === "```text") {
      inTreeCode = true;
      stack = [];
      continue;
    }

    if (line.trim() === "```") {
      inTreeCode = false;
      continue;
    }

    if (!inTreeCode) continue;

    if (line.trim() === "" || line.trim() === current.rootPath) continue;
    if (line.includes("... (tree truncated)") || line.includes("... (+")) continue;

    const parsed = parseTreeLine(line);
    if (!parsed) continue;

    const cleanName = parsed.isDirectory ? parsed.name.slice(0, -1) : parsed.name;
    const parentPath = parsed.depth === 0 ? current.rootPath : stack[parsed.depth - 1]?.path || current.rootPath;
    const fullPath = normalizeSlashes(path.join(parentPath, cleanName));
    const node = {
      name: cleanName,
      path: fullPath,
      type: parsed.isDirectory ? "directory" : "file",
      children: []
    };

    if (parsed.depth === 0) {
      current.children.push(node);
    } else {
      const parent = stack[parsed.depth - 1];
      if (parent) parent.children.push(node);
      else current.children.push(node);
    }

    stack[parsed.depth] = node;
    stack.length = parsed.depth + 1;
  }

  return roots;
}

function flattenNodes(nodes, out = []) {
  for (const node of nodes) {
    out.push(node);
    if (node.children?.length) flattenNodes(node.children, out);
  }
  return out;
}

function copyPath(src, dest) {
  const stats = fs.statSync(src);
  if (stats.isDirectory()) {
    fs.mkdirSync(dest, { recursive: true });
    const entries = fs.readdirSync(src, { withFileTypes: true });
    for (const entry of entries) {
      copyPath(path.join(src, entry.name), path.join(dest, entry.name));
    }
    return;
  }

  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.copyFileSync(src, dest);
}

ensureStateFiles();

app.get("/api/health", (_req, res) => {
  res.json({ ok: true });
});

app.get("/api/settings", (_req, res) => {
  res.json(readJson(settingsPath));
});

app.post("/api/settings", (req, res) => {
  const current = readJson(settingsPath);
  const next = { ...current, ...req.body };
  writeJson(settingsPath, next);
  res.json(next);
});

app.get("/api/marks", (_req, res) => {
  res.json(readJson(marksPath));
});

app.post("/api/marks", (req, res) => {
  const { path: itemPath, category, note = "" } = req.body || {};
  if (!itemPath || !category) {
    return res.status(400).json({ error: "path and category are required" });
  }

  const marks = readJson(marksPath);
  marks.items[itemPath] = { category, note };
  marks.updatedAt = new Date().toISOString();
  writeJson(marksPath, marks);
  return res.json(marks.items[itemPath]);
});

app.delete("/api/marks", (req, res) => {
  const { path: itemPath } = req.body || {};
  if (!itemPath) return res.status(400).json({ error: "path is required" });

  const marks = readJson(marksPath);
  delete marks.items[itemPath];
  marks.updatedAt = new Date().toISOString();
  writeJson(marksPath, marks);
  return res.json({ ok: true });
});

app.get("/api/tree", (_req, res) => {
  const { reportPath } = readJson(settingsPath);
  if (!reportPath || !fs.existsSync(reportPath)) {
    return res.status(400).json({ error: "Report file not found. Update settings.reportPath first." });
  }

  const report = fs.readFileSync(reportPath, "utf8");
  const roots = parseMarkdownTreeReport(report);
  return res.json({ roots });
});

app.get("/api/important", (_req, res) => {
  const marks = readJson(marksPath);
  const { reportPath } = readJson(settingsPath);
  if (!reportPath || !fs.existsSync(reportPath)) {
    return res.status(400).json({ error: "Report file not found." });
  }

  const report = fs.readFileSync(reportPath, "utf8");
  const roots = parseMarkdownTreeReport(report);
  const allNodes = flattenNodes(roots.flatMap((r) => r.children));
  const importantPaths = new Set(
    Object.entries(marks.items)
      .filter(([, value]) => value?.category === "important")
      .map(([key]) => normalizeSlashes(key))
  );

  const important = allNodes.filter((node) => importantPaths.has(normalizeSlashes(node.path)));
  return res.json({ important });
});

app.post("/api/backup/run", (req, res) => {
  const { dryRun = false } = req.body || {};
  const marks = readJson(marksPath);
  const { backupOutputPath } = readJson(settingsPath);
  if (!backupOutputPath) return res.status(400).json({ error: "backupOutputPath is empty in settings." });

  const importantPaths = Object.entries(marks.items)
    .filter(([, value]) => value?.category === "important")
    .map(([key]) => normalizeSlashes(key))
    .filter((filePath) => fs.existsSync(filePath));

  const copied = [];
  const skipped = [];

  fs.mkdirSync(backupOutputPath, { recursive: true });

  for (const source of importantPaths) {
    const safeName = source.replace(/[:\\\/]/g, "_");
    const destination = path.join(backupOutputPath, safeName);
    if (dryRun) {
      copied.push({ source, destination, dryRun: true });
      continue;
    }

    try {
      copyPath(source, destination);
      copied.push({ source, destination });
    } catch (error) {
      skipped.push({ source, reason: error.message });
    }
  }

  return res.json({ copied, skipped, totalImportant: importantPaths.length, dryRun });
});

app.listen(PORT, () => {
  console.log(`md-file-priority server running on http://localhost:${PORT}`);
});
