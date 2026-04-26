const API_BASE = "http://localhost:4177/api";

async function request(url, options = {}) {
  const response = await fetch(`${API_BASE}${url}`, {
    headers: { "Content-Type": "application/json" },
    ...options
  });
  if (!response.ok) {
    const payload = await response.json().catch(() => ({}));
    throw new Error(payload.error || `Request failed: ${response.status}`);
  }
  return response.json();
}

export const api = {
  getTree: () => request("/tree"),
  getSettings: () => request("/settings"),
  saveSettings: (data) => request("/settings", { method: "POST", body: JSON.stringify(data) }),
  getMarks: () => request("/marks"),
  saveMark: (payload) => request("/marks", { method: "POST", body: JSON.stringify(payload) }),
  clearMark: (path) => request("/marks", { method: "DELETE", body: JSON.stringify({ path }) }),
  getImportant: () => request("/important"),
  runBackup: (dryRun = false) => request("/backup/run", { method: "POST", body: JSON.stringify({ dryRun }) })
};
