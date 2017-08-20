class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.string :doc_type
      t.string :text

      t.timestamps
    end
  end
end
