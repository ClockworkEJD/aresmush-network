$:.unshift File.dirname(__FILE__)

module AresMUSH
    module DateProf

        def self.plugin_dir
            File.dirname(__FILE__)
        end

        def self.shortcuts
            Global.read_config("dateprof", "shortcuts")
        end

        def self.get_cmd_handler(client, cmd, enactor)
            case cmd.root
            when "dateprof"
                case cmd.switch
                when "set"
                    return SetDateProfCmd
                when "clear"
                    return ClearDateProfCmd
                else 
                    return DateProfCmd
                end
            end
        end

        nil
    end
end