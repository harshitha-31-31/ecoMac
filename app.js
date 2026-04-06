require('dotenv').config();
const fetch = require('node-fetch');

async function getAIResponse(message) {
  try {
    const response = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${process.env.API_KEY}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model: "gpt-4.1-mini",
        input: message
      })
    });

    const data = await response.json();
    console.log("API Response:", data);
  } catch (error) {
    console.log("Error:", error);
  }
}

getAIResponse("How to recycle plastic?");