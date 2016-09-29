module AresMUSH
  module Utils
    class EditPasswordCmd
      include CommandHandler
      include CommandRequiresLogin
      
      attr_accessor :prefix
      
      def crack!
        self.prefix = trim_input(cmd.args)
      end

      def handle
        if (!self.prefix)
          enactor.edit_prefix = nil
          message = t('edit.prefix_cleared')
        else
          enactor.edit_prefix = self.prefix
          message = t('edit.prefix_set')
        end
        
        enactor.save!
        client.emit_success message
      end
    end
  end
end
