$:.unshift File.dirname(__FILE__)

module AresMUSH
  module Custom
    def self.plugin_dir
      File.dirname(__FILE__)
    end
 
    def self.shortcuts
      Global.read_config("custom", "shortcuts")
    end
 
    def self.get_cmd_handler(client, cmd, enactor)   
      case cmd.root
      when "dotcount"
        return DotCountCmd
      when "plotcheck"
        return PlotcheckCmd
      when "wordcount"
        case cmd.switch
        when "alts"
          return WordCountAltsCmd
        when nil
          return WordCountCmd
        end
      when "log"
        case cmd.switch
        when "clear"
          return LogClearCmd
        when "delete"
          return LogDeleteCmd
        when nil
          return LogClearCmd
        end
      end   
      return nil
    end
  end
end
