module AresMUSH
  module Describe
    class ScenesCmd
      include CommandHandler
      include CommandRequiresLogin
      
      attr_accessor :set
      
      def handle
        template = SceneListTemplate.new(Describe.rooms_with_scenes)
        client.emit template.render
      end
    end
  end
end