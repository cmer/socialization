require File.expand_path(File.dirname(__FILE__))+'/test_helper'

# Test Socialization as it would be used in a "real world" scenario
class WorldTest < Test::Unit::TestCase
  attr_reader :users, :movies, :celebs


  context "The World" do
    setup do
      seed
    end

    should "be social" do
      john.like!(pulp)
      john.follow!(jane)
      john.follow!(travolta)

      assert john.likes?(pulp)
      assert john.follows?(jane)
      assert john.follows?(travolta)

      assert pulp.liked_by?(john)
      assert travolta.followed_by?(john)

      carl.like!(pulp)
      camilo.like!(pulp)
      assert_equal 3, pulp.likers.size

      assert pulp.likers.include?(carl)
      assert pulp.likers.include?(john)
      assert pulp.likers.include?(camilo)
      assert !pulp.likers.include?(mat)

      carl.follow!(mat)
      mat.follow!(carl)
      camilo.follow!(carl)

      assert carl.follows?(mat)
      assert mat.followed_by?(carl)
      assert mat.follows?(carl)
      assert carl.followed_by?(mat)
      assert camilo.follows?(carl)
      assert !carl.follows?(camilo)

      assert_raise ArgumentError do
        john.like!(travolta) # Can't like a Celeb
      end

      assert_raise ArgumentError do
        john.follow!(killbill) # Can't follow a movie
      end

      assert_raise ArgumentError do
        john.follow!(john) # Can't follow yourself, duh!
      end

      assert_raise ArgumentError do
        john.like!(john) # Can't like yourself, duh!
      end
    end
  end

  def seed
    @users  = {}
    @celebs = {}
    @movies = {}

    @users[:john] = User.create :name => 'John Doe'
    @users[:jane] = User.create :name => 'Jane Doe'
    @users[:mat]  = User.create :name => 'Mat'
    @users[:carl] = User.create :name => 'Carl'
    @users[:camilo] = User.create :name => 'Camilo'

    @movies[:pulp] = Movie.create :name => 'Pulp Fiction'
    @movies[:reservoir] = Movie.create :name => 'Reservoir Dogs'
    @movies[:killbill]  = Movie.create :name => 'Kill Bill'

    @celebs[:willis] = Celebrity.create :name => 'Bruce Willis'
    @celebs[:travolta] = Celebrity.create :name => 'John Travolta'
    @celebs[:jackson] = Celebrity.create :name => 'Samuel L. Jackson'
  end

  def method_missing(meth, *args, &block)
    sym = meth.to_sym
    return users[sym] if users[sym]
    return celebs[sym] if celebs[sym]
    return movies[sym] if movies[sym]
    super
  end

end
