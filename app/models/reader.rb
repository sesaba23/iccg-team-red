class Reader < ApplicationRecord
  belongs_to :game

################### get info about game state ####################
  
  # returns true if, during this round, this reader is the questioner
  def is_questioner?
    self.game.is_questioner(:reader)
  end

  # returns true if a new round just started
  def new_round?
    self.game.new_round?
  end

  # returns true if a questions is available for this round
  def question_available?
    self.game.question_available
  end

  # returns true if both answers are available in this round
  def answers_available?
    self.game.answers_available
  end

  # returns a symbol representing the game's state
  def game_state
    self.game.get_state
  end

##################### get interaction content ####################

  # if a question is available for this round,
  # returns a string containing the question for this round
  def get_question
    self.game.get_current_question
  end

  # if guesser's answer is available,
  # returns a sring containing the guesser's answer
  def get_guessers_answer
    self.game.get_answer(:guesser) if self.answers_available?
  end

  # if reader's answer is available,
  # returns a string containing the reader's answer
  def get_readers_answer
    self.game.get_answer(:reader) unless
      (['ask', 'answer_any', 'answer_reader'].include? self.game.state)
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

############################# submit #############################
  
  # if it's the readers turn to submit a question,
  # submits a question to the game
  # question:  a nonempty string
  def submit_question(question)
    self.game.submit_question(:reader, question)
  end

  # if it's the readers turn to submit an answer,
  # submits an answer to the game
  # answer: a nonempty string containing the answer
  def submit_answer(answer)
    self.game.submit_answer(:reader, answer)
  end

end
