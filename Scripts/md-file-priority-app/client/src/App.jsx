import { useEffect, useMemo, useState } from "react";
import { api } from "./api";

const CATEGORY_COLORS = {
  important: "#B8860B",
  reference: "#2563eb",
  archive: "#6b7280",
  ignore: "#dc2626"
};

const CATEGORY_OPTIONS = ["important", "reference", "archive", "ignore"];

function TreeNode({ node, marks, onMark, prefix = "", isLast = true, showRootPath = false }) {
  const mark = marks[node.path];
  const category = mark?.category || null;
  const connector = isLast ? "\\--" : "|--";
  const childPrefix = `${prefix}${isLast ? "    " : "|   "}`;
  const children = node.children || [];

  const isDir = node.type === "directory";
  const typeIcon = isDir ? "📁" : "📄";
  const typeLabel = isDir ? "FOLDER" : "FILE";

  return (
    <>
      <div className={`tree-line-row ${node.type === "directory" ? "directory-row" : "file-row"}`}>
        <span className="tree-prefix">
          {prefix}
          {connector}
        </span>
        <span className={`type-badge ${isDir ? "folder-badge" : "file-badge"}`}>{typeLabel}</span>
        <span className="type-icon">{typeIcon}</span>
        <span className="node-name">
          {node.name}
          {node.type === "directory" ? "/" : ""}
        </span>
        <div className="hover-actions">
          {CATEGORY_OPTIONS.map((item) => (
            <button
              key={`${node.path}-${item}`}
              className={item === category ? "category-chip active" : "category-chip"}
              style={{ borderColor: CATEGORY_COLORS[item], color: CATEGORY_COLORS[item] }}
              onClick={() => onMark(node.path, item, mark?.note || "")}
              title={`Mark as ${item}`}
            >
              {item}
            </button>
          ))}
          <button className="category-chip clear-chip" onClick={() => onMark(node.path, "unreviewed", mark?.note || "")}>
            clear
          </button>
        </div>
      </div>

      {showRootPath && (
        <div className="root-path-inline">
          <span>{node.path}</span>
        </div>
      )}

      {children.map((child, index) => (
        <TreeNode
          key={child.path}
          node={child}
          marks={marks}
          onMark={onMark}
          prefix={childPrefix}
          isLast={index === children.length - 1}
        />
      ))}
    </>
  );
}

function RootTree({ root, marks, onMark }) {
  const children = root.children || [];
  const rootNode = {
    name: root.title,
    path: root.rootPath,
    type: "directory",
    children
  };

  return (
    <div className="root-block">
      <TreeNode node={rootNode} marks={marks} onMark={onMark} showRootPath />
    </div>
  );
}

export default function App() {
  const [roots, setRoots] = useState([]);
  const [marks, setMarks] = useState({});
  const [settings, setSettings] = useState({ reportPath: "", backupOutputPath: "" });
  const [activeTab, setActiveTab] = useState("explorer");
  const [query, setQuery] = useState("");
  const [backupResult, setBackupResult] = useState(null);
  const [error, setError] = useState("");

  async function loadAll() {
    try {
      setError("");
      const [treeRes, marksRes, settingsRes] = await Promise.all([api.getTree(), api.getMarks(), api.getSettings()]);
      setRoots(treeRes.roots || []);
      setMarks(marksRes.items || {});
      setSettings(settingsRes);
    } catch (err) {
      setError(err.message);
    }
  }

  useEffect(() => {
    loadAll();
  }, []);

  async function handleMark(filePath, category, note) {
    try {
      if (category === "unreviewed") {
        await api.clearMark(filePath);
        setMarks((prev) => {
          const next = { ...prev };
          delete next[filePath];
          return next;
        });
        return;
      }
      await api.saveMark({ path: filePath, category, note });
      setMarks((prev) => ({ ...prev, [filePath]: { category, note } }));
    } catch (err) {
      setError(err.message);
    }
  }

  async function saveSettings() {
    try {
      await api.saveSettings(settings);
      await loadAll();
    } catch (err) {
      setError(err.message);
    }
  }

  async function runBackup(dryRun = false) {
    try {
      const result = await api.runBackup(dryRun);
      setBackupResult(result);
    } catch (err) {
      setError(err.message);
    }
  }

  const importantPaths = useMemo(
    () =>
      Object.entries(marks)
        .filter(([, value]) => value.category === "important")
        .map(([key]) => key),
    [marks]
  );

  const filteredRoots = useMemo(() => {
    if (!query.trim()) return roots;
    const lower = query.trim().toLowerCase();
    const filterNode = (node) => {
      const matchedChildren = (node.children || []).map(filterNode).filter(Boolean);
      const selfMatch = node.path.toLowerCase().includes(lower) || node.name.toLowerCase().includes(lower);
      if (selfMatch || matchedChildren.length) return { ...node, children: matchedChildren };
      return null;
    };
    return roots
      .map((root) => ({ ...root, children: root.children.map(filterNode).filter(Boolean) }))
      .filter((root) => root.children.length > 0);
  }, [roots, query]);

  return (
    <div className="app">
      <h1>Markdown Priority Manager</h1>
      <p>Hover a row to mark folder/file. Important category uses gold color.</p>

      <section className="panel">
        <h2>Settings</h2>
        <label>
          Report Path
          <input value={settings.reportPath} onChange={(event) => setSettings((prev) => ({ ...prev, reportPath: event.target.value }))} />
        </label>
        <label>
          Backup Output Path
          <input value={settings.backupOutputPath} onChange={(event) => setSettings((prev) => ({ ...prev, backupOutputPath: event.target.value }))} />
        </label>
        <button onClick={saveSettings}>Save Settings & Reload</button>
      </section>

      <section className="tabs">
        <button className={activeTab === "explorer" ? "active" : ""} onClick={() => setActiveTab("explorer")}>
          Explorer
        </button>
        <button className={activeTab === "important" ? "active" : ""} onClick={() => setActiveTab("important")}>
          Important (Gold)
        </button>
        <button className={activeTab === "backup" ? "active" : ""} onClick={() => setActiveTab("backup")}>
          Backup
        </button>
      </section>

      {error && <p className="error">{error}</p>}

      {activeTab === "explorer" && (
        <section className="panel">
          <input placeholder="Search by path or name..." value={query} onChange={(event) => setQuery(event.target.value)} />
          {filteredRoots.map((root) => (
            <RootTree key={root.rootPath} root={root} marks={marks} onMark={handleMark} />
          ))}
        </section>
      )}

      {activeTab === "important" && (
        <section className="panel">
          <h2>Important Items</h2>
          <p>Total important marked paths: {importantPaths.length}</p>
          <ul>
            {importantPaths.map((filePath) => (
              <li key={filePath} style={{ color: CATEGORY_COLORS.important }}>
                {filePath}
              </li>
            ))}
          </ul>
        </section>
      )}

      {activeTab === "backup" && (
        <section className="panel">
          <h2>Backup</h2>
          <p>Copies all paths marked as important into the backup output folder.</p>
          <div className="actions">
            <button onClick={() => runBackup(true)}>Dry Run</button>
            <button onClick={() => runBackup(false)}>Run Backup</button>
          </div>
          {backupResult && <pre className="result">{JSON.stringify(backupResult, null, 2)}</pre>}
        </section>
      )}
    </div>
  );
}
