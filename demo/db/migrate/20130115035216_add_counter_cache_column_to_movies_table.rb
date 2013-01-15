class AddCounterCacheColumnToMoviesTable < ActiveRecord::Migration
  def change
    add_column :movies, :likes_count, :integer, :default => 0
  end
end
