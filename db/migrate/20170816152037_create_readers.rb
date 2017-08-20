class CreateReaders < ActiveRecord::Migration[5.1]
  def change
    create_table :readers do |t|
      t.integer :user_id
      t.belongs_to :game, index: true

      t.timestamps
    end
    
  end
end
