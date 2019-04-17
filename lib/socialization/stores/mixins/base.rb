module Socialization
  module Stores
    module Mixins
      module Base
        def touch_dependents(actor, subject)
          actor.touch if touch_actor?(actor)
          subject.touch if touch_subject?(subject)
        end

        def touch_actor?(actor)
          return false unless actor.respond_to?(:touch)
          touch == :all || touch.to_s =~ /er$/i
        end

        def touch_subject?(subject)
          return false unless subject.respond_to?(:touch)
          touch == :all || touch.to_s =~ /able$/i
        end
        alias touch_victim? touch_subject?
      end
    end
  end
end
