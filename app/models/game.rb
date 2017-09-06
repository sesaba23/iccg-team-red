# The Abstract Game
# =================
# 
# The game:
# A game has three roles: guesser, reader and judge. In every game there is one of each.
# It also has one document (e.g. a news article) which is available to reader and judge.
# During each round of the game, reader or guesser get to ask a question
# about the content of the document. Both reader and guesser answer that
# question. Reader and guesser both try to convince the judge that they
# are in possession of the document, by providing a good answer to the
# question. The judge's goal is to determine which answer was given by the
# guesser.
#
# As the game goes on information is transferred to the guesser:
# All previous rounds (questions & answers) are stored on the whiteboard.
# The whiteboard is visible to all players. The guesser learns about the
# contents of the document by reading the whiteboard.
#
# Game score:
# * Judge and reader gain 1 point whenever the judge successfully identifies
#   an answer given by the guesser.
# * The reader gains 1 point whenever the judge fails to correctly identify
#   the guesser's answer.
#
# The Game class
# ==============
#
# This is an implemention of an abstract datatype for the game described above.
#
#
# The game has 3 mutators:
#
# * submit_question
# * submit_answer
# * more_suspicious_answer_is
#  
# Each of these will return an exception if it is called at an inappropriate time. For
# example, submit_answer(:reader, "Who is Charlie?") can be called without exception
# only after a question has been submitted. If it is called again before another question
# is submitted, it will raise an exception.
#
# You can think of each of the mutators being associated with a particluar state of the
# game. If they are called during that state, they will submit a player action and
# transition the game to the next state. If they are called while the game is in a
# different state, they will raise an exception.
#
# There are two types of observers:
# 1. queries that can be called at any time
# 2. queries that can be called without exception only after a particular mutator has
#    been called without exception during the current round.
#    For example, get_question only makes sense after a question has been submitted. 

class Game < ApplicationRecord

  # Representation:
  # ===============
  # The game is represented by
  # * 6 states:
  #   ask, answer_any, answer_reader, answer_guesser, judge, game_over
  #   (for state diagram see [TODO: upload a picture])
  # * the strings current_question, current_questioner, reader_answer,
  #   guesser_answer, current_judged_suspicious
  # * coin_flip, an integer that is either 0 or 1. It encodes the order in which
  #   the two answers are returned. (The order is randomly generated
  #   each round to prevent determining the author from the order.)
  # * three integeres that accumulate the points that each role has earned.
  # * a reference to the document which is used in the game.
  # * a reference to a whiteboard which is a record of all previous rounds
  # * references to three objects that represent the three roles. They contain
  #   the ids of the users who play in each respective role. The game does not
  #   use these ids, but provides access to them from the outside.
  
  has_one :reader
  has_one :guesser
  has_one :judge 
  belongs_to :document
  has_one :whiteboard

  @@states = ['ask', 'answer_any', 'answer_reader', 'answer_guesser',
              'judge' ,'score', 'game_over']
  @@roles = [:reader, :guesser, :judge]
  
  #################### CREATORS ####################
  
  # Create a game object and all dependencies.
  # - param document: object of type Document (app/models/document.rb), is the document
  #         the game is played with.
  # - param xxx_user_id: optional integer value identifying the user who plays in
  #         role xxx
  # - returns: a new game object that is added to document.games.
  def self.setup(document, reader_user_id=0, guesser_user_id=0, judge_user_id=0)
    game = Game.create(state: 'ask', guesser_score: 0, reader_score: 0,
                       judge_score: 0, current_questioner: [:reader, :guesser].sample)
    game.reader = Reader.create(user_id: reader_user_id)
    game.guesser = Guesser.create(user_id: guesser_user_id)
    game.judge = Judge.create(user_id: judge_user_id)
    game.whiteboard = Whiteboard.create
    
    document.whiteboards << game.whiteboard
    document.games << game
    return game
  end

  #################### OBSERVERS ####################
  
  # Ask if a new round just started.
  # - returns: a boolean indicating whether a new round has started,
  #            but no actions have yet been taken
  def new_round?
    self.state == 'ask'
  end

  # Ask if reader or guesser asks the question during the current round.
  # - param role:  must be :reader or :guesser
  # - returns: true if role is asks the question during this round.
  def is_questioner(role)
    raise ArgumentError, "must be :reader or :guesser" unless
      role == :reader or role == :guesser
    return role == self.current_questioner.to_sym
  end

  # Get this round's answers in random order. During a particular round the order
  # remains the same.
  # - raises: NotYetAvailableError if both answers are not yet available for this round
  # - returns a hash with keys :answer1 and :answer2 with the two answers as values
  def get_anonymized_answers
    raise NotYetAvailableError unless
      (self.state == 'anonymize' or self.state =='judge')
    self.state = 'judge'
    self.save
    return encode_answers
  end

  # Get the question for this round.
  # - raises: NotYetAvailableError if no question is yet available for this round. 
  # - returns: the question for this round.
  def get_question
    raise NotYetAvailableError if self.state == 'ask'
    return self.current_question
  end

  # Ask if a question is already available for this round.
  # - returns a boolean indicating whether a question is already available.
  def question_available
    return self.state != 'ask'
  end

  # Get an answer that has been submitted during this round.
  # - param role: Indicates who submitted the answer. Must be :guesser or :reader.
  # - raises: NotYetAvailableError if role has not yet submitted an answer during
  #           this round.
  # - returns: the answer role submitted during this round.
  def get_answer(role)
    if role == :reader
      if !(['ask', 'answer_any', 'answer_reader'].include? self.state)
        return self.current_reader_answer
      else
        raise NotYetAvailableError
      end
    elsif role == :guesser
      if !(['ask', 'answer_any', 'answer_guesser'].include? self.state)
        return self.current_guesser_answer
      else
        raise NotYetAvailableError
      end
    else
      raise ArgumentError
    end
  end

  # Ask if an answer is already available for this round.
  # - param role: Indicates the role who's answers is of interest.
  #         Must be :reader or :guesser.
  # - returns: a boolean indicating whether an answer is available for this round.
  def answer_available(role)
    if role == :reader
      return !(['ask', 'answer_any', 'answer_reader'].include? self.state)
    elsif role == :guesser
      return !(['ask', 'answer_any', 'answer_guesser'].include? self.state)
    end
  end

  # Ask if both answers are already available for this round.
  # - returns: a boolean indicating whether both answers are already available.
  def answers_available
    return @@states[4,7].include? self.state
  end

  # Get the total score for each player.
  # - returns: a hash with keys :reader, :guesser and :judge
  #            and integer values representing their respective scores.
  def get_scores
    return {reader: self.reader_score, guesser: self.guesser_score,
            judge: self.judge_score}
  end

  # Get the next action that is required.
  # - returns: a symbol indicating the actor (:reader, :guesser, :judge)
  #            and a string describing the action.
  def required_action
    # TODO: implement
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
    self.whiteboard.board_hashes
  end

  # Get the type of the document for this game.
  # - returns: a symbol indicating the type of the document.
  #            The following types exist:
  #            * :text
  #            * :link
  #            * :embedded_youtube
  def get_document_type
    self.document.get_document_type
  end

  # Get the contents of the document.
  # - returns: depends on type of document
  #            * text: text as a string
  #            * link: url as a string
  #            * embedded_youtube: url for (embedded) youtube video as a string
  def document_content
    self.document.content
  end

  # Ask whether the game has concluded.
  # - returns a boolean indicating if the game has concluded.
  def is_over
    self.state == 'game_over'
  end

  #################### MUTATORS ####################

  # Submit a question to the game.
  # - param role: symbol that indicates who is submitting the question
  #         must be :reader or :guesser
  # - param question: a nonempty string that represents the question
  # - raises: RoleMismatchError if role is not the current questioner
  #           NoContentError if question is an empty string
  #           NotYetAvailableError if no question should be submitted at this point
  def submit_question(role, question)
    raise RoleMismatchError unless self.is_questioner(role)
    raise NoContentError if question.empty?
    raise NotYetAvailableError unless self.state=='ask'
    self.update(current_question: question)
    self.update(state: 'answer_any')
  end

  # Submit an answer to the game.
  # - param role: indicates who is submitting the answer
  #         must be :reader or :guesser
  # - param answer: a nonempty string that represents the answer
  # - raises: NotYetAvailableError if no answer is expected from role
  #           NoContentError if answer is an empty string
  def submit_answer(role, answer)
    raise ArgumentError unless [:reader, :guesser].include? role
    raise NotYetAvailableError unless (
      (role==:reader and ['answer_reader', 'answer_any'].include? self.state) or
      (role==:guesser and ['answer_guesser', 'answer_any'].include? self.state))
    raise NoContentError if answer.empty?
    if role == :reader
      # set answer
      self.current_reader_answer = answer
      # update state
      if self.state == 'answer_any' # still waiting for guesser
        self.state = 'answer_guesser'
      elsif self.state == 'answer_reader' # done with answers
        anonymize_answers
        self.state = 'judge'
      end
    else
      # set answer
      self.current_guesser_answer = answer
      # update state
      if self.state == 'answer_any' # still waiting for reader
        self.state = 'answer_reader'
      elsif self.state == 'answer_guesser' # done with answers
        anonymize_answers
        self.state = 'judge'
      end
    end
    self.save
  end  

  # Submit which answer is deemed more suspicious.
  # - param answer_key: Indicates which answer is more suspicious. Must be a key of
  #         the hash returned by get_anonymized_answers.
  # - raises: NotYetAvailableError if both answers are not yet available for this round.
  def more_suspect_answer_is(answer_key)
    raise ArgumentError unless [:answer1, :answer2].include? answer_key
    raise NotYetAvailableError unless self.state == 'judge'
    self.current_judged_suspicious = decode_answers[answer_key]
    update_scores
    write_to_whiteboard
    self.update(current_questioner: new_questioner)
    (self.update(state: 'game_over') and return) if game_over_condition
    self.update(state: 'ask')
  end

  #################### PRIVATE ####################

  private

  def game_over_condition
    lines = self.get_whiteboard_hashes
    return false if lines.size < 3
    correct_identification_count = lines[lines.size-3, lines.size-1].
                                   select {|line| line[:guesser_marked]}.
                                   size
    lines.size >= 3 and correct_identification_count == 0
  end

  def anonymize_answers
    self.update(coin_flip: rand(2))
  end

  def encode_answers
    answers = Hash.new
    if self.coin_flip == 0
      answers[:answer1] = self.current_reader_answer
      answers[:answer2] = self.current_guesser_answer
    else
      answers[:answer1] = self.current_guesser_answer
      answers[:answer2] = self.current_reader_answer
    end
    return answers
  end

  def decode_answers
    decode_hash = Hash.new
    if self.coin_flip == 0
      decode_hash[:answer1] = 'reader'
      decode_hash[:answer2] = 'guesser'
    else
      decode_hash[:answer1] = 'guesser'
      decode_hash[:answer2] = 'reader'
    end
    return decode_hash
  end

  def update_scores
    if current_judged_suspicious == 'guesser'
      self.judge_score += 1
      self.reader_score += 1
    else
      self.guesser_score += 1
    end
    self.save
  end

  def write_to_whiteboard
    guesser_identified = (self.current_judged_suspicious == 'guesser')
    self.whiteboard.write_line(self.current_questioner,
                               self.current_question,
                               self.current_reader_answer,
                               self.current_guesser_answer,
                               guesser_identified)
  end

  def new_questioner
    [:reader, :guesser].sample
  end
end


class RoleMismatchError < ArgumentError
end

class NoContentError < ArgumentError
end

class NotYetAvailableError < ArgumentError
end
