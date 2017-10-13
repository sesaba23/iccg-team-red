class RenameDocumentsAttributes < ActiveRecord::Migration[5.1]
  def up
    rename_column :documents, :doc_type, :kind
    rename_column :documents, :text, :content
  end

  def down
    rename_column :documents, :kind, :doc_type
    rename_column :documents, :content, :text
  end
end
