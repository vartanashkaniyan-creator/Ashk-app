/*************************
 * DICTIONARY (FA + EN)
 *************************/
const DICTIONARY = {
  note: ["note", "یادداشت"],
  list: ["list", "لیست"],
  save: ["save", "ذخیره"],
  login: ["login", "ورود", "لاگین"],
  settings: ["settings", "تنظیمات"],
  heavy: ["heavy", "حرفه‌ای", "سنگین"]
};

/*************************
 * PARSER
 *************************/
function parseCommand(text) {
  const t = text.toLowerCase();
  const blocks = [];

  for (let key in DICTIONARY) {
    DICTIONARY[key].forEach(word => {
      if (t.includes(word) && !blocks.includes(key)) {
        blocks.push(key);
      }
    });
  }
  return blocks;
}

/*************************
 * BLUEPRINT
 *************************/
function buildBlueprint(blocks) {
  return {
    note: blocks.includes("note"),
    list: blocks.includes("list"),
    save: blocks.includes("save"),
    login: blocks.includes("login"),
    settings: blocks.includes("settings"),
    heavy: blocks.includes("heavy")
  };
}

/*************************
 * REAL APP GENERATOR
 *************************/
function generateRealApp(bp) {
  let html = `
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
body{font-family:sans-serif;background:#0f172a;color:#fff;padding:16px}
input,textarea,button{width:100%;margin:6px 0;padding:8px;border-radius:6px;border:none}
button{background:#22c55e;color:#000;font-weight:bold}
.card{background:#020617;padding:12px;border-radius:8px;margin-top:10px}
</style>
</head>
<body>
<h2>My App</h2>
`;

  /* LOGIN */
  if (bp.login) {
    html += `
<div class="card">
<h3>Login</h3>
<input placeholder="Username">
<input type="password" placeholder="Password">
<button>Login</button>
</div>
`;
  }

  /* NOTE */
  if (bp.note) {
    html += `
<div class="card">
<h3>Note</h3>
<textarea id="noteText" placeholder="Write note..."></textarea>
<button onclick="saveNote()">Save</button>
<p id="noteView"></p>
</div>
`;
  }

  /* LIST */
  if (bp.list) {
    html += `
<div class="card">
<h3>List</h3>
<input id="itemInput" placeholder="New item">
<button onclick="addItem()">Add</button>
<ul id="list"></ul>
</div>
`;
  }

  /* SETTINGS */
  if (bp.settings) {
    html += `
<div class="card">
<h3>Settings</h3>
<p>Dark mode enabled</p>
</div>
`;
  }

  /* SCRIPT */
  html += `
<script>
function saveNote(){
  const t=document.getElementById("noteText").value;
  document.getElementById("noteView").innerText=t;
  ${bp.save ? 'localStorage.setItem("note",t);' : ''}
}
function addItem(){
  const v=document.getElementById("itemInput").value;
  const li=document.createElement("li");
  li.innerText=v;
  document.getElementById("list").appendChild(li);
}
${bp.save ? `
window.onload=function(){
  const n=localStorage.getItem("note");
  if(n) document.getElementById("noteView").innerText=n;
}
` : ''}
</script>

</body>
</html>
`;

  return html;
}

/*************************
 * MAIN
 *************************/
function buildApp() {
  const cmd = document.getElementById("command").value;
  const blocks = parseCommand(cmd);
  const blueprint = buildBlueprint(blocks);
  const appCode = generateRealApp(blueprint);

  document.getElementById("output").innerHTML = appCode;
}
