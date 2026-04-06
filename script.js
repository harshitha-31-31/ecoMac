// 🎤 VOICE FUNCTION
function startVoice() {

    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;

    if (!SpeechRecognition) {
        alert("Use Chrome browser");
        return;
    }

    const recognition = new SpeechRecognition();

    recognition.lang = "en-US";
    recognition.start();

    recognition.onresult = function(event) {
        let voiceText = event.results[0][0].transcript;

        // Put text into input box
        document.getElementById("userInput").value = voiceText;
    };

    recognition.onerror = function(event) {
        console.log("Error:", event.error);
    };
}