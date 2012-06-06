module Socialization
  module ActiveRecordStores
    class Like < ActiveRecord::Base
      belongs_to :liker,    :polymorphic => true
      belongs_to :likeable, :polymorphic => true

      scope :liked_by, lambda { |liker| where(
        :liker_type    => liker.class.table_name.classify,
        :liker_id      => liker.id)
      }

      scope :liking,   lambda { |likeable| where(
        :likeable_type => likeable.class.table_name.classify,
        :likeable_id   => likeable.id)
      }

      @@after_create_hook = nil
      @@after_destroy_hook = nil

      class << self
        def like!(liker, likeable)
          unless likes?(liker, likeable)
            self.create! do |like|
              like.liker = liker
              like.likeable = likeable
            end
            call_after_create_hook(liker, likeable)
            liker.touch if [:all, :liker].include?(touch) && liker.respond_to?(:touch)
            likeable.touch if [:all, :likeable].include?(touch) && likeable.respond_to?(:touch)
            true
          else
            false
          end
        end

        def unlike!(liker, likeable)
          if likes?(liker, likeable)
            like_for(liker, likeable).destroy_all
            call_after_destroy_hook(liker, likeable)
            liker.touch if [:all, :liker].include?(touch) && liker.respond_to?(:touch)
            likeable.touch if [:all, :likeable].include?(touch) && likeable.respond_to?(:touch)
            true
          else
            false
          end
        end

        def likes?(liker, likeable)
          !like_for(liker, likeable).empty?
        end

        # Returns an ActiveRecord::Relation of all the likers of a certain type that are liking  likeable
        def likers_relation(likeable, klass, opts = {})
          rel = klass.where(:id =>
            self.select(:liker_id).
              where(:liker_type => klass.table_name.classify).
              where(:likeable_type => likeable.class.to_s).
              where(:likeable_id => likeable.id)
          )

          if opts[:pluck]
            rel.pluck(opts[:pluck])
          else
            rel
          end
        end

        # Returns all the likers of a certain type that are liking  likeable
        def likers(likeable, klass, opts = {})
          rel = likers_relation(likeable, klass, opts)
          if rel.is_a?(ActiveRecord::Relation)
            rel.all
          else
            rel
          end
        end

        # Returns an ActiveRecord::Relation of all the likeables of a certain type that are liked by liker
        def likeables_relation(liker, klass, opts = {})
          rel = klass.where(:id =>
            self.select(:likeable_id).
              where(:likeable_type => klass.table_name.classify).
              where(:liker_type => liker.class.to_s).
              where(:liker_id => liker.id)
          )

          if opts[:pluck]
            rel.pluck(opts[:pluck])
          else
            rel
          end
        end

        # Returns all the likeables of a certain type that are liked by liker
        def likeables(liker, klass, opts = {})
          rel = likeables_relation(liker, klass, opts)
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
            raise ArgumentError unless [:all, :liker, :likeable, false, nil].include?(what)
            @touch = what
          end
        end

        def after_like(method)
          raise ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_create_hook = method
        end

        def after_unlike(method)
          raise ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_destroy_hook = method
        end

      private
        def call_after_create_hook(liker, likeable)
          self.send(@after_create_hook, liker, likeable) if @after_create_hook
        end

        def call_after_destroy_hook(liker, likeable)
          self.send(@after_destroy_hook, liker, likeable) if @after_destroy_hook
        end

        def like_for(liker, likeable)
          liked_by(liker).liking( likeable)
        end
      end # class << self

    end
  end
end
