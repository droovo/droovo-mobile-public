// Droovo Public Helpers — project dashboard
// Reads public data from the GitHub REST API (no auth, no backend) and
// renders it. Nothing here writes anywhere or touches user data.

const REPO = "droovo/droovo-mobile-public";
const API = `https://api.github.com/repos/${REPO}`;
const CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes — keeps us comfortably under
// GitHub's unauthenticated rate limit (60 requests/hour per IP) across
// repeat visits/refreshes.

// --- fetch helper with localStorage caching ----------------------------

async function cachedFetch(url) {
  const cacheKey = `gh-cache:${url}`;
  const cached = localStorage.getItem(cacheKey);
  if (cached) {
    try {
      const { timestamp, data } = JSON.parse(cached);
      if (Date.now() - timestamp < CACHE_TTL_MS) return data;
    } catch (_) {
      /* corrupt cache entry, ignore and refetch */
    }
  }

  const res = await fetch(url, {
    headers: { Accept: "application/vnd.github+json" },
  });

  if (!res.ok) {
    if (res.status === 403) {
      throw new Error(
        "GitHub API rate limit reached for your IP — try again in a few minutes."
      );
    }
    throw new Error(`GitHub API error ${res.status} for ${url}`);
  }

  const data = await res.json();
  try {
    localStorage.setItem(
      cacheKey,
      JSON.stringify({ timestamp: Date.now(), data })
    );
  } catch (_) {
    /* storage full/unavailable — fine, just skip caching */
  }
  return data;
}

// --- small utilities -----------------------------------------------------

function escapeHtml(str) {
  return String(str ?? "").replace(
    /[&<>"']/g,
    (c) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[
        c
      ])
  );
}

function timeAgo(isoDate) {
  const diffMs = Date.now() - new Date(isoDate).getTime();
  const mins = Math.round(diffMs / 60000);
  if (mins < 1) return "just now";
  if (mins < 60) return `${mins}m ago`;
  const hours = Math.round(mins / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.round(hours / 24);
  if (days < 30) return `${days}d ago`;
  const months = Math.round(days / 30);
  if (months < 12) return `${months}mo ago`;
  return `${Math.round(months / 12)}y ago`;
}

function shortSha(sha) {
  return (sha || "").slice(0, 7);
}

function setListHtml(id, html) {
  document.getElementById(id).innerHTML = html;
}

// Sets a stat card's value and clears its loading shimmer. Without the
// classList.remove, the value stays invisible: .skeleton forces
// `color: transparent` and plain text (or a plain <a>, which inherits
// color) has nothing else to override it with.
function setStatValue(cardId, html) {
  const el = document.getElementById(cardId).querySelector(".stat-value");
  el.innerHTML = html;
  el.classList.remove("skeleton");
}

function showError(message) {
  const banner = document.getElementById("error-banner");
  banner.textContent = message;
  banner.hidden = false;
}

// --- tabs ------------------------------------------------------------------

function initTabs() {
  const tabs = document.querySelectorAll(".tab");
  const panels = {
    activity: document.getElementById("panel-activity"),
    contributors: document.getElementById("panel-contributors"),
    pulls: document.getElementById("panel-pulls"),
    branches: document.getElementById("panel-branches"),
    builds: document.getElementById("panel-builds"),
    downloads: document.getElementById("panel-downloads"),
  };

  function activate(name) {
    tabs.forEach((t) => {
      const isActive = t.dataset.tab === name;
      t.classList.toggle("active", isActive);
      t.setAttribute("aria-selected", String(isActive));
    });
    Object.entries(panels).forEach(([key, el]) => {
      el.hidden = key !== name;
    });
  }

  tabs.forEach((t) =>
    t.addEventListener("click", () => activate(t.dataset.tab))
  );
  document.querySelectorAll(".switch-tab").forEach((el) =>
    el.addEventListener("click", (e) => {
      e.preventDefault();
      activate(el.dataset.tab);
    })
  );
}

// --- data loading & rendering ----------------------------------------------

async function loadActivity() {
  const commits = await cachedFetch(`${API}/commits?sha=main&per_page=20`);
  setListHtml(
    "list-activity",
    commits
      .map((c) => {
        const author = c.author;
        const avatar = author
          ? `<img class="avatar" src="${author.avatar_url}&s=56" alt="" />`
          : "";
        const authorName = escapeHtml(
          author?.login || c.commit.author?.name || "unknown"
        );
        const title = escapeHtml(c.commit.message.split("\n")[0]);
        return `<li class="list-item">
          ${avatar}
          <div class="item-main">
            <div class="item-title"><a href="${c.html_url}" target="_blank" rel="noopener">${title}</a></div>
            <div class="item-meta">${authorName} · <code>${shortSha(c.sha)}</code> · ${timeAgo(c.commit.author?.date)}</div>
          </div>
        </li>`;
      })
      .join("") || `<li class="empty-state">No commits found.</li>`
  );
}

async function loadContributors() {
  const contributors = await cachedFetch(`${API}/contributors?per_page=20`);
  const medals = ["🥇", "🥈", "🥉"];

  setListHtml(
    "list-contributors",
    contributors
      .map((c, i) => {
        const rank = medals[i] || `#${i + 1}`;
        return `<li class="list-item">
          <span class="rank">${rank}</span>
          <img class="avatar" src="${c.avatar_url}&s=56" alt="" />
          <div class="item-main">
            <div class="item-title"><a href="${c.html_url}" target="_blank" rel="noopener">${escapeHtml(c.login)}</a></div>
          </div>
          <span class="badge badge-neutral">${c.contributions} commit${c.contributions === 1 ? "" : "s"}</span>
        </li>`;
      })
      .join("") ||
      `<li class="empty-state">No contributors yet — be the first! See <a href="https://github.com/${REPO}/blob/main/CONTRIBUTING.md" target="_blank" rel="noopener">CONTRIBUTING.md</a>.</li>`
  );
}

async function loadPulls() {
  const pulls = await cachedFetch(
    `${API}/pulls?state=all&sort=updated&direction=desc&per_page=20`
  );

  setStatValue(
    "stat-pulls",
    String(pulls.filter((p) => p.state === "open").length)
  );

  setListHtml(
    "list-pulls",
    pulls
      .map((p) => {
        let badgeClass = "badge-neutral";
        let badgeText = "closed";
        if (p.state === "open") {
          badgeClass = "badge-pending";
          badgeText = "open";
        } else if (p.merged_at) {
          badgeClass = "badge-success";
          badgeText = "merged";
        }
        return `<li class="list-item">
          <img class="avatar" src="${p.user.avatar_url}&s=56" alt="" />
          <div class="item-main">
            <div class="item-title"><a href="${p.html_url}" target="_blank" rel="noopener">${escapeHtml(p.title)}</a></div>
            <div class="item-meta">#${p.number} by ${escapeHtml(p.user.login)} · ${escapeHtml(p.head.ref)} → ${escapeHtml(p.base.ref)} · updated ${timeAgo(p.updated_at)}</div>
          </div>
          <span class="badge ${badgeClass}">${badgeText}</span>
        </li>`;
      })
      .join("") ||
      `<li class="empty-state">No pull requests yet — be the first! See <a href="https://github.com/${REPO}/blob/main/CONTRIBUTING.md" target="_blank" rel="noopener">CONTRIBUTING.md</a>.</li>`
  );
}

async function loadBranches() {
  const branches = await cachedFetch(`${API}/branches?per_page=50`);

  setStatValue("stat-branches", String(branches.length));

  setListHtml(
    "list-branches",
    branches
      .map((b) => {
        const isDefault = b.name === "main";
        return `<li class="list-item">
          <div class="item-main">
            <div class="item-title">
              <a href="https://github.com/${REPO}/tree/${encodeURIComponent(b.name)}" target="_blank" rel="noopener">${escapeHtml(b.name)}</a>
              ${isDefault ? '<span class="badge badge-neutral">default</span>' : ""}
            </div>
            <div class="item-meta">latest commit <code>${shortSha(b.commit.sha)}</code></div>
          </div>
        </li>`;
      })
      .join("") || `<li class="empty-state">No branches found.</li>`
  );
}

function runStatusBadge(run) {
  if (run.status !== "completed") {
    return { cls: "badge-pending", text: run.status.replace("_", " ") };
  }
  if (run.conclusion === "success") return { cls: "badge-success", text: "passed" };
  if (run.conclusion === "failure") return { cls: "badge-failure", text: "failed" };
  return { cls: "badge-neutral", text: run.conclusion || "unknown" };
}

async function loadBuilds() {
  const data = await cachedFetch(`${API}/actions/runs?per_page=20`);
  const runs = data.workflow_runs || [];

  if (runs.length > 0) {
    const latest = runs[0];
    const status = runStatusBadge(latest);
    setStatValue(
      "stat-build",
      `<a href="${latest.html_url}" target="_blank" rel="noopener"><span class="badge ${status.cls}">${status.text}</span></a>`
    );
  } else {
    setStatValue("stat-build", "—");
  }

  setListHtml(
    "list-builds",
    runs
      .map((r) => {
        const status = runStatusBadge(r);
        return `<li class="list-item">
          <div class="item-main">
            <div class="item-title"><a href="${r.html_url}" target="_blank" rel="noopener">${escapeHtml(r.display_title || r.name)}</a></div>
            <div class="item-meta">${escapeHtml(r.head_branch)} · <code>${shortSha(r.head_sha)}</code> · ${timeAgo(r.created_at)}</div>
          </div>
          <span class="badge ${status.cls}">${status.text}</span>
        </li>`;
      })
      .join("") || `<li class="empty-state">No CI runs yet.</li>`
  );
}

function formatBytes(bytes) {
  if (!bytes) return "";
  const units = ["B", "KB", "MB", "GB"];
  let i = 0;
  let n = bytes;
  while (n >= 1024 && i < units.length - 1) {
    n /= 1024;
    i++;
  }
  return `${n.toFixed(1)} ${units[i]}`;
}

async function loadDownloads() {
  const releases = await cachedFetch(`${API}/releases?per_page=10`);

  if (releases.length > 0) {
    const latest = releases[0];
    setStatValue(
      "stat-release",
      `<a href="${latest.html_url}" target="_blank" rel="noopener">${escapeHtml(latest.tag_name)}</a>`
    );
  } else {
    setStatValue("stat-release", "none yet");
  }

  setListHtml(
    "list-downloads",
    releases
      .map((r) => {
        const assets = (r.assets || [])
          .map(
            (a) =>
              `<a href="${a.browser_download_url}">${escapeHtml(a.name)} (${formatBytes(a.size)})</a>`
          )
          .join("");
        return `<li class="list-item">
          <div class="item-main">
            <div class="item-title"><a href="${r.html_url}" target="_blank" rel="noopener">${escapeHtml(r.name || r.tag_name)}</a></div>
            <div class="item-meta">published ${timeAgo(r.published_at)}</div>
            <div class="download-links">${assets || '<span class="item-meta">no build files attached</span>'}</div>
          </div>
        </li>`;
      })
      .join("") ||
      `<li class="empty-state">No tagged releases yet. Once a maintainer pushes a version tag, the APK/AAB/web build will download directly from here — no GitHub login needed. In the meantime, see the <a href="#" class="switch-tab" data-tab="builds">Builds</a> tab.</li>`
  );

  // Re-bind any new .switch-tab links just inserted into the DOM.
  document.querySelectorAll("#list-downloads .switch-tab").forEach((el) =>
    el.addEventListener("click", (e) => {
      e.preventDefault();
      document.querySelector(`.tab[data-tab="${el.dataset.tab}"]`)?.click();
    })
  );
}

// --- boot --------------------------------------------------------------

async function main() {
  initTabs();

  const loaders = [
    ["Activity", loadActivity],
    ["Contributors", loadContributors],
    ["Pull requests", loadPulls],
    ["Branches", loadBranches],
    ["Builds", loadBuilds],
    ["Downloads", loadDownloads],
  ];

  const results = await Promise.allSettled(loaders.map(([, fn]) => fn()));
  const failed = results
    .map((r, i) => (r.status === "rejected" ? loaders[i][0] : null))
    .filter(Boolean);

  if (failed.length > 0) {
    console.error(
      results.filter((r) => r.status === "rejected").map((r) => r.reason)
    );
    showError(
      `Couldn't load: ${failed.join(", ")}. ${results.find((r) => r.status === "rejected")?.reason?.message || ""}`
    );
  }
}

main();
