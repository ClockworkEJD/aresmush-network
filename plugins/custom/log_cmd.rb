module AresMUSH
    module Custom
      class LogCmd
       include CommandHandler
 
       attr_accessor :name
 
        def handle
           client.emit_failure "You need to specify whether to clear or delete the log."
        end
      end
    end
end