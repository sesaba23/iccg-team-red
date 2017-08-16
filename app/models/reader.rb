class Reader < ApplicationRecord
  belongs_to :game

  def submit_question(question)
    self.game.submit_question(:reader, question)
  end
end
