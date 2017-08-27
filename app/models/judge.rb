class Judge < ApplicationRecord
  belongs_to :game

  # returns true if a questions is available for this round
  def question_available?
    self.game.question_available
  end

  # if a question is available for this round,
  # returns a string containing the question for this round
  def get_question
    self.game.get_current_question
  end

  # returns true if both answers are available in this round
  def answers_available?
    self.game.answers_available
  end

  # returns a hash with two answers
  def get_answers
    self.game.get_anonymized_answers
  end

  # labels get_answers[:answer1] as the suspicious answer
  def first_answer_suspicious
    self.game.more_suspect_answer_is(:answer1)
    self.game.next_round
  end

  # labels get_answers[:answer2] as the suspicious answer
  def second_answer_suspicious
    self.game.more_suspect_answer_is(:answer2)
    self.game.next_round
  end

  # returns an array of hashes. Each hash represents a line
  # on the whiteboard.
  # questioner: either "reader" or "guesser"
  # question: string containing the question
  # reader_answer: string containing reader answer
  # guesser_answer: string containing guesser answer
  # guesser_marked: true if judge identified guesser correctly
  # timestamp: string containing time when the line was created
  def get_whiteboard_hashes
    self.game.get_whiteboard_hashes
  end

  # if the document is a text document,
  # returns a string containing the document's text
  def get_document_text
    self.game.document_content
  end
end
