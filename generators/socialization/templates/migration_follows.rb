class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.string  :follower_type
      t.integer :follower_id
      t.string  :followable_type
      t.integer :followable_id
      t.datetime :created_at
    end

    add_index :follows, ["follower_id", "follower_type"],     :name => "fk_follows"
    add_index :follows, ["followable_id", "followable_type"], :name => "fk_followables"
  end
end
