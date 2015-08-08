module Socialization
  module ActiveRecordStores
    class Mention < ActiveRecord::Base
      extend Socialization::Stores::Mixins::Base
      extend Socialization::Stores::Mixins::Mention
      extend Socialization::ActiveRecordStores::Mixins::Base

      belongs_to :mentioner,   :polymorphic => true
      belongs_to :mentionable, :polymorphic => true

      scope :mentioned_by, lambda { |mentioner| where(
        :mentioner_type   => mentioner.class.name.classify,
        :mentioner_id     => mentioner.id)
      }

      scope :mentioning,   lambda { |mentionable| where(
        :mentionable_type => mentionable.class.name.classify,
        :mentionable_id   => mentionable.id)
      }

      class << self
        def mention!(mentioner, mentionable)
          unless mentions?(mentioner, mentionable)
            self.create! do |mention|
              mention.mentioner = mentioner
              mention.mentionable = mentionable
            end
            update_counter(mentioner, mentionees_count: +1)
            update_counter(mentionable, mentioners_count: +1)
            call_after_create_hooks(mentioner, mentionable)
            true
          else
            false
          end
        end

        def unmention!(mentioner, mentionable)
          if mentions?(mentioner, mentionable)
            mention_for(mentioner, mentionable).destroy_all
            update_counter(mentioner, mentionees_count: -1)
            update_counter(mentionable, mentioners_count: -1)
            call_after_destroy_hooks(mentioner, mentionable)
            true
          else
            false
          end
        end

        def mentions?(mentioner, mentionable)
          !mention_for(mentioner, mentionable).empty?
        end

        # Returns an ActiveRecord::Relation of all the mentioners of a certain type that are mentioning mentionable
        def mentioners_relation(mentionable, klass, opts = {})
          rel = klass.where(:id =>
            self.select(:mentioner_id).
              where(:mentioner_type => klass.name.classify).
              where(:mentionable_type => mentionable.class.to_s).
              where(:mentionable_id => mentionable.id)
          )

          if opts[:pluck]
            rel.pluck(opts[:pluck])
          else
            rel
          end
        end

        # Returns all the mentioners of a certain type that are mentioning mentionable
        def mentioners(mentionable, klass, opts = {})
          rel = mentioners_relation(mentionable, klass, opts)
          if rel.is_a?(ActiveRecord::Relation)
            rel.to_a
          else
            rel
          end
        end

        # Returns an ActiveRecord::Relation of all the mentionables of a certain type that are mentioned by mentioner
        def mentionables_relation(mentioner, klass, opts = {})
          rel = klass.where(:id =>
            self.select(:mentionable_id).
              where(:mentionable_type => klass.name.classify).
              where(:mentioner_type => mentioner.class.to_s).
              where(:mentioner_id => mentioner.id)
          )

          if opts[:pluck]
            rel.pluck(opts[:pluck])
          else
            rel
          end
        end

        # Returns all the mentionables of a certain type that are mentioned by mentioner
        def mentionables(mentioner, klass, opts = {})
          rel = mentionables_relation(mentioner, klass, opts)
          if rel.is_a?(ActiveRecord::Relation)
            rel.to_a
          else
            rel
          end
        end

        # Remove all the mentioners for mentionable
        def remove_mentioners(mentionable)
          self.where(:mentionable_type => mentionable.class.name.classify).
               where(:mentionable_id => mentionable.id).destroy_all
        end

        # Remove all the mentionables for mentioner
        def remove_mentionables(mentioner)
          self.where(:mentioner_type => mentioner.class.name.classify).
               where(:mentioner_id => mentioner.id).destroy_all
        end

      private
        def mention_for(mentioner, mentionable)
          mentioned_by(mentioner).mentioning(mentionable)
        end
      end # class << self

    end
  end
end
