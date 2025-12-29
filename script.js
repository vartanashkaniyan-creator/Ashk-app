// Function to show quiz questions
function showQuiz() {
    const questions = [
        { question: "2 + 2 = ?", options: [2, 3, 4, 5], answer: 4 },
        { question: "3 + 5 = ?", options: [7, 8, 9, 10], answer: 8 }
    ];
    
    let currentQuestion = questions[0];  // This can be dynamic
    document.getElementById("app").innerHTML = `
        <h2>${currentQuestion.question}</h2>
        ${currentQuestion.options.map(o => `<button onclick="checkAnswer(${o}, ${currentQuestion.answer})">${o}</button>`).join("")}
    `;
}

function checkAnswer(selected, correct) {
    let score = 0;
    if (selected === correct) {
        score += 10;
        alert("پاسخ صحیح است!");
    } else {
        alert("پاسخ اشتباه است.");
    }
    document.getElementById("score").innerText = score;
}
