// دیکشنری زبان
const dictionary = {
  note: ["note", "یادداشت"],
  login: ["login", "ورود", "لاگین"],
  list: ["list", "لیست"],
  save: ["save", "ذخیره"],
  condition: ["if", "اگر"]
};

// تحلیل دستور
function parse(text) {
  let result = [];

  for (let key in dictionary) {
    dictionary[key].forEach(word => {
      if (text.toLowerCase().includes(word)) {
        if (!result.includes(key)) result.push(key);
      }
    });
  }
  return result;
}

// تولید خروجی
function generateCode(blocks) {
  let output = "";

  if (blocks.includes("login"))
    output += "✔ Login Screen\n";

  if (blocks.includes("note"))
    output += "✔ Note Feature\n";

  if (blocks.includes("list"))
    output += "✔ List View\n";

  if (blocks.includes("save"))
    output += "✔ Local Storage\n";

  if (blocks.includes("condition"))
    output += "✔ Conditional Logic\n";

  return output || "❌ قابلیتی شناسایی نشد";
}

// دکمه ساخت اپ
function buildApp() {
  const text = document.getElementById("command").value;
  const blocks = parse(text);
  const output = generateCode(blocks);

  document.getElementById("output").innerText =
    "Blocks:\n" +
    JSON.stringify(blocks, null, 2) +
    "\n\nResult:\n" +
    output;
}
