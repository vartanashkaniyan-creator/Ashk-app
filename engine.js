const Engine = {
  current: "home",
  score: 0,

  pages: [
    { id: "home", type: "home" },
    {
      id: "lesson",
      type: "lesson",
      text: "این محتوا به‌صورت خودکار توسط موتور ساخته شده است."
    },
    {
      id: "quiz",
      type: "quiz",
      question: "2 + 2 = ؟",
      options: [2, 3, 4, 5],
      answer: 4
    },
    { id: "result", type: "result" }
  ],

  init() {
    this.render();
    this.open("home");
  },

  render() {
    const app = document.getElementById("app");
    app.innerHTML = "";

    this.pages.forEach(p => {
      const s = document.createElement("section");
      s.className = "view";
      s.dataset.view = p.id;

      if (p.type === "home") {
        s.innerHTML = `
          <div class="card">
            <h2>خوش آمدید</h2>
            <p>این یک اپ ساخته‌شده با موتور دستور است.</p>
          </div>
        `;
      }

      if (p.type === "lesson") {
        s.innerHTML = `
          <div class="card">
            <h2>آموزش</h2>
            <p>${p.text}</p>
          </div>
        `;
      }

      if (p.type === "quiz") {
        s.innerHTML = `
          <div class="card">
            <h2>آزمون</h2>
            <p>${p.question}</p>
            ${p.options.map(o =>
              `<button class="option" onclick="Engine.answer(${o}, ${p.answer})">${o}</button>`
            ).join("")}
          </div>
        `;
      }

      if (p.type === "result") {
        s.innerHTML = `
          <div class="card">
            <h2>نتیجه</h2>
            <p>امتیاز شما: <strong>${this.score}</strong></p>
          </div>
        `;
      }

      app.appendChild(s);
    });
  },

  answer(selected, correct) {
    if (selected === correct) this.score += 10;
    this.render();
    this.open("result");
  },

  open(view) {
    document.querySelectorAll(".view").forEach(v =>
      v.classList.remove("active")
    );
    document.querySelector(`[data-view="${view}"]`).classList.add("active");
    this.current = view;
  }
};

Engine.init();
