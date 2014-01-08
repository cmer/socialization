# Socialization

Socialization is a Ruby Gem that allows any ActiveRecord model to `Follow`, `Like` and/or `Mention` any other model. ActiveRecord or Redis can be used as a data store.

The Follow feature is similar to Twitter's follow. For example, John follows Jane. Unlike Facebook's "friendship", Follow is a one-way concept. The fact that John follows Jane doesn't mean that Jane follows John.

The Like feature works just like a Facebook Like. For example, John likes Pulp Fiction.

The Mention feature was written with Facebook mentions in mind. For example, John mentions Jane in a comment. Typically, Jane would be highlighted in the comment user interface and possibly notified that John mentioned her. This Facebook feature is occasionally called Tagging, although tagging is generally something [entirely different](http://en.wikipedia.org/wiki/Tag_(metadata).

[![Build Status](https://secure.travis-ci.org/cmer/socialization.png?branch=master)](http://travis-ci.org/cmer/socialization)

## Installation

### Rails 3/4

Add the gem to the gemfile:
`gem "socialization"`

Run the generator:
`rails generate socialization -s`

Or if you want to use Redis as your data store:
`rails generate socialization -s --store=redis`

This will generate three migration files (when using ActiveRecord) and three models named Follow, Like and Mention. You may delete any of the Follow, Like or Mention models and migrations if you don't need that functionality in your application.

### Rails 2.3.x Support

This gem requires Rails 3 or better. Sorry!

## Usage

### Setup

Allow a model to be followed:

    class Celebrity < ActiveRecord::Base
      ...
      acts_as_followable
      ...
    end

Allow a model to be a follower:

    class User < ActiveRecord::Base
      ...
      acts_as_follower
      ...
    end


Allow a model to be liked:

    class Movie < ActiveRecord::Base
      ...
      acts_as_likeable
      ...
    end

Allow a model to like:

    class User < ActiveRecord::Base
      ...
      acts_as_liker
      ...
    end

Allow a model to be mentioned:

    class User < ActiveRecord::Base
      ...
      acts_as_mentionable
      ...
    end

Allow a model to mention:

    class Comment < ActiveRecord::Base
      ...
      acts_as_mentioner
      ...
    end

Or a more complex case where users can like and follow each other:

    class User < ActiveRecord::Base
      ...
      acts_as_follower
      acts_as_followable
      acts_as_liker
      acts_as_likeable
      acts_as_mentionable
      ...
    end

***


### acts_as_follower Methods

Follow something

    user.follow!(celebrity)

Stop following

    user.unfollow!(celebrity)

Toggle

    user.toggle_follow!(celebrity)

Is following?

    user.follows?(celebrity)

What items are you following (given that an Item model is followed)?

    user.followees(Item)


***


### acts_as_followable Methods

Find out if an objects follows

    celebrity.followed_by?(user)

All followers

    celebrity.followers(User)


***


### acts_as_liker Methods

Like something

    user.like!(movie)

Stop liking

    user.unlike!(movie)

Toggle

    user.toggle_like!(celebrity)

Likes?

    user.likes?(movie)

***


### acts_as_likeable Methods

Find out if an objects likes

    movie.liked_by?(user)

All likers

    movie.likers(User)

***


### acts_as_mentioner Methods

**Note that a "mentioner" is the object containing the mention and not necessarily the actor. For example, John mentions Jane in a comment. The mentioner is the comment object, NOT John.**

Mention something

    comment.mention!(user)

Remove mention

    comment.unmention!(user)

Toggle

    user.toggle_mention!(celebrity)

Mentions?

    comment.mentions?(user)

All mentionees

    comment.mentionees(User)

***


### acts_as_mentionable Methods

Find out if an objects mentions

    user.mentioned_by?(comment)

All mentioners

    user.mentioners(Comment)


***


## Documentation

You can find the compiled YARD documentation at http://rubydoc.info/github/cmer/socialization/frames. Documentation for methods inside `include` blocks is not currently generated although it exists in the code. A custom YARD filter needs to be written for YARD to pick those up.


***

## Changelog

Here it is: https://github.com/cmer/socialization/blob/master/CHANGELOG.md

## Demo App

For your convenience, I have added a demo app in demo/demo_app. It does not have a web UI, but you can play with Socialization in the Rails console. It should also help you figure out hown to use Socialization in the Real World.

To use the demo app:

    $ cd demo/demo_app
    $ bundle
    $ rake db:migrate
    $ rake db:seed
    $ rails console


## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Send me a pull request. Bonus points for topic branches.

## Similar Projects

[acts_as_follower](https://github.com/tcocca/acts_as_follower) is a similar project that I only discovered when I was 95% finished writing the first version of Socialization. I initially intended to name this project acts_as_follower only to find out the name was taken. You might want to check it out as well so see which one suits your needs better. Socialization is simpler, supports "Likes" and "Mentions" and easilly extendable; acts_as_follower has more "Follow" features, however.


## Copyright

Copyright (c) 2012-2014 Carl Mercier --  Released under the MIT license.
