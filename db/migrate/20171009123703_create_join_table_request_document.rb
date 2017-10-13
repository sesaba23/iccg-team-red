class CreateJoinTableRequestDocument < ActiveRecord::Migration[5.1]
  def change
    create_join_table :requests, :documents do |t|
      # t.index [:request_id, :document_id]
      # t.index [:document_id, :request_id]
    end
  end
end
