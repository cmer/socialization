module Socialization
  class << self
    # Force loading of classes if they're not already loaded
    begin; Follow; end
    begin; Mention; end
    begin; Like; end

    def follow_model
      if @follow_model
        @follow_model
      elsif defined?(::Follow)
        ::Follow
      else
        raise RuntimeError.new("No Follow model has been defined.")
      end
    end

    def follow_model=(klass)
      @follow_model = klass
    end

    def like_model
      if @like_model
        @like_model
      elsif defined?(::Like)
        ::Like
      else
        raise RuntimeError.new("No Like model has been defined.")
      end
    end

    def like_model=(klass)
      @like_model = klass
    end

    def mention_model
      if @mention_model
        @mention_model
      elsif defined?(::Mention)
        ::Mention
      else
        raise RuntimeError.new("No Mention model has been defined.")
      end
    end

    def mention_model=(klass)
      @mention_model = klass
    end
  end
end