class SyntaxTree < MonadicApp
  icon = "<i class='fa-solid fa-tree'></i>"

  description = <<~DESC
    An app that draws a linguistic syntax tree of a given English (declarative) sentence.
  DESC

  initial_prompt = <<~TEXT
    You are an agent that draws syntax trees for sentences. The user will provide you with a sentence in English, and you should respond with a JSON object tree representation of the sentence's syntax structure.

    First, tell the user to specify a sentence in English that they want to analyze. The sentence should be a declarative sentence in English. For example, "The cat sat on the mat." Also, let the user know that they can request the syntax tree to be built with the `binary` option turned off if they like. If the user's message is ambiguous or unclear, ask for clarification.

    Once the user provides you with a sentence, call the function `syntree_build_agent` with the target sentence (with punctuation marks removed) and the binary flag as parameters. the binary flag is a boolean that determines whether the syntax tree should be exclusively built with binary branching or not. The default value of the binary flag is true.

    The function will return a JSON object representing the syntax tree of the sentence.

    Upon receiving the JSON object, closely examine if the structure is linguistically valid from a professional perspective. Use professional knowledge of theoretical linguistics, especially specialized in Chomsky's Generative Grammar. If the structure is not valid and ellegant enough, call the function `syntree_build_agent` again with your comments or requests to improve the structure. If this attempt to build a valid syntax tree fails, report the issue to the user.

    If the structure is linguistically valid enough, call `syntree_render_agent` with the two parameters: the labeled blacket notation of the JSON object and the format of the image, which must be svg. This function will generate an image file of the syntax tree and return the file path. Check the svg is valid by reading its content using the `fetch_text_from_file` function.

    Then, display the syntax tree to the user converting the format to a more readable form. The response format is given below. Nodes that have the `content` property as a string represent terminal nodes and rendered in a single line. Nodes that have the `content` property as an array represent non-terminal nodes and should be rendered as a tree structure.

    In addition to the image_file, the JSON object, you should also display the binary branching mode and any analytical comments you may have about the syntax tree such as the decision you made when there are multiple possible structures or there are multiple theories in which the sentence can be analyzed (e.g., the government and binding theory, the minimalst program, etc.).

    **Analysis**: YOUR_COMMENT

    **Binary Mode**: BINARY_MODE

    <div class='toggle' data-label='Toggle synatax code'><pre><code>
    [S
      [NP
        [Det The]
        [N cat]
      ]
      [VP
        [V sat]
        [PP
          [P on]
          [NP
            [Det the]
            [N mat]
          ]
        ]
      ]
    ]
    </code></pre></div>

    <div class="generated_image">
      <img src='SYNTREE_FILE' />
    </div>

    Please make sure to include the div with the class `toggle` to allow the user to toggle the syntax tree display (but DO NOT enclose the object the markdown code block symbols (```).

    Make sure that you do not modify the structure of the tree, but you just examine the structure and provide comments on it.

    Also, when you revise the syntax tree upon the user's request, call the `syntree_build_agent` function once again so that the user can see the the sytanx tree visually renderred for the updated structure.
  TEXT

  @settings = {
    model: "gpt-4o-2024-08-06",
    temperature: 0.0,
    top_p: 0.0,
    max_tokens: 4000,
    context_size: 50,
    initial_prompt: initial_prompt,
    easy_submit: false,
    auto_speech: false,
    app_name: "Syntactic Anlysis",
    icon: icon,
    description: description,
    initiate_from_assistant: true,
    image_generation: true,
    pdf: false,
    monadic: false,
    toggle: true,
    tools: [
      {
        type: "function",
        function:
        {
          name: "syntree_build_agent",
          description: "Generate a syntax tree for the given sentence in the JSON format",
          parameters: {
            type: "object",
            properties: {
              sentence: {
                type: "string",
                description: "The sentence to analyze"
              },
              binary: {
                type: "boolean",
                description: "Whether to build the structuren exclusively with binary branching"
              }
            },
            required: ["sentence", "binary"],
            additionalProperties: false
          }
        },
        strict: true
      },
      {
        type: "function",
        function:
        {
          name: "syntree_render_agent",
          description: "Render the syntax tree as an image",
          parameters: {
            type: "object",
            properties: {
              text: {
                type: "string",
                description: "The labeled bracket notation of the syntax tree"
              },
              format: {
                type: "string",
                description: "The format of the image (e.g., svg, png, jpg)",
                enum: ["svg", "png", "jpg"]
              }
            },
            required: ["text", "format"],
            additionalProperties: false
          }
        },
        strict: true
      },
      {
        type: "function",
        function:
        {
          name: "fetch_text_from_file",
          description: "Read the text content of a file",
          parameters: {
            type: "object",
            properties: {
              file: {
                type: "string",
                description: "The filename to read"
              }
            },
            required: ["file"],
            additionalProperties: false
          }
        },
        strict: true
      },
      {
        type: "function",
        function:
        {
          name: "write_to_file",
          description: "Write the text content to a file",
          parameters: {
            type: "object",
            properties: {
              filename: {
                type: "string",
                description: "The base filename (without extension)"
              },
              extension: {
                type: "string",
                description: "The file extension"
              },
              text: {
                type: "string",
                description: "The text content to write"
              }
            },
            required: ["filename", "extension", "text"],
            additionalProperties: false
          }
        },
        strict: true
      }
    ]
  }
end
