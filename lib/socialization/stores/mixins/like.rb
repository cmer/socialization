module Socialization
  module Stores
    module Mixins
      module Like

      public
        def touch(what = nil)
          if what.nil?
            @touch || false
          else
            raise Socialization::ArgumentError unless [:all, :liker, :likeable, false, nil].include?(what)
            @touch = what
          end
        end

        def after_like(method)
          raise Socialization::ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_create_hook = method
        end

        def after_unlike(method)
          raise Socialization::ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_destroy_hook = method
        end

      protected
        def call_after_create_hooks(liker, likeable)
          self.send(@after_create_hook, liker, likeable) if @after_create_hook
          touch_dependents(liker, likeable)
        end

        def call_after_destroy_hooks(liker, likeable)
          self.send(@after_destroy_hook, liker, likeable) if @after_destroy_hook
          touch_dependents(liker, likeable)
        end

      end
    end
  end
end