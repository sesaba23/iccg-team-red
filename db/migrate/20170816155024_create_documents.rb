class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.integer :game_id
      t.string :text

      t.timestamps
    end
  end
end
