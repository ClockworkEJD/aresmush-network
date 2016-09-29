module AresMUSH
  module OOCTime
    module Api
      
      def self.local_short_timestr(viewer, datetime)
        OOCTime.local_short_timestr(viewer, datetime)
      end

      def self.local_long_timestr(viewer, datetime)
        OOCTime.local_long_timestr(viewer, datetime)
      end
    
      def self.timezone(char)
        char.timezone
      end
    end
  end
end