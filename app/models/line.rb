class Line < ApplicationRecord
  belongs_to :whiteboard

  def line_string
    output = "Q: #{self.question} R: #{self.reader_answer} G: #{self.guesser_answer}"
    if self.judgement_correct
      output += " J: Guesser identified"
    else
      output += " J: Guesser not identified"
    end
    return output
  end
end
