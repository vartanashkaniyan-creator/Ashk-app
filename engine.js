const Engine = {
  current: "home",

  command: {
    appName: "Language App",
    pages: [
      { id: "home", title: "خانه", content: "به اپ خوش آمدید" },
      { id: "lesson", title: "آموزش", content: "درس‌ها به صورت خودکار ساخته می‌شوند" },
      { id: "quiz", title: "آزمون", content: "سوالات اینجا تولید می‌شوند" },
      { id: "result", title: "نتیجه", content: "تحلیل نتیجه کاربر" }
    ]
  },

  init() {
    this.renderFromCommand();
    this.open("home");
  },

  renderFromCommand() {
    const app = document.getElementById("app");
    app.innerHTML = "";

    this.command.pages.forEach(page => {
      const section = document.createElement("section");
      section.className = "view";
      section.dataset.view = page.id;

      section.innerHTML = `
        <h1>${page.title}</h1>
        <p>${page.content}</p>
      `;

      app.appendChild(section);
    });
  },

  open(viewName) {
    document.querySelectorAll(".view").forEach(v =>
      v.classList.remove("active")
    );

    const target = document.querySelector(`[data-view="${viewName}"]`);
    if (target) {
      target.classList.add("active");
      this.current = viewName;
    }
  }
};

Engine.init();
