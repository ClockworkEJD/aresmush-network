module AresMUSH

  module FS3Skills
    class CharBackupCmd
      include CommandHandler
      include CommandRequiresLogin
      include CommandWithoutSwitches
      
      attr_accessor :target
      
      def crack!
        self.target = !cmd.args ? client.name : trim_input(cmd.args)
      end
      
      def check_permission
        return nil if self.target == client.name
        return nil if enactor.has_any_role?(Global.read_config("fs3skills", "roles", "can_view_sheets"))
        return t('fs3skills.no_permission_to_backup')
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.target, client) do |model|
          Global.dispatcher.queue_command(client, Command.new("sheet #{model.name}"))
          Global.dispatcher.queue_command(client, Command.new("bg #{model.name}"))
          Global.dispatcher.queue_command(client, Command.new("info #{model.name}"))
          
          template = Describe::Api.desc_template(model, enactor)
          client.emit template.render
        end
      end
    end
  end
end
