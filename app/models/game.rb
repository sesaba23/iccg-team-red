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
  has_one :reader
  has_one :guesser
  has_one :judge
  belongs_to :document
  has_one :whiteboard

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
  end

  # role: must be :reader, :guesser or :judge.
  # question: a string
  # if role is not the current questioner, raises RoleMismatchError.
  # if question is an empty string, raises NoContentError.
  # if a question has alread been successfully submitted during this
  # round, raises MultipleSubmissionsError.
  # otherwise makes question this round's question.
  def submit_question(role, question)
    # TODO: incomplete, needs revision
    if self.current_questioner.to_sym == role
      self.update(current_question: question)
    else
      raise RoleMismatchError
    end
  end

  # role is :reader or :guesser
  # return true if role is the current questioner
  # return false otherwise
  def is_questioner(role)
    raise NotImplementedError
  end

  # role: must be :reader, :guesser or :judge.
  # answer: a string
  # if role is :judge raises RoleMismatchError.
  # if answer is an empty string raises NoContentError.
  # if answer has already been submitted by this role during
  # this round raises MultipleSubmissionsError.
  # otherwise makes answer this round's answer of this role.
  def submit_answer(role, answer)
    raise NotImplementedError
  end

  # if both answers have not yet been entered raises
  # NotYetAvailableError.
  # returns a hash with keys :answer1 and :answer2
  # and the two answers as values. Which answer is assigned
  # which key should be random.
  def get_anonymized_answers
    raise NotImplementedError
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
    raise NotImplementedError
  end

  # if called before more_suspicious_answer_is, raises NotYetAvailableError
  # otherwise returns the role (symbol) of the author of the answer which was judged
  # more suspicious.
  def judged_suspicious
    raise NotImplementedError
  end

  # if no question has yet been set, raises NotYetAvailableError.
  # returns the question of this round.
  def get_current_question
    raise NotImplementedError
  end

  # returns true if a question is available for this round
  # returns false otherwise
  def question_available
    raise NotImplementedError
  end

  # returns true if both answers are available for this round
  # returns false otherwise
  def answers_available
    raise NotImplementedError
  end

  # returns a string that represents the history of this game
  def get_whiteboard_string
    raise NotImplementedError
  end

  # returns a symbol which indicates the type of the document
  # e.g. :text
  def document_type
    raise NotImplementedError
  end

  # returns the content of the document
  # what is return will depend on the type of the document
  def document_content
    raise NotImplementedError
  end

  # unless the current round has accepted a question, answers from reader
  # and guesser and a judgement,
  # raises NotYetAvailableError.
  # commits the record of this round to the whiteboard,
  # starts the next round and
  # returns the updated scores of reader, judge, and guesser in a hash
  # {reader: reader_score, guesser: guesser_score, judge: judge_score}
  def next_round
    raise NotImplementedError
  end

  private

  def update_scores
    raise NotImplementedError
  end

  def next_questioner
    raise NotImplementedError
  end
end

class RoleMismatchError < ArgumentError
end

class NoContentError < ArgumentError
end
