module Socialization
  module ActiveRecordStores
    class Follow < ActiveRecord::Base
      include Socialization::ActiveRecordStores::Mixins::Base
      include Socialization::Stores::Mixins::Follow

      belongs_to :follower,   :polymorphic => true
      belongs_to :followable, :polymorphic => true

      scope :followed_by, lambda { |follower| where(
        :follower_type   => follower.class.table_name.classify,
        :follower_id     => follower.id)
      }

      scope :following,   lambda { |followable| where(
        :followable_type => followable.class.table_name.classify,
        :followable_id   => followable.id)
      }

      class << self
        def follow!(follower, followable)
          unless follows?(follower, followable)
            self.create! do |follow|
              follow.follower = follower
              follow.followable = followable
            end
            call_after_create_hook(follower, followable)
            follower.touch if [:all, :follower].include?(touch) && follower.respond_to?(:touch)
            followable.touch if [:all, :followable].include?(touch) && followable.respond_to?(:touch)
            true
          else
            false
          end
        end

        def unfollow!(follower, followable)
          if follows?(follower, followable)
            follow_for(follower, followable).destroy_all
            call_after_destroy_hook(follower, followable)
            follower.touch if [:all, :follower].include?(touch) && follower.respond_to?(:touch)
            followable.touch if [:all, :followable].include?(touch) && followable.respond_to?(:touch)
            true
          else
            false
          end
        end

        def follows?(follower, followable)
          !follow_for(follower, followable).empty?
        end

        # Returns an ActiveRecord::Relation of all the followers of a certain type that are following followable
        def followers_relation(followable, klass, opts = {})
          rel = klass.where(:id =>
            self.select(:follower_id).
              where(:follower_type => klass.table_name.classify).
              where(:followable_type => followable.class.to_s).
              where(:followable_id => followable.id)
          )

          if opts[:pluck]
            rel.pluck(opts[:pluck])
          else
            rel
          end
        end

        # Returns all the followers of a certain type that are following followable
        def followers(followable, klass, opts = {})
          rel = followers_relation(followable, klass, opts)
          if rel.is_a?(ActiveRecord::Relation)
            rel.all
          else
            rel
          end
        end

        # Returns an ActiveRecord::Relation of all the followables of a certain type that are followed by follower
        def followables_relation(follower, klass, opts = {})
          rel = klass.where(:id =>
            self.select(:followable_id).
              where(:followable_type => klass.table_name.classify).
              where(:follower_type => follower.class.to_s).
              where(:follower_id => follower.id)
          )

          if opts[:pluck]
            rel.pluck(opts[:pluck])
          else
            rel
          end
        end

        # Returns all the followables of a certain type that are followed by follower
        def followables(follower, klass, opts = {})
          rel = followables_relation(follower, klass, opts)
          if rel.is_a?(ActiveRecord::Relation)
            rel.all
          else
            rel
          end
        end

        def touch(what = nil)
          if what.nil?
            @touch || false
          else
            raise ArgumentError unless [:all, :follower, :followable, false, nil].include?(what)
            @touch = what
          end
        end

        def after_follow(method)
          raise ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_create_hook = method
        end

        def after_unfollow(method)
          raise ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_destroy_hook = method
        end

      private
        def call_after_create_hook(follower, followable)
          self.send(@after_create_hook, follower, followable) if @after_create_hook
        end

        def call_after_destroy_hook(follower, followable)
          self.send(@after_destroy_hook, follower, followable) if @after_destroy_hook
        end

        def follow_for(follower, followable)
          followed_by(follower).following(followable)
        end
      end # class << self

    end
  end
end
