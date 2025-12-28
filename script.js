function generateCode() {
  const cmd = document.getElementById("command").value;
  const out = document.getElementById("output");

  if (cmd.includes("note")) {
    out.textContent =
`// Android Java Code
EditText note;
Button save;

save.setOnClickListener(v -> {
  // save note
});`;
  } 
  else {
    out.textContent = "// دستور شناخته نشد";
  }
}
