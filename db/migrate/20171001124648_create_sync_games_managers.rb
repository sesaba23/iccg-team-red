class CreateSyncGamesManagers < ActiveRecord::Migration[5.1]
  def change
    create_table :sync_games_managers do |t|
      t.text :user_state
      t.text :games

      t.timestamps
    end
  end
end
