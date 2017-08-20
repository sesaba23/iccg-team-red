class CreateWhiteboards < ActiveRecord::Migration[5.1]
  def change
    create_table :whiteboards do |t|
      t.integer :game_id
      t.belongs_to :document

      t.timestamps
    end
  end
end
