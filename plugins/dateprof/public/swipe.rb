module AresMUSH
  module DateProf
    class Swipe < Ohm::Model
      include ObjectModel

      reference :character, 'AresMUSH::Character'
      reference :target, 'AresMUSH::Character'
      attribute :type, :type => DataType::Symbol
      attribute :missed, :type => DataType::Boolean, :default => false

      index :type
      index :missed

      def self.check_type(type)
        return nil if [:interested, :curious, :skip, :missed_connection].include? type
        return t('dateprof.invalid_swipe_type')
      end
    end
  end
end
