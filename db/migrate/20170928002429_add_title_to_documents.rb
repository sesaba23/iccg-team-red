class AddTitleToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :title, :string, null: false, default: 'untitled'
  end
end
