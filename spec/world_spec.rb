require 'spec_helper'

# Test Socialization as it would be used in a "real world" scenario
describe "The World" do
  cattr_reader :users, :movies, :celebs, :comments

  %w(john jane mat carl camilo tami).each do |user|
    define_method(user) { @users[user.to_sym] }
  end

  %w(pulp reservoir kill_bill).each do |movie|
    define_method(movie) { @movies[movie.to_sym] }
  end

  %w(willis travolta jackson).each do |celeb|
    define_method(celeb) { @celebs[celeb.to_sym] }
  end

  before(:all) do
    seed
  end

  shared_examples "the world" do
    it "acts like it should" do
      john.like!(pulp)
      john.follow!(jane)
      john.follow!(travolta)

      expect(john.likes?(pulp)).to be true
      expect(john.follows?(jane)).to be true
      expect(john.follows?travolta).to be true

      expect(pulp.liked_by?(john)).to be true
      expect(travolta.followed_by?(john)).to be true

      carl.like!(pulp)
      camilo.like!(pulp)
      expect(pulp.likers(User).size).to eq(3)

      expect(pulp.likers(User).include?(carl)).to be true
      expect(pulp.likers(User).include?(john)).to be true
      expect(pulp.likers(User).include?(camilo)).to be true
      expect(!pulp.likers(User).include?(mat)).to be true

      carl.follow!(mat)
      mat.follow!(carl)
      camilo.follow!(carl)

      expect(carl.follows?(mat)).to be true
      expect(mat.followed_by?(carl)).to be true
      expect(mat.follows?(carl)).to be true
      expect(carl.followed_by?(mat)).to be true
      expect(camilo.follows?(carl)).to be true
      expect(!carl.follows?(camilo)).to be true

      # Can't like a Celeb
      expect { john.like!(travolta) }.to raise_error(Socialization::ArgumentError)

      # Can't follow a movie
      expect { john.follow!(kill_bill) }.to raise_error(Socialization::ArgumentError)

      # You can even follow or like yourself if your ego is that big.
      expect(john.follow!(john)).to be true
      expect(john.like!(john)).to be true

      comment = john.comments.create(:body => "I think Tami and Carl would like this movie!", :movie_id => pulp.id)
      comment.mention!(tami)
      comment.mention!(carl)
      expect(comment.mentions?(carl)).to be true
      expect(carl.mentioned_by?(comment)).to be true
      expect(comment.mentions?(tami)).to be true
      expect(tami.mentioned_by?(comment)).to be true
    end
  end

  context "ActiveRecord store" do
    before(:all) { use_ar_store }
    it_behaves_like "the world"
  end

  context "Redis store" do
    before(:all) { use_redis_store }
    it_behaves_like "the world"
  end

  def seed
    @users    = {}
    @celebs   = {}
    @movies   = {}

    @users[:john]       = User.create :name => 'John Doe'
    @users[:jane]       = User.create :name => 'Jane Doe'
    @users[:mat]        = User.create :name => 'Mat'
    @users[:carl]       = User.create :name => 'Carl'
    @users[:camilo]     = User.create :name => 'Camilo'
    @users[:tami]       = User.create :name => 'Tami'

    @movies[:pulp]      = Movie.create :name => 'Pulp Fiction'
    @movies[:reservoir] = Movie.create :name => 'Reservoir Dogs'
    @movies[:kill_bill] = Movie.create :name => 'Kill Bill'

    @celebs[:willis]    = Celebrity.create :name => 'Bruce Willis'
    @celebs[:travolta]  = Celebrity.create :name => 'John Travolta'
    @celebs[:jackson]   = Celebrity.create :name => 'Samuel L. Jackson'
  end

end
