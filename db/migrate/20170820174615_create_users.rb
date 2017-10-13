class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.text :known_documents
      t.belongs_to :invite

      t.timestamps
    end
  end
end
