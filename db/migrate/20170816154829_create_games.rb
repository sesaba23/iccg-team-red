class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.string :current_question
      t.string :current_questioner
      t.string :current_reader_answer
      t.string :current_guesser_answer
      t.string :current_judgement

      t.timestamps
    end
  end
end
