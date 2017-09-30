class Judge < ApplicationRecord
  belongs_to :game

  #################### OBSERVERS ####################

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

  # Get the question for this round.
  # - raises: NotYetAvailableError if no question is yet available for this round.
  # - returns: the question for this round.
  def get_question
    self.game.get_question
  end

  # Ask if both answers are already available for this round.
  # - returns: a boolean indicating whether both answers are already available.
  def answers_available?
    self.game.answers_available
  end

  # Get this round's answers in random order. During a particular round the order
  # remains the same.
  # - raises: NotYetAvailableError if both answers are not yet available for this round
  # - returns a hash with keys :answer1 and :answer2 with the two answers as values
  def get_answers
    self.game.get_anonymized_answers
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

  # Get the type of the document in this game.
  # - returns: a symbol indicating the type of the document.
  #            The following types exist:
  #            * :text
  #            * :link
  #            * :embedded_youtube
  def get_document_type
    self.game.get_document_type
  end

  # Get the textual contents of the document.
  # - returns: depends on type of document
  #            * text: text as a string
  #            * link: url as a string
  #            * embedded_youtube: url for (embedded) youtube video as a string
  def get_document_text
    self.game.document
  end

  # Ask whether the game has concluded.
  # - returns a boolean indicating if the game has concluded.
  def is_game_over
    self.game.is_over
  end

  #################### MUTATORS ####################

  # Submit which answer is deemed more suspicious.
  # - param answer_key: Indicates which answer is more suspicious. Must be a key of
  #         the hash returned by get_anonymized_answers.
  # - raises: NotYetAvailableError if both answers are not yet available for this round.
  def more_suspect_is(answer)
    self.game.more_suspect_answer_is(answer)
  end

  # labels get_answers[:answer1] as the suspicious answer
  def first_answer_suspicious
    self.game.more_suspect_answer_is(:answer1)
  end

  # labels get_answers[:answer2] as the suspicious answer
  def second_answer_suspicious
    self.game.more_suspect_answer_is(:answer2)
  end
end
