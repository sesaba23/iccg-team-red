class CreateQueuedPlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :queued_players do |t|
      t.integer :user_id
      t.belongs_to :multiplayer_queue

      t.timestamps
    end
  end
end
