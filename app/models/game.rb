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
# This class represents the game and provides methods for the basic
# manipulations
# * submitting questions
# * submitting answers
# * get the anonymoized answers for the current round
# * select one of the anonymous answers as suspicious
# * generating scores for the current round,
#   selecting the next role to ask a question
#   and starting the next round

class Game < ApplicationRecord
  has_one :reader
  has_one :guesser
  has_one :judge
  has_one :document
  has_one :whiteboard

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
    end
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

  # answer_id: must be :answer1 or :answer2, which are
  # keys of the hash returned by get_anonymized_answers during this
  # round.
  # answer_id is the key of the question which has been identified
  # as most suspect.
  # Submits a judgement.
  def more_suspect_answer_is(answer_id)
    raise NotImplementedError
  end

  # if no question has yet been set, raises NotYetAvailableError.
  # returns the question of this round.
  def get_current_question
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
