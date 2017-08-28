class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.string :current_question
      t.string :current_questioner
      t.string :current_reader_answer
      t.string :current_guesser_answer
      t.string :current_judged_suspicious
      t.string :state
      t.integer :coin_flip
      t.integer :guesser_score
      t.integer :reader_score
      t.integer :judge_score
      t.belongs_to :document

      t.timestamps
    end
  end
end
