const Engine = {
    current: "login", // صفحه شروع (صفحه ورود)
    lang: "fa", // زبان پیش‌فرض
    score: 0,
    currentQuestion: 0,
    questions: [
        { question: "2 + 2 = ?", options: [2, 3, 4, 5], answer: 4 },
        { question: "5 + 3 = ?", options: [7, 8, 9, 10], answer: 8 },
        { question: "3 + 7 = ?", options: [10, 11, 12, 9], answer: 10 }
    ],
    languagePack: {
        fa: {
            loginTitle: "ورود به اپ",
            loginButton: "ورود",
            lessonTitle: "دوره آموزشی",
            startLesson: "شروع دوره",
            completeLesson: "تمام کردن درس",
            quizTitle: "آزمون",
            resultTitle: "نتیجه آزمون",
            resultMessage: "امتیاز شما"
        },
        en: {
            loginTitle: "Login",
            loginButton: "Login",
            lessonTitle: "Lesson",
            startLesson: "Start Lesson",
            completeLesson: "Complete Lesson",
            quizTitle: "Quiz",
            resultTitle: "Quiz Result",
            resultMessage: "Your Score"
        }
    },

    // تغییر زبان
    changeLanguage: function(lang) {
        this.lang = lang;
        this.updateText();
    },

    // بروزرسانی تمام متون صفحه
    updateText: function() {
        document.getElementById("login-title").innerText = this.languagePack[this.lang].loginTitle;
        document.getElementById("login-button").innerText = this.languagePack[this.lang].loginButton;
    },

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
            <h1>${this.languagePack[this.lang].lessonTitle}</h1>
            <p>در اینجا محتوای آموزشی به صورت خودکار تولید خواهد شد.</p>
            <button onclick="Engine.startLesson()">${this.languagePack[this.lang].startLesson}</button>
        `;
    },

    // شروع دوره آموزشی
    startLesson: function() {
        document.getElementById("app").innerHTML = `
            <h1>درس 1: مقدمه‌ای بر برنامه‌نویسی</h1>
            <p>در این درس با مبانی اولیه برنامه‌نویسی آشنا می‌شوید.</p>
            <button onclick="Engine.completeLesson()">${this.languagePack[this.lang].completeLesson}</button>
        `;
    },

    // اتمام درس
    completeLesson: function() {
        document.getElementById("app").innerHTML = `
            <h1>درس تمام شد</h1>
            <p>تبریک! شما درس اول را تمام کردید.</p>
            <button onclick="Engine.open('quiz')">${this.languagePack[this.lang].quizTitle}</button>
        `;
    },

    // شروع آزمون
    startQuiz: function() {
        this.showQuestion(this.questions[this.currentQuestion]);
    },

    // نمایش سوالات
    showQuestion: function(question) {
        document.getElementById("app").innerHTML = `
            <h1>${this.languagePack[this.lang].quizTitle}</h1>
            <p>${question.question}</p>
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
            <h1>${this.languagePack[this.lang].resultTitle}</h1>
            <p>${this.languagePack[this.lang].resultMessage}: <strong id="score">${this.score}</strong></p>
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
