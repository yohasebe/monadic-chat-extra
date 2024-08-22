class DiscourseAnalysis < MonadicApp
  icon = "<i class='fas fa-scroll'></i>"

  description = <<~TEXT
    This is an application for analyzing and summarizing the user’s discourse. The AI generates a summary of the user’s messages, identifies the main topics, classifies the sentence types, and determines the sentiment of the messages. This app uses the monadic feature of the Monadic Chat framework. It accumulates and summarizes the past discourse contents and passes them over to the following conversation turns.
  TEXT

  initial_prompt = <<~TEXT
    Create a response to the user's message, which is embedded in a JSON object of the structure below. Set your response to the "message" property of the object and update the contents of the "context" as instructed in the "INSTRUCTIONS" below.

    INSTRUCTIONS:
    - Your response in the "message" property is a summary of the user's messages up to the current one, which contains the main points of the conversation. The whole response should be a single paragraph. Make it contain as much information as possible from the user's past and present messages.
    - The "context" property of the response object is an object that contains the following properties:
      - The "topics" property of "context" is a list that accumulates the topics of the user's messages.
      - The "sentence type" property of "context" is a text label that indicates the sentence type of the user's message, such as "persuasive", "questioning", "factual", "descriptive", etc.
      - The "sentiment" property of "context" is one or more emoji labels that indicate the sentiment of the user's message.
  TEXT

  @settings = {
    "app_name": "Discourse Analysis",
    "model": "gpt-4o-2024-08-06",
    "temperature": 0.0,
    "top_p": 0.0,
    "context_size": 20,
    "initial_prompt": initial_prompt,
    "description": description,
    "icon": icon,
    "easy_submit": false,
    "auto_speech": false,
    "initiate_from_assistant": false,
    "image": true,
    "monadic": true,
    "response_format": {
      type: "json_schema",
      json_schema: {
        name: "discourse_analysis_response",
        schema: {
          type: "object",
          properties: {
            message: {
              type: "string",
              description: "The response message from the Math Tutor."
            },
            context: {
              type: "object",
              properties: {
                topics: {
                  type: "array",
                  items: {
                    type: "string",
                    description: "The topic of the user's message."
                  }
                },
                sentence_type: {
                  type: "string",
                  description: "The sentence type of the user's message."
                },
                sentiment: {
                  type: "array",
                  items: {
                    type: "string",
                    description: "The sentiment of the user's message."
                  }
                }
              },
              required: ["topics", "sentence_type", "sentiment"],
              additionalProperties: false
            }
          },
          required: ["message", "context"],
          additionalProperties: false
        },
        strict: true
      }
    }
  }
end
