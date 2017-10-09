class CreateInvites < ActiveRecord::Migration[5.1]
  def change
    create_table :invites do |t|
      t.integer :reader_id
      t.integer :guesser_id
      t.integer :judge_id
      t.belongs_to :sync_games_manager
      t.belongs_to :document

      t.timestamps
    end
  end
end
