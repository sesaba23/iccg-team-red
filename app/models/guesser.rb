class Guesser < ApplicationRecord
  belongs_to :game
  
  ################### OBSERVERS  ####################
  
  # Ask whether this guesser asks the question during this round.
  # - returns: a boolean indicating whether the reader is the questioner.
  def is_questioner?
    self.game.is_questioner(:guesser)
  end

  # Ask if a new round just started.
  # - returns: a boolean indicating whether a new round has started,
  #            but no actions have yet been taken
  def new_round?
    self.game.new_round?
  end

  # Ask if a question is already available for this round.
  # - returns a boolean indicating whether a question is already available.
  def question_available?
    self.game.question_available
  end

  # Ask if both answers are already available for this round.
  # - returns: a boolean indicating whether both answers are already available.
  def answers_available?
    self.game.answers_available
  end

  # Get the question for this round.
  # - raises: NotYetAvailableError if no question is yet available for this round. 
  # - returns: the question for this round.
  def get_question
    self.game.get_question
  end

  # Attempts to get the guesser's answer.
  # - returns: a string containing the guesser's answer or nil if the reader has not
  #            yet submitted an answer during this round.
  def get_guessers_answer
    self.game.get_answer(:guesser) unless
      (['ask', 'answer_any', 'answer_guesser'].include? self.game.state)
  end

  # Attempts to get the readers's answer. Only succeeds if reader and guesser already
  # submitted their answers during this round.
  # - returns: a string containing the reader's answer or nil
  def get_readers_answer
    self.game.get_answer(:reader) if self.answers_available?
  end

  # Get the total score for each player.
  # - returns: a hash with keys :reader, :guesser and :judge
  #            and integer values representing their respective scores.
  def get_scores
    self.game.get_scores
  end

  # Get the content of the whiteboard.
  # - returns: an array of hashes, where every hash represents one round of the game.
  #            Each hash has keys:
  #            * questioner: either "reader" or "guesser"
  #            * question: string containing the question
  #            * reader_answer: string containing reader answer
  #            * guesser_answer: string containing guesser answer
  #            * guesser_marked: true if judge identified guesser correctly
  #            * timestamp: string containing the time when the line was created
  def get_whiteboard_hashes
    self.game.get_whiteboard_hashes
  end

  # Ask whether the game has concluded.
  # - returns a boolean indicating if the game has concluded.
  def is_game_over
    self.game.is_over
  end

  #################### MUTATORS ####################
  
  # Submit a question to the game.
  # - param question: a nonempty string that represents the question
  # - raises: RoleMismatchError if guesser is not the current questioner
  #           NoContentError if question is an empty string
  #           NotYetAvailableError if no question should be submitted at this point
  def submit_question(question)
    self.game.submit_question(:guesser, question)
  end

  # Submit an answer to the game.
  # - param answer: a nonempty string that represents the answer
  # - raises: NotYetAvailableError if no answer is expected at this point
  #           NoContentError if answer is an empty string
  def submit_answer(answer)
    self.game.submit_answer(:guesser, answer)
  end
end
