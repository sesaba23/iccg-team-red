class CreateSyncGamesManagers < ActiveRecord::Migration[5.1]
  def change
    create_table :sync_games_managers do |t|
      ## users
      t.text :idle
      t.text :queued
      t.text :playing
      ## games
      t.text :active_games
      t.text :finished_games

      t.timestamps
    end
  end
end
