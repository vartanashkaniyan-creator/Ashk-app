document.addEventListener("DOMContentLoaded", () => {
  const btn = document.getElementById("generateBtn");
  const input = document.getElementById("commandInput");
  const output = document.getElementById("output");

  btn.addEventListener("click", () => {
    const command = input.value.trim().toLowerCase();

    if (!command) {
      output.textContent = "❗ دستور وارد کن";
      return;
    }

    if (command.includes("todo") || command.includes("لیست")) {
      output.textContent = `
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Todo App</title>
</head>
<body>
<h2>Todo App</h2>
<input placeholder="New task">
<button>Add</button>
</body>
</html>
      `;
    } else {
      output.textContent = "❌ دستور شناخته نشد";
    }
  });
});
