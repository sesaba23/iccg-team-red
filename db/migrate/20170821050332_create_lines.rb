class CreateLines < ActiveRecord::Migration[5.1]
  def change
    create_table :lines do |t|
      t.string :questioner
      t.string :question
      t.string :reader_answer
      t.string :guesser_answer
      t.boolean :judgement_correct
      t.belongs_to :whiteboard

      t.timestamps
    end
  end
end
