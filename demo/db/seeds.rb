User.create :name => 'Mia Wallace'
User.create :name => 'Vincent Vega'
User.create :name => 'Jules Winnfield'
User.create :name => 'Butch Coolidge'

Movie.create :name => 'Pulp Fiction'
Movie.create :name => 'Reservoir Dogs'
Movie.create :name => 'Kill Bill'
Movie.create :name => 'Inglorious Basterds'

Celebrity.create :name => 'Uma Thurman'
Celebrity.create :name => 'John Travlota'
Celebrity.create :name => 'Samuel L. Jackson'
Celebrity.create :name => 'Bruce Willis'

c = Comment.create :user_id => 1, :movie_id => 1, :body => 'Awesome movie. Vincent Vega is awesome in it!'
c.mention!(User.find_by_name("Vincent Vega"))
