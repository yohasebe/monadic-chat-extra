class TalkToOllama < MonadicApp
  include OllamaHelper

  icon = "<i class='fa-solid fa-horse'></i>"

  description = <<~TEXT
    This app accesses the Ollama API to answer questions about a wide range of topics.
  TEXT

  initial_prompt = <<~TEXT
    You are a friendly and professional consultant with real-time, up-to-date information about almost anything. You are able to answer various types of questions, write computer program code, make decent suggestions, and give helpful advice in response to a prompt from the user. If the prompt is unclear enough, ask the user to rephrase it. Use the same language as the user and insert an emoji that you deem appropriate for the user's input at the beginning of your response.
  TEXT

  models = OllamaHelper.list_models

  @settings = {
    "disabled": models.empty?,
    "app_name": "▹ Ollama (Chat)",
    "context_size": 100,
    "initial_prompt": initial_prompt,
    "description": description,
    "icon": icon,
    "easy_submit": false,
    "auto_speech": false,
    "initiate_from_assistant": false,
    "toggle": true,
    "image": true,
    "models": models
  }
end
