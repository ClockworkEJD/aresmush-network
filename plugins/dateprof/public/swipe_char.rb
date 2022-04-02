module AresMUSH
  class Character
    list :dating_queue, 'AresMUSH::Character'
    collection :swipes, 'AresMUSH::DateProf::Swipe'

    def missed_connections
      AresMUSH::DateProf::Swipe.find(target_id: self.id, missed: true).select do |swipe|
        self.match_for(swipe.character) == :missed
      end.map do |swipe|
        swipe.character
      end
    end

    def next_dating_profile
      self.refresh_dating_queue! if self.dating_queue.empty?
      return self.dating_queue.first
    end

    def refresh_dating_queue!
      queue = Character.all.reject(&:is_admin?).select(&:is_approved?).reject do |model|
        model.id == self.id
      end.select do |model|
        swipe_for(model).nil?
      end.shuffle
      self.dating_queue.replace(queue)
    end

    def swipe(target, type)
      swipe = swipe_for(target)
      if swipe.nil?
        swipe = AresMUSH::DateProf::Swipe.create(
          character_id: self.id,
          target_id: target.id,
          type: type,
        )
        self.dating_queue.delete(target)
      else
        swipe.update(type: type)
      end 
    end

    def swipe_for(target)
      AresMUSH::DateProf::Swipe.find(character_id: self.id, target_id: target.id).first
    end

    def swipes_of_type(type)
      if type == :missed
        self.swipes.find(missed: true)
      else
        self.swipes.find(type: type)
      end
    end

    def match_for(target)
      me = self.swipe_for(target)
      them = target.swipe_for(self)

      if (me.nil? || me.type == :skip) && them && them.missed
        return :missed
      elsif me.nil? or them.nil?
        return nil
      end
      case [me.type, them.type]
      when [:interested, :interested] then :solid
      when [:interested, :curious], [:curious, :interested] then :okay
      when [:curious, :curious] then :maybe
      else nil
      end
    end
  end
end
