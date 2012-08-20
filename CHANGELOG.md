# Changelog

## 0.5.0.beta (June 6, 2012)

* **IMPORTANT:** This release includes many changes, some breaking. Make sure to test your code carefully after upgrading.
* **BREAKING CHANGE:** Your Like, Follow and Mention models should now inherit the Socialization store base class instead of using the acts_as helper. (e.g.: class Follow < Socialization::ActiveRecordStores::Follow). See demo app for an example.
* **BREAKING CHANGE:** the `followers`, `followables` etc methods now return an array of objects. Use methods such as `followers_relation` for an ActiveRecord::Relation.
* Changed: The persistence logic has now been moved to the Socialization::ActiveRecordStores namespace. More stores can be easily added.
* Changed: `like!`, `follow!`, and `mention!` now return a boolean. True when the action was successful, false when it wasn't (e.g.: the relationship already exists).
* Changed: `unlike!`, `unfollow!` and `unmention!` will now return false if there is no record to destroy rather than raising `ActiveRecord::RecordNotFound`.
* Changed: Records can now like, follow or mention themselves. If you want to prevent this, it should be enforced directly in your application.
* Added: Data can now be stored in Redis.
* Added: `toggle_like!`, `toggle_follow!` and `toggle_mention!` methods. Thanks to [@balvig](https://github.com/balvig).
* Added: support for single table inheritance. Thanks to [@balvig](https://github.com/balvig).
* Changed: raises Socialization::ArgumentError instead of ::ArgumentError

## v0.4.0 (February 25, 2012)

* **BREAKING CHANGE:** Renamed `mentionner` to `mentioner`. This is proper English.
* Added: `followees`, `likees` and `mentionees` methods to `Follower`, `Liker` and `Mentioner`. Thanks to [@ihara2525](https://github.com/ihara2525).

## v0.3.0 (February 22, 2012)

* **BREAKING CHANGE:** `likers`, `followers` now return a scope instead of an array. They also require to have the class of the desired scope as an argument. For example: `Movie.find(1).followers(User)`.
* Added: Mention support.
* Some refactoring and clean up. Thanks to [@tilsammans](https://github.com/tilsammans)


## 0.2.2 (January 15, 2012)

* Improved tests.
* Changed: Can no longer like or follow yourself.

## 0.2.1 (January 15, 2012)

* Bug fixes

## 0.2.0 (January 15, 2012)

* Bug fixes
* Made Ruby 1.8.7 compatible

## 0.1.0 (January 14, 2012)

* Initial release