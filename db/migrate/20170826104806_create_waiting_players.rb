class CreateWaitingPlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :waiting_players do |t|
      t.integer :user_id
      t.boolean :active

      t.timestamps
    end
  end
end
