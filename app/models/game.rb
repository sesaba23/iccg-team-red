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

class Game < ApplicationRecord

  # Representation:
  # ===============
  # The game is represented by
  # * 8 states:
  #   ask, answer_any, answer_reader, answer_guesser, anonymize, judge,
  #   score, game_over (for state diagram see TODO: upload a picture)
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
              'anonymize', 'judge' ,'score', 'game_over']
  @@roles = [:reader, :guesser, :judge]


  ########################################
  ### DEPRECATED ###
  
  # a game should be created in the following way:
  #
  # game = Game.create(document_id) or
  # document.games.push(Game.create)
  # game.setup(reader_id, guesser_id, judge_id)
  #
  # reader_id is the id of the user who plays as reader
  # guesser_id is the id of the user who plays as guesser
  # judge_id is the id of the user who plays as judge
  # ids must correspond to users
  # prepares the game for play
  def setup(reader_id, guesser_id, judge_id, questioner=:reader)
    self.reader = Reader.create(user_id: reader_id)
    self.guesser = Guesser.create(user_id: guesser_id)
    self.judge = Judge.create(user_id: judge_id)
    self.whiteboard = Whiteboard.create(document_id: self.document_id)

    # You need to create a document in the model
    #self.document = Document.create(doc_type: "text", text: "I am the winner!")

    self.current_questioner = questioner
    self.reader_score = 0
    self.guesser_score = 0
    self.judge_score = 0
    self.state = 'ask'
    self.save!
  end
  ########################################
  
  #################### CREATORS ####################
  
  # Create a game object and all dependencies.
  # - param document: object of type Document (app/models/document.rb), is the document
  #         the game is played with.
  # - param xxx_user_id: optional integer value identifying the user who plays in
  #         role xxx
  # - returns: a new game object that is added to document.games.
  def self.setup(document, reader_user_id=0, guesser_user_id=0, judge_user_id=0)
    # TODO: implement
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
    # store coin flip result to be able to decode later
    self.coin_flip = rand(2)
    answers = Hash.new
    # hide identity
    if self.coin_flip == 0
      answers[:answer1] = self.current_reader_answer
      answers[:answer2] = self.current_guesser_answer
    else
      answers[:answer1] = self.current_guesser_answer
      answers[:answer2] = self.current_reader_answer
    end
    self.state = 'judge'
    self.save
    return answers
  end

  # Ask who's answer was deemed more suspicious during this round.
  # - raises: NotYetAvailableError if a judgement has not yet been submitted this round.
  # - returns: the role (:reader or :guesser) of the author of the answer which was
  #            judged more suspicious.
  def judged_suspicious
    raise NotYetAvailableError unless self.state == 'score'
    return self.current_judged_suspicious.to_sym
  end

  # Ask if the guesser has been identified in this round.
  # - raises: NotYetAvailableError if a judgement has not yet been submitted for
  #           this round
  # - returns: a boolean indicating whether the guesser has been identified.
  def guesser_identified
    # TODO: implement
  end

  # Get the question for this round.
  # - raises: NotYetAvailableError if no question is yet available for this round. 
  # - returns: the question for this round.
  def get_current_question
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
      return self.current_reader_answer if
        !(['ask', 'answer_any', 'answer_reader'].include? self.state)
    elsif role == :guesser
      return self.current_guesser_answer if
        !(['ask', 'answer_any', 'answer_guesser'].include? self.state)
    else
      raise ArgumentError
    end
    return false
  end

  # Ask if an answer is already available for this round.
  # - param role: Indicates the role who's answers is of interest.
  #         Must be :reader or :guesser.
  # - returns: a boolean indicating whether an answer is available for this round.
  def answer_available(role)
    #TODO: implement
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
    # TODO: implement
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
    # TODO: implement
  end

  # Ask whether the game has concluded.
  # - returns a boolean indicating if the game has concluded.
  def is_game_over
    # TODO: implement
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
    unless self.state == 'ask'
      raise MultipleSubmissionsError
    end
    raise NoContentError if question.empty?
    if self.current_questioner.to_sym == role
      self.update(current_question: question)
      self.state = 'answer_any'
      self.save
    else
      raise RoleMismatchError
    end
  end

  # Submit an answer to the game.
  # - param role: indicates who is submitting the answer
  #         must be :reader or :guesser
  # - param answer: a nonempty string that represents the answer
  # - raises: NotYetAvailableError if no answer is expected form role
  #           NoContentError if answer is an empty string
  def submit_answer(role, answer)
    raise ArgumentError unless @@roles.include? role
    raise RoleMismatchError if role==:judge
    raise NoContentError if answer.empty?
    raise MultipleSubmissionsError if
      ((self.state == 'answer_reader' and role == :guesser) or
       (self.state == 'answer_guesser' and role == :reader))
    raise NotYetAvailableError unless
      ['answer_reader', 'answer_guesser', 'answer_any'].include? self.state
    if role == :reader
      # set answer
      self.current_reader_answer = answer
      # update state
      if self.state == 'answer_any'
        self.state = 'answer_guesser'
      elsif self.state == 'answer_reader'
        self.state = 'anonymize'
      end
    else
      # set answer
      self.current_guesser_answer = answer
      # update state
      if self.state == 'answer_any'
        self.state = 'answer_reader'
      elsif self.state == 'answer_guesser'
        self.state = 'anonymize'
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
    decode_hash = Hash.new
    if self.coin_flip == 0
      decode_hash[:answer1] = 'reader'
      decode_hash[:answer2] = 'guesser'
    else
      decode_hash[:answer1] = 'guesser'
      decode_hash[:answer2] = 'reader'
    end
    self.current_judged_suspicious = decode_hash[answer_key]
    self.state = 'score'
    self.save
  end

  # Marks the game as concluded. When a game is over it can no longer be
  # changed.
  def over
    next_round
    self.state = 'game_over'
    self.save
  end

  #################### PRIVATE ####################

  private

  # Generate a random order for the answers in this round.
  # - raises: NotYetAvailableError if both answers have not yet been given this round
  #           NotYetAvailableError if answers have already been anonymized this round
  def anonymize_answers
    # TODO: implement
  end

  # unless the current round has accepted a question, answers from reader
  # and guesser and a judgement,
  # raises NotYetAvailableError.
  # commits the record of this round to the whiteboard,
  # starts the next round and
  # returns the updated scores of reader, judge, and guesser in a hash
  # {reader: reader_score, guesser: guesser_score, judge: judge_score}
  def next_round
    raise NotYetAvailableError unless self.state == 'score'
    guesser_identified = (self.current_judged_suspicious == 'guesser')
    self.whiteboard.write_line(self.current_questioner,
                               self.current_question,
                               self.current_reader_answer,
                               self.current_guesser_answer,
                               guesser_identified)
    
    self.current_questioner = get_next_questioner
    scores = update_scores
    # reset state
    self.state = 'ask'
    self.save
    return scores
  end

  # returns array of new scores hash
  # with key value pairs like reader: integer (score value)
  # updates scores in table
  def update_scores
    raise NotYetAvailableError unless self.state == 'score'
    if current_judged_suspicious == 'guesser'
      self.judge_score += 1
      self.reader_score += 1
    else
      self.guesser_score += 1
    end
    self.save
    scores = Hash.new
    scores[:reader] =  self.reader_score
    scores[:guesser] = self.guesser_score
    scores[:judge] = self.judge_score
    return scores
  end

  def get_next_questioner
    ['reader', 'guesser'][rand(2)] # random questioner
  end
end

class RoleMismatchError < ArgumentError
end

class NoContentError < ArgumentError
end

class NotYetAvailableError < ArgumentError
end
