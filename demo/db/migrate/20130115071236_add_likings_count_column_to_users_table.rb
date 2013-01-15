class AddLikingsCountColumnToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :likings_count, :integer, :default => 0
  end
end
