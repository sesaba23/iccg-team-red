class Whiteboard < ApplicationRecord
  belongs_to :game
  belongs_to :document
  has_many :lines

  def write_line(questioner,
                 question,
                 reader_answer,
                 guesser_answer,
                 guesser_identified)
    
    self.lines.push(Line.create(questioner: questioner,
                                question: question,
                                reader_answer: reader_answer,
                                guesser_answer: guesser_answer,
                                judgement_correct: guesser_identified))
  end

  def board_string
    output = ""
    self.lines.each{|l| output += l.line_string + "\n"}
    return output
  end
  
end
