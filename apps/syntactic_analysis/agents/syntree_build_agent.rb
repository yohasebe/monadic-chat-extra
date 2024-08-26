module MonadicAgent
  extend BasicAgent

  def syntree_build_agent(sentence:, model: "gpt-4o-2024-08-06", binary: false)
    return "Error: sentence text is required." if sentence.to_s.empty?

    prompt = <<~TEXT
    You are an agent that draws syntax trees for sentences. You are capable of parse English sentences with a vast ammount of knowledge about theoretical linguistics based on Chomsky's Generative Grammar.

    The user will provide you with a sentence in English, and you should respond with a JSON object containing the following properties:

    You create a syntax trees for sentences in English using the labeled bracket notation. For example, the sentence "The cat sat on the mat" can be represented as "[S [NP [Det The] [N cat]] [VP [V sat] [PP [P on] [NP [Det the] [N mat]]]]".But you do not need to use the bracket symbols in your response. The response must be strictly structured as the specified JSON schema. The schema allows recursive structures, so your response can be a tree-like nested structure of an arbitrary number of depths.

    If the user requests for a more detailed analysis, it does not mean that you need to provide a different tree structure but rather that you reflain from using abbriviated notation for some of the compoments of the tree.

    Remember that the if the resulting tree structure is quite complex, you may need to use abbriviated notation for some of its (sub) compoments. For instance, you can use `[VP [V sat] [PP on the mat] ]` instead of  `[VP [V sat] [PP [P on] [NP [Det the] [N mat] ] ] ]`. Use this technique when it is necessary to simplify the tree structure for readability.

    Avoid nested structures where a node has a single child with the same label. For example, `[S [S ...]]` is not allowed. Each level should introduce a new grammatical element or phrase type. This is not limited to the top level of the structure. The following structure is also invalid: `[VP [V houses] [NP [NP [NP married and single soldiers] ] ] ]` since the NP node has a single child with the same label.

        Punctuation marks such as ".", ",", "?", "!", ":", ";" should not be included as part of the structure.

    TEXT

    if binary
      prompt << <<~TEXTB
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

      Avoid omitting words in the resulting structure. For instance, conjunctions and complementizers should be kept in the structure. For example, the sentence "She stopped and laughed" can be represented as `[S [NP She] [VP [V stopped] [ConjP [Conj and] [VP [V laughed]]]]]` and the sentence "She says that she will come" can be represented as `[S [NP She] [VP [V says] [CP [C that] [S [NP she] [VP [V will] [VP [V come]]]]]]]`.
      TEXTB
    else
      prompt << <<~TEXTNB
        Binary branching is preferred throughout the nested structure but coordinating conjunctions of more than two nodes are allowed. For instance, the sentence "She stopped and laughed" can be represented as follows:

        ```
        [S
          [NP She]
          [VP
            [V stopped]
            [Conj and]
            [V laughed]
          ]
        ]
        ```
      TEXTNB
    end

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
                    left: { type: "object", item: { "$ref": "#/properties/content" } },
                    right: { type: "object", item: { "$ref": "#/properties/content" } }
                  }
                else
                  { children: { type: "array", items: { "$ref": "#/properties/content" } } }
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
