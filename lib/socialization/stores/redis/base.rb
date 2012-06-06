module Socialization
  module RedisStores
    class Base
      @@after_create_hook = nil
      @@after_destroy_hook = nil
    end
  end
end