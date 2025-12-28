const Engine = {
  current: "home",
  lang: "fa",
  score: 0,

  command: {
    languages: {
      fa: {
        home: "خانه",
        lesson: "آموزش",
        quiz: "آزمون",
        result: "نتیجه",
        welcome: "به اپ خوش آمدید",
        startQuiz: "شروع آزمون",
        yourScore: "امتیاز شما"
      },
      en: {
        home: "Home",
        lesson: "Lesson",
        quiz: "Quiz",
        result: "Result",
        welcome: "Welcome to the app",
        startQuiz: "Start Quiz",
        yourScore: "Your Score"
      }
    },

    pages: [
      { id: "home", type: "static" },
      { id: "lesson", type: "content", text: "محتوای آموزشی به‌صورت خودکار ساخته شد." },
      {
        id: "quiz",
        type: "quiz",
        question: "2 + 2 = ?",
        options: [2, 3, 4, 5],
        answer: 4
      },
      { id: "result", type: "result" }
    ]
  },

  t(key) {
    return this.command.languages[this.lang][key];
  },

  init() {
    this.render();
    this.open("home");
  },

  render() {
    const app = document.getElementById("app");
    app.innerHTML = "";

    this.command.pages.forEach(p => {
      const s = document.createElement("section");
      s.className = "view";
      s.dataset.view = p.id;

      if (p.type === "static") {
        s.innerHTML = `<h1>${this.t("home")}</h1><p>${this.t("welcome")}</p>`;
      }

      if (p.type === "content") {
        s.innerHTML = `<h1>${this.t("lesson")}</h1><p>${p.text}</p>`;
      }

      if (p.type === "quiz") {
        s.innerHTML = `
          <h1>${this.t("quiz")}</h1>
          <p>${p.question}</p>
          ${p.options.map(o =>
            `<button onclick="Engine.answer(${o}, ${p.answer})">${o}</button>`
          ).join("")}
        `;
      }

      if (p.type === "result") {
        s.innerHTML = `
          <h1>${this.t("result")}</h1>
          <p>${this.t("yourScore")}: <strong id="score">0</strong></p>
        `;
      }

      app.appendChild(s);
    });
  },

  answer(selected, correct) {
    if (selected === correct) this.score += 10;
    document.getElementById("score").innerText = this.score;
    this.open("result");
  },

  open(view) {
    document.querySelectorAll(".view").forEach(v => v.classList.remove("active"));
    document.querySelector(`[data-view="${view}"]`)?.classList.add("active");
    this.current = view;
  }
};

Engine.init();
