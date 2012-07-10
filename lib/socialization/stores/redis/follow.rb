module Socialization
  module RedisStores
    class Follow < Socialization::RedisStores::Base
      extend Socialization::Stores::Mixins::Base
      extend Socialization::Stores::Mixins::Follow
      extend Socialization::RedisStores::Mixins::Base

      class << self
        alias_method :follow!, :relation!;                          public :follow!
        alias_method :unfollow!, :unrelation!;                      public :unfollow!
        alias_method :follows?, :relation?;                         public :follows?
        alias_method :followers_relation, :actors_relation;         public :followers_relation
        alias_method :followers, :actors;                           public :followers
        alias_method :followables_relation, :victims_relation;      public :followables_relation
        alias_method :followables, :victims;                        public :followables
        alias_method :remove_followers, :remove_actor_relations;    public :remove_followers
        alias_method :remove_followables, :remove_victim_relations; public :remove_followables
      end

    end
  end
end
