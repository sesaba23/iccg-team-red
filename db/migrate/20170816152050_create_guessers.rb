class CreateGuessers < ActiveRecord::Migration[5.1]
  def change
    create_table :guessers do |t|
      t.integer :user_id
      t.integer :game_id

      t.timestamps
    end
  end
end
