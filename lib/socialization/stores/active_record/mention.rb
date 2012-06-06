module Socialization
  module ActiveRecordStores
    class Mention < ActiveRecord::Base
      belongs_to :mentioner,   :polymorphic => true
      belongs_to :mentionable, :polymorphic => true

      scope :mentioned_by, lambda { |mentioner| where(
        :mentioner_type   => mentioner.class.table_name.classify,
        :mentioner_id     => mentioner.id)
      }

      scope :mentioning,   lambda { |mentionable| where(
        :mentionable_type => mentionable.class.table_name.classify,
        :mentionable_id   => mentionable.id)
      }

      @@after_create_hook = nil
      @@after_destroy_hook = nil

      class << self
        def mention!(mentioner, mentionable)
          unless mentions?(mentioner, mentionable)
            self.create! do |mention|
              mention.mentioner = mentioner
              mention.mentionable = mentionable
            end
            call_after_create_hook(mentioner, mentionable)
            mentioner.touch if [:all, :mentioner].include?(touch) && mentioner.respond_to?(:touch)
            mentionable.touch if [:all, :mentionable].include?(touch) && mentionable.respond_to?(:touch)
            true
          else
            false
          end
        end

        def unmention!(mentioner, mentionable)
          if mentions?(mentioner, mentionable)
            mention_for(mentioner, mentionable).destroy_all
            call_after_destroy_hook(mentioner, mentionable)
            mentioner.touch if [:all, :mentioner].include?(touch) && mentioner.respond_to?(:touch)
            mentionable.touch if [:all, :mentionable].include?(touch) && mentionable.respond_to?(:touch)
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
              where(:mentioner_type => klass.table_name.classify).
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
            rel.all
          else
            rel
          end
        end

        # Returns an ActiveRecord::Relation of all the mentionables of a certain type that are mentioned by mentioner
        def mentionables_relation(mentioner, klass, opts = {})
          rel = klass.where(:id =>
            self.select(:mentionable_id).
              where(:mentionable_type => klass.table_name.classify).
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
            rel.all
          else
            rel
          end
        end

        def touch(what = nil)
          if what.nil?
            @touch || false
          else
            raise ArgumentError unless [:all, :mentioner, :mentionable, false, nil].include?(what)
            @touch = what
          end
        end

        def after_mention(method)
          raise ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_create_hook = method
        end

        def after_unmention(method)
          raise ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_destroy_hook = method
        end

      private
        def call_after_create_hook(mentioner, mentionable)
          self.send(@after_create_hook, mentioner, mentionable) if @after_create_hook
        end

        def call_after_destroy_hook(mentioner, mentionable)
          self.send(@after_destroy_hook, mentioner, mentionable) if @after_destroy_hook
        end

        def mention_for(mentioner, mentionable)
          mentioned_by(mentioner).mentioning(mentionable)
        end
      end # class << self

    end
  end
end
