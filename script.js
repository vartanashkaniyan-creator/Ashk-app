// تغییر صفحه به سوالات
function generateQuiz() {
    const questions = [
        { question: "2 + 2 = ?", options: [2, 3, 4, 5], answer: 4 },
        { question: "5 + 3 = ?", options: [7, 8, 9, 10], answer: 8 },
        { question: "10 - 3 = ?", options: [6, 7, 8, 9], answer: 7 }
    ];

    // انتخاب سوال تصادفی
    const randomIndex = Math.floor(Math.random() * questions.length);
    const currentQuestion = questions[randomIndex];

    let html = `
        <h2>${currentQuestion.question}</h2>
        ${currentQuestion.options.map(o => 
            `<button onclick="checkAnswer(${o}, ${currentQuestion.answer})">${o}</button>`
        ).join("")}
    `;
    document.getElementById("app").innerHTML = html;
}

// بررسی جواب کاربر
function checkAnswer(selected, correct) {
    let score = 0;
    if (selected === correct) {
        score += 10;
        alert("پاسخ صحیح است!");
    } else {
        alert("پاسخ اشتباه است.");
    }

    // نمایش امتیاز
    document.getElementById("app").innerHTML = `
        <h2>نتیجه آزمون</h2>
        <p>امتیاز شما: <strong id="score">${score}</strong></p>
        <button onclick="generateQuiz()">پرسش بعدی</button>
    `;
}

// بارگذاری صفحه اولیه
function showHome() {
    document.getElementById("app").innerHTML = `
        <h1>به اپ خوش آمدید</h1>
        <button onclick="generateQuiz()">شروع آزمون</button>
    `;
}

window.onload = showHome;
