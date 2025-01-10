// Toggle the Chatbot
function toggleChat() {
    const chatContainer = document.getElementById("chat-container");
    if (chatContainer.style.display === "none" || !chatContainer.style.display) {
        chatContainer.style.display = "block";
    } else {
        chatContainer.style.display = "none";
    }
}

// Send Message Functionality (Basic Example)
function sendMessage() {
    const userInput = document.getElementById("user-input");
    const chatHistory = document.getElementById("chat-history");

    if (userInput.value.trim() !== "") {
        const userMessage = document.createElement("div");
        userMessage.className = "user-message";
        userMessage.textContent = userInput.value;

        chatHistory.appendChild(userMessage);

        // Simulate Bot Response
        const botMessage = document.createElement("div");
        botMessage.className = "bot-message";
        botMessage.textContent = "I'm here to help!";

        chatHistory.appendChild(botMessage);

        // Scroll to the bottom of chat
        chatHistory.scrollTop = chatHistory.scrollHeight;

        // Clear user input
        userInput.value = "";
    }
}
// Toggle Chat Visibility
function toggleChat() {
    const chatContainer = document.getElementById("chat-container");
    chatContainer.style.display = chatContainer.style.display === "none" || chatContainer.style.display === "" ? "block" : "none";
}

