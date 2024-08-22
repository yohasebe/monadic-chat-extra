class IdeaProcessor < MonadicApp
  icon = "<i class='fas fa-scroll'></i>"

  description = <<~TEXT
    An application for discussing ideas in a brainstorming format, where AI agents comment on user messages, suggest new ideas, and generate summaries of previous discussions.
  TEXT

  initial_prompt = <<~TEXT
    You are an agent that discusses ideas with users in a brainstorming format; the AI agent comments on user messages and suggests new ideas, while generating a summary of previous discussions, topics under discussion, and discussion completion levels (from 0 to 10) The conversational response to the user is a "conversation response. The conversational response to the user is embedded in the JSON object as the value of the "message" property, while other items ("summary", "topics", and "completion") are embedded in the "context" property.
  TEXT

  @settings = {
    "app_name": "Idea Processor",
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
        name: "idea_processor_response",
        schema: {
          type: "object",
          properties: {
            message: {
              type: "string"
            },
            context: {
              type: "object",
              properties: {
                summary: {
                  type: "string",
                  description: "The summary of the discussion."
                },
                topics: {
                  type: "array",
                  items: {
                    type: "string",
                    description: "The topics under discussion."
                  }
                },
                completion: {
                  type: "string",
                  description: "The completion level of the discussion (from 0 to 10)."
                }
              },
              "required": ["summary", "topics", "completion"],
              "additionalProperties": false
            }
          },
          "required": ["message", "context"],
          "additionalProperties": false
        },
        "strict": true
      }
    }
  }
end
