class CreateJoinTableCollectionDocument < ActiveRecord::Migration[5.1]
  def change
    create_join_table :collections, :documents do |t|
      # t.index [:collection_id, :document_id]
      # t.index [:document_id, :collection_id]
    end
  end
end
