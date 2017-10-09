class CreateRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :requests do |t|
      t.boolean :reader
      t.boolean :guesser
      t.boolean :judge
      t.belongs_to :sync_games_manager
      t.belongs_to :user

      t.timestamps
    end
  end
end
