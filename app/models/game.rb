class Game < ApplicationRecord
  has_one :reader
  has_one :guesser
  has_one :judge
  has_one :document
  has_one :whiteboard

  def submit_question(role, question)
    if self.current_questioner.to_sym == role
      self.update(current_question: question)
    end
  end
end
