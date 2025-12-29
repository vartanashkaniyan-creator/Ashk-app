function generateLesson() {
    let lessonTitle = "درس جدید";
    let lessonContent = "محتوای این درس به صورت خودکار تولید شد.";
    document.getElementById("app").innerHTML = `<h2>${lessonTitle}</h2><p>${lessonContent}</p>`;
}

function generateQuiz() {
    let question = "2 + 2 = ?";
    let options = [2, 3, 4, 5];
    let html = `<h2>${question}</h2>`;
    options.forEach(option => {
        html += `<button onclick="checkAnswer(${option}, 4)">${option}</button>`;
    });
    document.getElementById("app").innerHTML = html;
}

function checkAnswer(selected, correct) {
    let score = 0;
    if (selected === correct) {
        score += 10;
        alert("پاسخ صحیح است!");
    } else {
        alert("پاسخ اشتباه است.");
    }
    document.getElementById("app").innerHTML += `<p>امتیاز شما: ${score}</p>`;
}

function showApp(type) {
    if (type === 'lesson') generateLesson();
    if (type === 'quiz') generateQuiz();
    if (type === 'result') showResult();
}

function showResult() {
    document.getElementById("app").innerHTML = "<h2>نتیجه آزمون</h2><p>امتیاز شما: 10</p>";
}
