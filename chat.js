// Updated Chatbot Code with Options for User Selection

const predefinedFlows = {
    signup: [
        "What is your name?",
        "What skills do you have?",
        "What type of work are you looking for?",
        "Do you need help logging in or signing up?"
    ],
    hiring: [
        "What type of worker are you looking for?",
        "Do you have specific requirements (e.g., skills, experience)?",
        "What is the location of the job?",
        "Do you need assistance verifying worker details?"
    ]
};

const predefinedAnswers = {
    "What is your name?": "I am SkillMitra's assistant.",
    "What skills do you have?": "We can help with tailoring, embroidery, plumbing, and more!",
    "What type of work are you looking for?": "We have many local opportunities. What are you interested in?",
    "Do you need help logging in or signing up?": "If you are a worker, go to the 'Sign Up as a Worker' section and create an account using your details. If you are a hirer, select the 'Hire Verified' option and fill out your company or personal details to register.",
    "What type of worker are you looking for?": "We can provide skilled workers in tailoring, plumbing, and more.",
    "Do you have specific requirements (e.g., skills, experience)?": "Yes, we can match workers based on your requirements.",
    "What is the location of the job?": "Please provide the location so we can find nearby workers.",
    "Do you need assistance verifying worker details?": "We offer worker verification services for your safety and peace of mind."
};

let currentFlow = [];
let currentQuestionIndex = 0;

// Function to initialize the chat
function startChat() {
    const chatHistory = document.getElementById("chat-history");
    chatHistory.innerHTML = "<p><strong>Chatbot:</strong> Hi, I am your chatbot. How can I assist you today?</p>";
    showOptions(["Assist for Sign Up", "Assist in Hiring"]);
}

// Function to show options to the user
function showOptions(options) {
    const chatSuggestions = document.getElementById("chat-suggestions");
    chatSuggestions.innerHTML = "";

    options.forEach(option => {
        const button = document.createElement("button");
        button.textContent = option;
        button.onclick = () => handleOptionSelection(option);
        chatSuggestions.appendChild(button);
    });
}

// Function to handle user selection of an option
function handleOptionSelection(option) {
    const chatHistory = document.getElementById("chat-history");
    chatHistory.innerHTML += `<p><strong>You:</strong> ${option}</p>`;

    if (option === "Assist for Sign Up") {
        currentFlow = predefinedFlows.signup;
    } else if (option === "Assist in Hiring") {
        currentFlow = predefinedFlows.hiring;
    }

    currentQuestionIndex = 0;
    document.getElementById("chat-suggestions").innerHTML = "";
    askQuestion(currentQuestionIndex);
}

// Function to ask a question
function askQuestion(index) {
    const chatHistory = document.getElementById("chat-history");
    const question = currentFlow[index];

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
            const currentQuestion = currentFlow[currentQuestionIndex];
            if (predefinedAnswers[currentQuestion]) {
                chatHistory.innerHTML += `<p><strong>Chatbot:</strong> ${predefinedAnswers[currentQuestion]}</p>`;
            }

            // Move to the next question
            currentQuestionIndex++;
            if (currentQuestionIndex < currentFlow.length) {
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
