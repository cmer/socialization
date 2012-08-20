module Socialization
  module Stores
    module Mixins
      module Follow

      public
        def touch(what = nil)
          if what.nil?
            @touch || false
          else
            raise Socialization::ArgumentError unless [:all, :follower, :followable, false, nil].include?(what)
            @touch = what
          end
        end

        def after_follow(method)
          raise Socialization::ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_create_hook = method
        end

        def after_unfollow(method)
          raise Socialization::ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_destroy_hook = method
        end

      protected
        def call_after_create_hooks(follower, followable)
          self.send(@after_create_hook, follower, followable) if @after_create_hook
          touch_dependents(follower, followable)
        end

        def call_after_destroy_hooks(follower, followable)
          self.send(@after_destroy_hook, follower, followable) if @after_destroy_hook
          touch_dependents(follower, followable)
        end
      end
    end
  end
end