module Socialization
  module ActiveRecordStores
    class Like < ActiveRecord::Base
      extend Socialization::Stores::Mixins::Base
      extend Socialization::Stores::Mixins::Like
      extend Socialization::ActiveRecordStores::Mixins::Base

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

      after_create { |record|
        likeableClass = record.likeable_type.capitalize.constantize
        likerClass = record.liker_type.capitalize.constantize
        
        # Increment likes count of likeable (The movie is liked by 20 people)
        if likeableClass.column_names.include?("likers_count")
          likeableClass.increment_counter(:likers_count, record.likeable_id)
        end

        # Increment likes count of liker (The User likes 20 things)
        if likerClass.column_names.include?("likeables_count")
          likerClass.increment_counter(:likeables_count, record.liker_id)
        end
      }

      after_destroy { |record|
        likeableClass = record.likeable_type.capitalize.constantize
        likerClass = record.liker_type.capitalize.constantize
        
        # Decrement likes count of likeable (The movie is liked by 20 people)
        if likeableClass.column_names.include?("likers_count")
          likeableClass.decrement_counter(:likers_count, record.likeable_id)
        end

        # Decrement likes count of liker (The User likes 20 things)
        if likerClass.column_names.include?("likeables_count")
          likerClass.decrement_counter(:likeables_count, record.liker_id)
        end
      }

      class << self
        def like!(liker, likeable)
          unless likes?(liker, likeable)
            self.create! do |like|
              like.liker = liker
              like.likeable = likeable
            end
            call_after_create_hooks(liker, likeable)
            true
          else
            false
          end
        end

        def unlike!(liker, likeable)
          if likes?(liker, likeable)
            like_for(liker, likeable).destroy_all
            call_after_destroy_hooks(liker, likeable)
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

        # Return 
        def likeables_count(liker)
          if liker.has_attribute("likings_count")
            liker.likings_count
          end
        end

        # Remove all the likers for likeable
        def remove_likers(likeable)
          self.where(:likeable_type => likeable.class.name.classify).
               where(:likeable_id => likeable.id).destroy_all
        end

        # Remove all the likeables for liker
        def remove_likeables(liker)
          self.where(:liker_type => liker.class.name.classify).
               where(:liker_id => liker.id).destroy_all
        end

      private
        def like_for(liker, likeable)
          liked_by(liker).liking( likeable)
        end
      end # class << self

    end
  end
end
