const Engine = {
    current: "login", // صفحه شروع (صفحه ورود)
    score: 0,
    currentQuestion: 0,
    questions: [
        { question: "2 + 2 = ?", options: [2, 3, 4, 5], answer: 4 },
        { question: "5 + 3 = ?", options: [7, 8, 9, 10], answer: 8 },
        { question: "3 + 7 = ?", options: [10, 11, 12, 9], answer: 10 }
    ],

    // ورود به اپ
    login: function() {
        var username = document.getElementById("username").value;
        var password = document.getElementById("password").value;
        
        if (username === "admin" && password === "1234") {
            alert("ورود موفقیت‌آمیز بود");
            this.open("lesson");
        } else {
            alert("نام کاربری یا رمز عبور اشتباه است");
        }
    },

    // تغییر صفحه
    open: function(view) {
        document.getElementById("app").innerHTML = "";
        if (view === "lesson") {
            this.loadLessonPage();
        } else if (view === "quiz") {
            this.startQuiz();
        } else if (view === "result") {
            this.showResult();
        }
    },

    // صفحه آموزشی
    loadLessonPage: function() {
        document.getElementById("app").innerHTML = `
            <h1>دوره آموزشی</h1>
            <p>در اینجا محتوای آموزشی به صورت خودکار تولید خواهد شد.</p>
            <button onclick="Engine.startLesson()">شروع دوره</button>
        `;
    },

    // شروع دوره آموزشی
    startLesson: function() {
        document.getElementById("app").innerHTML = `
            <h1>درس 1: مقدمه‌ای بر برنامه‌نویسی</h1>
            <p>در این درس با مبانی اولیه برنامه‌نویسی آشنا می‌شوید.</p>
            <button onclick="Engine.completeLesson()">تمام کردن درس</button>
        `;
    },

    // اتمام درس
    completeLesson: function() {
        document.getElementById("app").innerHTML = `
            <h1>درس تمام شد</h1>
            <p>تبریک! شما درس اول را تمام کردید.</p>
            <button onclick="Engine.open('quiz')">شروع آزمون</button>
        `;
    },

    // شروع آزمون
    startQuiz: function() {
        this.showQuestion(this.questions[this.currentQuestion]);
    },

    // نمایش سوالات
    showQuestion: function(question) {
        document.getElementById("app").innerHTML = `
            <h1>${question.question}</h1>
            ${question.options.map(o => 
                `<button onclick="Engine.selectAnswer(${o}, ${question.answer})">${o}</button>`
            ).join("")}
        `;
    },

    // انتخاب جواب
    selectAnswer: function(selected, correct) {
        if (selected === correct) {
            this.score += 10;
        }
        this.currentQuestion++;

        if (this.currentQuestion < this.questions.length) {
            this.showQuestion(this.questions[this.currentQuestion]);
        } else {
            this.showResult();
        }
    },

    // نمایش نتیجه
    showResult: function() {
        document.getElementById("app").innerHTML = `
            <h1>نتیجه آزمون</h1>
            <p>امتیاز شما: <strong id="score">${this.score}</strong></p>
            <button onclick="Engine.restartQuiz()">شروع دوباره آزمون</button>
        `;
    },

    // شروع دوباره آزمون
    restartQuiz: function() {
        this.score = 0;
        this.currentQuestion = 0;
        this.startQuiz();
    }
};

// آغاز اپلیکیشن با صفحه ورود
Engine.open("login");
