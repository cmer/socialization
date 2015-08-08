require "spec_helper"

context "RedisStoreConfigTest" do
  before do
    Socialization.instance_eval { @redis = nil }
  end

  it "returns a new Redis object when none were specified" do
    expect(Socialization.redis).to be_a Redis
  end

  it "always returns the same Redis object when none were specified" do
    redis = Socialization.redis
    expect(Socialization.redis).to eq(redis)
  end

  it "is able to set and get a redis instance" do
    redis = Redis.new
    Socialization.redis = redis
    expect(Socialization.redis).to eq(redis)
  end

  it "always return the same Redis object when it was specified" do
    redis = Redis.new
    Socialization.redis = redis
    expect(Socialization.redis).to eq(redis)
  end
end
