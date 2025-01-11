const predefinedQuestions = [
    "What is your name?",
    "What skills do you have?",
    "What type of work are you looking for?"
];

// Predefined answers mapped to questions
const predefinedAnswers = {
    "What is your name?": "I am SkillMitra's assistant. What's your name?",
    "What skills do you have?": "We can help with tailoring, embroidery, plumbing, and more!",
    "What type of work are you looking for?": "We have many local opportunities. What are you interested in?"
};

let currentQuestionIndex = 0; // Tracks the current question

// Function to initialize the chat
function startChat() {
    const chatHistory = document.getElementById("chat-history");
    chatHistory.innerHTML = "<p><strong>Chatbot:</strong> Welcome! I'm here to assist you. Let's start.</p>";
    askQuestion(currentQuestionIndex);
}

// Function to ask a question
function askQuestion(index) {
    const chatHistory = document.getElementById("chat-history");
    const question = predefinedQuestions[index];

    if (question) {
        chatHistory.innerHTML += `<p><strong>Chatbot:</strong> ${question}</p>`;
        scrollToBottom();
    }
}

// Function to handle user's input
function sendMessage() {
    const userInput = document.getElementById("user-input").value.trim();
    const chatHistory = document.getElementById("chat-history");

    if (userInput) {
        // Display user's message
        chatHistory.innerHTML += `<p><strong>You:</strong> ${userInput}</p>`;
        document.getElementById("user-input").value = ''; // Clear input field

        // Simulate chatbot response based on the predefined answers
        setTimeout(() => {
            const currentQuestion = predefinedQuestions[currentQuestionIndex];
            if (predefinedAnswers[currentQuestion]) {
                chatHistory.innerHTML += `<p><strong>Chatbot:</strong> ${predefinedAnswers[currentQuestion]}</p>`;
            }

            // Move to the next question
            currentQuestionIndex++;
            if (currentQuestionIndex < predefinedQuestions.length) {
                setTimeout(() => askQuestion(currentQuestionIndex), 1500); // Delay before the next question
            } else {
                // End of conversation
                setTimeout(() => {
                    chatHistory.innerHTML += `<p><strong>Chatbot:</strong> Thank you for chatting with us! Have a great day!</p>`;
                }, 1500);
            }
            scrollToBottom();
        }, 1000); // Delay for chatbot response
    }
}

// Function to toggle chat visibility
function toggleChat() {
    const chatContainer = document.getElementById("chat-container");
    if (chatContainer.style.display === "none" || !chatContainer.style.display) {
        chatContainer.style.display = "block";
        startChat();
    } else {
        chatContainer.style.display = "none";
    }
}

// Function to scroll the chat to the bottom
function scrollToBottom() {
    const chatBox = document.getElementById("chat-box");
    chatBox.scrollTop = chatBox.scrollHeight;
}

// Event listener to send message when 'Enter' key is pressed
document.getElementById("user-input").addEventListener("keydown", function (event) {
    if (event.key === 'Enter') {
        sendMessage();
    }
});
