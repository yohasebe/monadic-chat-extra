module MonadicAgent
  extend BasicAgent

  def syntree_build_agent(sentence:, model: "gpt-4o-2024-08-06", binary: false)
    return "Error: sentence text is required." if sentence.to_s.empty?

    if binary
      process_mode = <<~TEXT
        The branching must be strictly binary throughout the nested structure. For instance, the sentence "She stopped and laughed" can be represented as follows:

    ```
    [S
      [NP She]
      [VP
        [V stopped]
        [ConjP
          [Conj and]
          [VP
            [V laughed]
          ]
        ]
      ]
    ]
    ```
      TEXT
    end

    note_process_mode = binary ? process_mode : ""

    prompt = <<~TEXT
    You are an agent that draws syntax trees for sentences. The user will provide you with a sentence in English, and you should respond with a JSON object containing the following properties:

    You create a syntax trees for sentences in English using the labeled bracket notation. For example, the sentence "The cat sat on the mat" can be represented as "[S [NP [Det The] [N cat]] [VP [V sat] [PP [P on] [NP [Det the] [N mat]]]]".But you do not need to use the bracket symbols in your response. The response must be strictly structured as the specified JSON schema. The schema allows recursive structures, so your response can be a tree-like nested structure of an arbitrary number of depths.

    Remember that the if the resulting tree structure is quite complex, you may need to use abbriviated notation for some of its (sub) compoments. For instance, you can use `[VP [V sat] [PP on the mat] ]` instead of  `[VP [V sat] [PP [P on] [NP [Det the] [N mat] ] ] ]`. Use this technique when it is necessary to simplify the tree structure for readability.
    #{note_process_mode}
    TEXT

    messages = [
      {
        "role" => "system",
        "content" => prompt
      },
      {
        "role" => "user",
        "content" => <<~TEXT
          ### Sentence to analyze

          #{sentence}
        TEXT
      }
    ]

    recursion = if binary
                  {
                    left: { type: "object", item: { "$ref": "#" } },
                    right: { type: "object", item: { "$ref": "#" } }
                  }
                else
                  { children: { type: "array", items: { "$ref": "#" } } }
                end

    response_format = {
      type: "json_schema",
      json_schema: {
        name: "syntax_tree_response",
        description: "A JSON object representing a syntax tree of a given English sentence.",
        schema: {
          type: "object",
          properties: {
            label: {
              type: "string",
              description: "The label of the syntactic node, for example S, NP, VP, etc."
            },
            content: {
              type: "object",
              description: "The syntactic node.",
              anyOf: [
                {
                  "type": "string",
                  "description": "The content of the syntactic node, for example a word or a phrase."
                },
                recursion
              ]
            }
          },
          required: ["label", "content"],
          additionalProperties: false
        },
        strict: true
      }
    }

    BasicAgent.send_query({ messages: messages,
                            response_format: response_format,
                            model: model })
  end
end
