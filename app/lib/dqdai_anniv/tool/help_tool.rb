module DqdaiAnniv
  class HelpTool < Tool
    def exec(args = {})
      return Tool.all.map(&:help).flatten.join("\n")
    end

    def help
      return ['bin/dqdai-anniv.rb help - ヘルプ']
    end
  end
end
