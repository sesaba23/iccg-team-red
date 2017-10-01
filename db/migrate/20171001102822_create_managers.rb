class CreateManagers < ActiveRecord::Migration[5.1]
  def change
    create_table :managers do |t|
      ## users
      t.integer :offline
      t.text :idle
      t.integer :queued
      t.integer :playing
      ## games
      t.integer :active_synchronous_games
      t.integer :concluded_synchronous_games
      t.integer :active_asynchronous_games
      t.integer :concluded_asynchronous_games

      t.timestamps
    end
  end
end
