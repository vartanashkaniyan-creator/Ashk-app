function generate() {
  const raw = document.getElementById("command").value;
  const cfg = {};

  raw.split("\n").forEach(line => {
    const [k, v] = line.split("=");
    if (k && v) cfg[k.trim()] = v.trim();
  });

  // ===== Resolver =====
  const screens = (cfg.SCREENS || "").split(",");
  const dark = cfg.THEME === "dark";
  const rtl = cfg.RTL === "true";

  // ===== UI Generator =====
  let ui = `<h2>${cfg.APP_NAME || "My App"}</h2>`;

  if (screens.includes("home")) {
    ui += `<button onclick="go('lesson')">📘 درس‌ها</button>`;
  }

  if (screens.includes("lesson")) {
    ui += `
      <div id="lesson" class="page">
        <h3>Lesson 1</h3>
        <p>Hello = سلام</p>
      </div>`;
  }

  if (cfg.QUIZ) {
    ui += `
      <div class="quiz">
        <p>سلام یعنی؟</p>
        <button onclick="score(1)">Hello</button>
        <button onclick="score(0)">Bye</button>
      </div>`;
  }

  // ===== Logic Generator =====
  let logic = `
    let totalScore = 0;
    function go(id){
      document.querySelectorAll('.page').forEach(p=>p.style.display='none');
      document.getElementById(id).style.display='block';
    }
    function score(v){
      totalScore += v;
      ${cfg.SCORE ? "alert('امتیاز: '+totalScore)" : ""}
      ${cfg.USER_PROGRESS ? "localStorage.setItem('score',totalScore);" : ""}
    }
  `;

  // ===== App Template =====
  const app = `
  <html>
  <head>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <style>
      body{
        font-family:${cfg.FONT || "sans-serif"};
        background:${dark ? "#0f172a" : "#fff"};
        color:${dark ? "#fff" : "#000"};
        direction:${rtl ? "rtl" : "ltr"};
        padding:15px;
      }
      button{
        width:100%;padding:12px;margin:6px 0;
        border-radius:12px;border:none;
      }
      .page{display:none}
    </style>
  </head>
  <body>
    ${ui}
    <script>${logic}<\/script>
  </body>
  </html>
  `;

  document.getElementById("preview").srcdoc = app;
}
