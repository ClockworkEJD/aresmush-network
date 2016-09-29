module AresMUSH

  module Roster
    class RosterClaimCmd
      include CommandHandler
      include CommandRequiresLogin
      include CommandRequiresArgs
      
      attr_accessor :name
      
      def initialize(client, cmd, enactor)
        self.required_args = ['name']
        self.help_topic = 'roster'
        super
      end
      
      def crack!
        self.name = titleize_input(cmd.args)
      end
      
      def handle
        terms_of_service = Login::Api.terms_of_service
        if (terms_of_service && client.program[:tos_accepted].nil?)
          client.program[:create_cmd] = cmd
          client.emit "%l1%r#{terms_of_service}%r#{t('login.tos_agree')}%r%l1"
          return
        end
        
        client.program.delete(:create_cmd)
        
        ClassTargetFinder.with_a_character(self.name, client) do |model|
          if (!model.roster_registry)
            client.emit_failure t('roster.not_on_roster', :name => model.name)
            return
          end

          password = Character.random_link_code
          Login::Api.change_password(model, password)
          model.roster_registry.destroy
          
          model.save
          client.emit_success t('roster.roster_claimed', :name => model.name, :password => password)
          
          bbs = Global.read_config("roster", "arrivals_board")
          return if !bbs
          return if bbs.blank?
        
          Bbs::Api.post(bbs, 
            t('roster.roster_bbs_subject'), 
            t('roster.roster_bbs_body', :name => model.name), 
            Game.master.system_character)
        end
      end
    end
  end
end
