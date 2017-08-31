class CreateMultiplayerQueues < ActiveRecord::Migration[5.1]
  def change
    create_table :multiplayer_queues do |t|
      t.integer :player1
      t.integer :player2
      t.integer :player3
      t.boolean :created
      t.integer :players_processed
      t.integer :game_id
      
      t.timestamps
    end
  end
end
