class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.string  :liker_type
      t.integer :liker_id
      t.string  :likeable_type
      t.integer :likeable_id
      t.datetime :created_at
    end

    add_index :likes, ["liker_id", "liker_type"],       :name => "fk_likes"
    add_index :likes, ["likeable_id", "likeable_type"], :name => "fk_likeables"
  end
end
