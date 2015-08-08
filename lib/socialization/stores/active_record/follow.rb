module Socialization
  module ActiveRecordStores
    class Follow < ActiveRecord::Base
      extend Socialization::Stores::Mixins::Base
      extend Socialization::Stores::Mixins::Follow
      extend Socialization::ActiveRecordStores::Mixins::Base

      belongs_to :follower,   :polymorphic => true
      belongs_to :followable, :polymorphic => true

      scope :followed_by, lambda { |follower| where(
        :follower_type   => follower.class.name.classify,
        :follower_id     => follower.id)
      }

      scope :following,   lambda { |followable| where(
        :followable_type => followable.class.name.classify,
        :followable_id   => followable.id)
      }

      class << self
        def follow!(follower, followable)
          unless follows?(follower, followable)
            self.create! do |follow|
              follow.follower = follower
              follow.followable = followable
            end
            update_counter(follower, followees_count: +1)
            update_counter(followable, followers_count: +1)
            call_after_create_hooks(follower, followable)
            true
          else
            false
          end
        end

        def unfollow!(follower, followable)
          if follows?(follower, followable)
            follow_for(follower, followable).destroy_all
            update_counter(follower, followees_count: -1)
            update_counter(followable, followers_count: -1)
            call_after_destroy_hooks(follower, followable)
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
              where(:follower_type => klass.name.classify).
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
            rel.to_a
          else
            rel
          end
        end

        # Returns an ActiveRecord::Relation of all the followables of a certain type that are followed by follower
        def followables_relation(follower, klass, opts = {})
          rel = klass.where(:id =>
            self.select(:followable_id).
              where(:followable_type => klass.name.classify).
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
            rel.to_a
          else
            rel
          end
        end

        # Remove all the followers for followable
        def remove_followers(followable)
          self.where(:followable_type => followable.class.name.classify).
               where(:followable_id => followable.id).destroy_all
        end

        # Remove all the followables for follower
        def remove_followables(follower)
          self.where(:follower_type => follower.class.name.classify).
               where(:follower_id => follower.id).destroy_all
        end

      private
        def follow_for(follower, followable)
          followed_by(follower).following(followable)
        end
      end # class << self

    end
  end
end
