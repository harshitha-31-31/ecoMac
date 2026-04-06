// 🎤 VOICE FUNCTION - Cross Browser Support
function startVoice() {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;

    if (!SpeechRecognition) {
        // Fallback for Firefox/Safari - show message to type instead
        showBrowserFallback();
        return;
    }

    const recognition = new SpeechRecognition();

    recognition.lang = "en-US";
    recognition.continuous = false;
    recognition.interimResults = false;

    // Show listening indicator
    showListeningIndicator();

    recognition.start();

    recognition.onresult = function(event) {
        let voiceText = event.results[0][0].transcript;
        document.getElementById("userInput").value = voiceText;
        hideListeningIndicator();
        sendMessage();
    };

    recognition.onerror = function(event) {
        console.log("Speech recognition error:", event.error);
        hideListeningIndicator();

        let errorMsg = "Speech error. Please try again or type your message.";
        if (event.error === 'not-allowed') {
            errorMsg = "Microphone access denied. Please allow microphone access or type your message.";
        } else if (event.error === 'no-speech') {
            errorMsg = "No speech detected. Please try again or type your message.";
        }

        showToast(errorMsg);
    };

    recognition.onend = function() {
        hideListeningIndicator();
    };
}

// Show listening indicator
function showListeningIndicator() {
    removeExistingIndicator();

    const indicator = document.createElement('div');
    indicator.id = 'voice-indicator';
    indicator.innerHTML = '🎤 Listening...';
    indicator.style.cssText = `
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: green;
        color: white;
        padding: 20px 40px;
        border-radius: 10px;
        font-size: 18px;
        z-index: 1000;
        animation: pulse 1s infinite;
    `;

    // Add pulse animation
    const style = document.createElement('style');
    style.id = 'voice-animation-style';
    style.textContent = `
        @keyframes pulse {
            0% { transform: translate(-50%, -50%) scale(1); }
            50% { transform: translate(-50%, -50%) scale(1.1); }
            100% { transform: translate(-50%, -50%) scale(1); }
        }
    `;
    document.head.appendChild(style);
    document.body.appendChild(indicator);
}

// Hide listening indicator
function hideListeningIndicator() {
    removeExistingIndicator();
}

// Remove existing indicator elements
function removeExistingIndicator() {
    const existing = document.getElementById('voice-indicator');
    const existingStyle = document.getElementById('voice-animation-style');
    if (existing) existing.remove();
    if (existingStyle) existingStyle.remove();
}

// Show browser fallback message
function showBrowserFallback() {
    const userInput = document.getElementById("userInput");
    userInput.placeholder = "Type your message here (voice not supported in this browser)";
    userInput.focus();

    showToast("Voice input not supported. Please type your message.");
}

// Show toast notification
function showToast(message) {
    removeExistingIndicator();

    const toast = document.createElement('div');
    toast.id = 'voice-toast';
    toast.textContent = message;
    toast.style.cssText = `
        position: fixed;
        top: 20%;
        left: 50%;
        transform: translateX(-50%);
        background: #333;
        color: white;
        padding: 15px 25px;
        border-radius: 8px;
        font-size: 14px;
        z-index: 1000;
        max-width: 80%;
        text-align: center;
    `;

    document.body.appendChild(toast);

    setTimeout(() => {
        toast.remove();
    }, 3000);
}
