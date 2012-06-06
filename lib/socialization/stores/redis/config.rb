module Socialization
  class << self
    def redis
      @redis ||= Redis.new
    end

    def redis=(redis)
      @redis = redis
    end
  end
end
