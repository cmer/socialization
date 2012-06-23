module Socialization
  module Stores
    module Mixins
      module Base
        def touch_dependents(actor, victim)
          actor.touch if touch_actor?(actor)
          victim.touch if touch_victim?(victim)
        end

        def touch_actor?(actor)
          return false unless actor.respond_to?(:touch)
          touch == :all || touch.to_s =~ /er$/i
        end

        def touch_victim?(victim)
          return false unless victim.respond_to?(:touch)
          touch == :all || touch.to_s =~ /able$/i
        end
      end
    end
  end
end
