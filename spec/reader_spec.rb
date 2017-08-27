require 'rails_helper'
require 'byebug'

describe Reader do
  describe "play as reader" do
    before do
      @game = Game.create(document_id: 2)
      @game.setup(1, 2, 3)
      @reader = @game.reader
    end

    it "should be able to play one round" do
      if @reader.is_questioner?
        @reader.submit_question("What food is mentioned?")
      end
      
      expect(@reader.question_available?).to be_truthy
      expect(@reader.get_question).to eq("What food is mentioned?")
      
      @reader.submit_answer("a delicious dessert")
      
      expect(!@reader.answers_available?).to be_truthy
      
      @game.submit_answer(:guesser, "spaghetti")
      
      expect(@reader.answers_available?).to be_truthy
      
      answers = @game.get_anonymized_answers
      @suspicious_answer = nil
      answers.each {|key, value| @suspicious_answer=key if value=="spaghetti"}
      @game.more_suspect_answer_is(@suspicious_answer)
      @scores = @game.next_round
      expect(@reader.new_round?).to be_truthy
      expect(@scores[:reader]).to eq(1)
      expect(@scores[:guesser]).to eq(0)
      expect(@scores[:judge]).to eq(1)
    end
  end
end
