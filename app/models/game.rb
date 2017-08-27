# The Abstract Game
# =================
# 
# The game:
# A game has three players: guesser, reader and judge.
# It also has one document which is available to reader and judge.
# During each round of the game, reader or guesser get to ask a question
# about the content of the document. Both reader and guesser answer that
# question. Reader and guesser both try to convince the judge that they
# are in possession of the document, by providing a good answer to the
# question. The judge's goal is to determine which answer was given by the
# guesser.
#
# Transfer of information to guesser:
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
# This class represents the game and provides methods for manipulating the game
# and viewing information about its state.

class Game < ApplicationRecord

  # Representation:
  # ===============
  # The game is represented by
  # * a state machine with 8 states:
  #   ask, answer_any, answer_reader, answer_guesser, anonymize, judge,
  #   score, game_over (for state diagram see TODO: upload a picture)
  # * [current_question, current_questioner, reader_answer,
  #   guesser_answer, current_judged_suspicious] fields
  #   - these are repopulated during each round.
  # The states determine which of the fields are up-to-date
  # in the current round.

  # the three users of the game class
  has_one :reader
  has_one :guesser
  has_one :judge
  ###################################
  
  belongs_to :document
  has_one :whiteboard

  @@states = ['ask', 'answer_any', 'answer_reader', 'answer_guesser',
              'anonymize', 'judge' ,'score', 'game_over']
  @@roles = [:reader, :guesser, :judge]

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
    self.current_questioner = questioner
    self.reader_score = 0
    self.guesser_score = 0
    self.judge_score = 0
    self.state = 'ask'
    self.save!
  end

  # returns true if a new round just started
  def new_round?
    self.state == 'ask'
  end

  # role: must be :reader, :guesser or :judge.
  # question: a string
  # if role is not the current questioner, raises RoleMismatchError.
  # if question is an empty string, raises NoContentError.
  # if a question has alread been successfully submitted during this
  # round, raises MultipleSubmissionsError.
  # otherwise makes question this round's question.
  def submit_question(role, question)
    unless self.state == 'ask'
      raise MultipleSubmissionsError
    end
    raise NoContentError if question.empty?
    if self.current_questioner.to_sym == role
      self.update(current_question: question)
      self.state = 'answer_any'
      self.save!
    else
      raise RoleMismatchError
    end
  end

  # role is :reader or :guesser
  # return true if role is the current questioner
  # return false otherwise
  def is_questioner(role)
    raise ArgumentError, "must be :reader or :guesser" unless
      role == :reader or role == :guesser
    return role == self.current_questioner.to_sym
  end

  # role: must be :reader, :guesser or :judge.
  # answer: a string
  # if role is :judge raises RoleMismatchError.
  # if answer is an empty string raises NoContentError.
  # if answer has already been submitted by this role during
  # this round raises MultipleSubmissionsError.
  # if called out of order, raises NotYetAvailableError
  # otherwise makes answer this round's answer of this role.
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

  # if called out of order raises NotYetAvailableError.
  # returns a hash with keys :answer1 and :answer2
  # and the two answers as values. Which answer is assigned
  # which key should be random.
  def get_anonymized_answers
    raise NotYetAvailableError unless self.state == 'anonymize'
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

  # answer_key: must be :answer1 or :answer2, which are
  # keys of the hash returned by get_anonymized_answers during this
  # round.
  # answer_key is the key of the question which has been identified
  # as most suspect.
  # if answer_key is not :answer1 or :answer2 raises ArgumentError.
  # if called before get_anonymized_answers, raises NotYetAvailableError.
  # otherwise submits a judgement.
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

  # if called before more_suspicious_answer_is, raises NotYetAvailableError
  # otherwise returns the role (symbol) of the author of the answer which was judged
  # more suspicious.
  def judged_suspicious
    raise NotYetAvailableError unless self.state == 'score'
    return self.current_judged_suspicious.to_sym
  end

  # if no question has yet been set, raises NotYetAvailableError.
  # returns the question of this round.
  def get_current_question
    raise NotYetAvailableError if self.state == 'ask'
    return self.current_question
  end

  # returns true if a question is available for this round
  # returns false otherwise
  def question_available
    return self.state != 'ask'
  end

  # returns the current answer for this role
  # role is :guesser or :reader
  # DANGER: this will return whatever is currently saved
  # does not need to have been submitted during this round
  def get_answer(role)
    if role == :reader
      return self.current_reader_answer
    elsif role == :guesser
      return self.current_guesser_answer
    else
      raise ArgumentError
    end
  end

  # returns true if both answers are available for this round
  # returns false otherwise
  def answers_available
    return @@states[4,7].include? self.state
  end

  # returns a string that represents the history of this game
  def get_whiteboard_string
    self.whiteboard.board_string
  end

  # returns a list of hashes
  # every hash represents a line on the whiteboard
  def get_whiteboard_hashes
    self.whiteboard.board_hashes
  end

  # returns a symbol which indicates the type of the document
  # e.g. :text
  def document_type
    self.document.get_document_type
  end

  # returns the content of the document
  # what is return will depend on the type of the document
  def document_content
    return self.document.content if self.document_type == :text
    raise ArgumentError, "unknown document type"
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

  # ends the game
  def over
    next_round
    self.state = 'game_over'
    self.save
  end

  private

  # returns array of new scores hash
  # with key value pairs like reader: integer (score value)
  # updates scores in table
  def update_scores
    #byebug
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

  def is_game_over
    raise NotImplementedError
  end
end

class RoleMismatchError < ArgumentError
end

class NoContentError < ArgumentError
end

class MultipleSubmissionsError < ArgumentError
end

class NotYetAvailableError < ArgumentError
end
