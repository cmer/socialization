module Socialization
  module Stores
    module Mixins
      module Mention

      public
        def touch(what = nil)
          if what.nil?
            @touch || false
          else
            raise Socialization::ArgumentError unless [:all, :mentioner, :mentionable, false, nil].include?(what)
            @touch = what
          end
        end

        def after_mention(method)
          raise Socialization::ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_create_hook = method
        end

        def after_unmention(method)
          raise Socialization::ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_destroy_hook = method
        end

      protected
        def call_after_create_hooks(mentioner, mentionable)
          self.send(@after_create_hook, mentioner, mentionable) if @after_create_hook
          touch_dependents(mentioner, mentionable)
        end

        def call_after_destroy_hooks(mentioner, mentionable)
          self.send(@after_destroy_hook, mentioner, mentionable) if @after_destroy_hook
          touch_dependents(mentioner, mentionable)
        end

      end
    end
  end
end