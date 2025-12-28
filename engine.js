const COMMAND = {
  app: {
    type: ["education", "form", "offline"],
    language: ["fa", "en"],
    pages: ["lesson", "quiz", "result"]
  }
};

function renderApp(cmd) {
  const app = document.getElementById("app");
  app.innerHTML = "";

  cmd.app.pages.forEach(page => {
    const card = document.createElement("div");
    card.className = "card";

    card.innerHTML = `
      <h3>${page.toUpperCase()}</h3>
      <p>Generated automatically</p>
      <button>Open</button>
    `;

    app.appendChild(card);
  });
}

renderApp(COMMAND);
