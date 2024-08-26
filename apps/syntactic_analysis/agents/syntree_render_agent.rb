module MonadicAgent
  def syntree_render_agent(text:, format: "svg")
    return "Error: input text is required." if text.to_s.empty?

    shared_volume = if IN_CONTAINER
                      MonadicApp::SHARED_VOL
                    else
                      MonadicApp::LOCAL_SHARED_VOL
                    end

    max_retrials = 10
    tempname = Time.now.to_i.to_s

    write_to_file(filename: tempname, extension: "txt", text: text)

    filepath1 = File.join(shared_volume, tempname + ".txt")

    success1 = false
    max_retrials.times do
      if File.exist?(filepath1)
        success1 = true
        break
      end
      sleep 1
    end

    if success1
      success_msg1 = "Syntree generated successfully"
      command = "bash -c 'rsyntaxtree -f #{format} -o . #{tempname}.txt'"
      res1 = send_command(command: command, container: "syntree", success: success_msg1)

      if /\A#{success_msg1}/ =~ res1.strip
        command = "bash -c 'mv syntree.#{format} #{tempname}.#{format}'"
        success_msg2 = "Syntax tree generated successfully as #{tempname}.#{format}"
        res2 = send_command(command: command, container: "syntree", success: success_msg2)

        if /\A#{success_msg2}/ =~ res2.strip

          filepath2 = File.join(shared_volume, tempname + "." + format)

          success2 = false
          max_retrials.times do
            if File.exist?(filepath2)
              success2 = true
              break
            end
            sleep 1
          end

          if success2
            "Syntax tree generated successfully as #{tempname + "." + format}"
          else
            "Error: syntax tree generation failed. #{res2}"
          end
        end
      else
        "Error: syntax tree generation failed. #{res1}"
      end
    else
      "Error: syntax tree generation failed. Temp file not found."
    end
  end
end
