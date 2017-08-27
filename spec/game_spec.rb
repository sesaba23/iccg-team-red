require 'rails_helper'
require 'byebug'

describe Game do

  before do
    @document = Document.create(doc_type: "text", text: "I am the winner!")
  end
  
  describe "submit_question" do
    before do
      @game = Game.create(document_id: @document.id)
      @game.setup(1, 2, 3)
    end
    
    it "should raise RoleMismatchError if role does not match" do
      expect {@game.submit_question(:guesser, "bla!")}.
               to raise_error(RoleMismatchError)
    end
    it "should raise NoContentError if question is empty" do
      expect {@game.submit_question(:reader, "")}.
        to raise_error(NoContentError)
    end
    it "should raise MultipleSubmissionsError if submitted a second time" do
      @game.submit_question(:reader, "bla?")
      expect {@game.submit_question(:reader, "blaaa?")}.
        to raise_error(MultipleSubmissionsError)
    end
    it "should update current question when role matches" do
      @game.submit_question(:reader, "is the text about elephants?")
      expect(@game.current_question).to eq("is the text about elephants?")
    end
  end

  describe "submit_answer" do
    before do
      @game = Game.create(document_id: 2)
      @game.setup(1, 2, 3)
      @game.submit_question(:reader, "is there any cake?")
    end

    it "should raise RoleMismatchError if judge submits answer" do
      expect {@game.submit_answer(:judge, "pi is 3.145926")}.
        to raise_error(RoleMismatchError)
    end
    it "should raise NoContentError if answer is empty" do
      expect {@game.submit_answer(:guesser, "")}.
        to raise_error(NoContentError)
    end
    it "should raise MultipleSubmissionsError if submit a second time" do
      @game.submit_answer(:reader, "the cake is a lie")
      expect {@game.submit_answer(:reader,
                                  "there will be cake if I pass this test")}.
        to raise_error(MultipleSubmissionsError)
    end
    it "should update answer" do
      @game.submit_answer(:guesser, "yes")
      expect(@game.current_guesser_answer).to eq("yes")
    end
  end

  describe "get_anonymized_answers" do
    before do
      @game = Game.create(document_id: 2)
      @game.setup(1, 2, 3)
      @game.submit_question(:reader, "is there any cake?")
      @game.submit_answer(:reader, "the cake is a lie")
    end

    it "should raise NotYetAvailableError if answers pending" do
      expect {@game.get_anonymized_answers}.
        to raise_error(NotYetAvailableError)
    end
    it "should return a hash with keys :answer1 and :answer2" do
      @game.submit_answer(:guesser, "of course there will be cake")
      expect(@game.get_anonymized_answers.keys).
        to contain_exactly(:answer1, :answer2)
    end
    it "should return a hash containing the two answers" do
      @game.submit_answer(:guesser, "of course there will be cake")
      expect(@game.get_anonymized_answers.values).
        to contain_exactly("the cake is a lie",
                           "of course there will be cake")
    end
  end

  describe "more_suspect_answer_is" do
    before do
      @game = Game.create(document_id: 1)
      @game.setup(1, 2, 3)
      @game.submit_question(:reader, "Who eats Great Whites?")
      @game.submit_answer(:guesser, "humans")
      @game.submit_answer(:reader, "Orcas")
    end

    it "should raise an ArgumentError if argument is not valid" do
      @game.get_anonymized_answers
      expect {@game.more_suspect_answer_is(:guesser_answer)}.
        to raise_error(ArgumentError)
    end
    it "should raise NotYetAvailableError if called before get_anonymized_answers" do
      expect {@game.more_suspect_answer_is(:answer1)}.
        to raise_error(NotYetAvailableError)
    end
    it "should update the judgement" do
      answers = @game.get_anonymized_answers
      suspect_answer = nil
      answers.each {|key, value| suspect_answer = key if value=="humans"}
      @game.more_suspect_answer_is(suspect_answer)
      expect(@game.judged_suspicious).to eq(:guesser)
    end
  end

  describe "judged_suspicious" do
    before do
      @game = Game.create(document_id: 1)
      @game.setup(1, 2, 3)
      @game.submit_question(:reader, "Who eats Great Whites?")
      @game.submit_answer(:guesser, "humans")
      @game.submit_answer(:reader, "Orcas")
      @answers = @game.get_anonymized_answers
    end

    it "should raise NotYetAvailableError if called before more_suspect_answer_is" do
      expect {@game.judged_suspicious}.
        to raise_error(NotYetAvailableError)
    end
    it "should return the role of the author of the suspicious answer" do
      suspect_answer = nil
      @answers.each {|key, value| suspect_answer = key if value=="humans"}
      @game.more_suspect_answer_is(suspect_answer)
      expect(@game.judged_suspicious).
        to eq(:guesser)
    end
  end

  describe "get_current_question" do
    before do
      @game = Game.create(document_id: 1)
      @game.setup(1, 2, 3)
    end
    
    it "should raise NotYetAvailableError if question not available" do
      expect {@game.get_current_question}.
        to raise_error(NotYetAvailableError)
    end
    it "should return the current question" do
      @game.submit_question(:reader, "Who eats Great Whites?")
      expect(@game.get_current_question).
        to eq("Who eats Great Whites?")
    end
  end

  describe "question_available" do
    before do
      @game = Game.create(document_id: 1)
      @game.setup(1, 2, 3)
    end

    it "should return false if there is no question for this round" do
      expect(@game.question_available).
        to eq(false)
    end
    it "should return true if there is a question for this round" do
      @game.submit_question(:reader, "Is the text about whales?")
      expect(@game.question_available).
        to eq(true)
    end
  end

  describe "answers_available" do
    before do
      @game = Game.create(document_id: 1)
      @game.setup(1, 2, 3)
      @game.submit_question(:reader, "is the text about dolphins?")
      @game.submit_answer(:reader, "yes")
    end

    it "should return false if answers are pending" do
      expect(@game.answers_available).to be_falsey
    end
    it "should return true if answer are available" do
      @game.submit_answer(:guesser, "yes")
      expect(@game.answers_available).to be_truthy
    end
  end

  describe "document_type" do
    it "should return the document type" do
      @game = Game.create(document_id: 1)
      @game.setup(1, 2, 3)
      document_types = [:text]
      #byebug
      expect(document_types).to include(@game.document_type)
    end
  end

  describe "document_content" do
    before do
      @game = Game.create(document_id: 1)
      @game.setup(1, 2, 3)
    end

    it "should return a string if document is a text document" do
      expect(@game.document_content).to be_a(String)
    end
  end

  describe "next_round" do
    before do
      @game = Game.create(document_id: 2)
      @game.setup(1, 2, 3)
      @game.submit_question(:reader, "What food is mentioned?")
      @game.submit_answer(:reader, "a delicious dessert")
      @game.submit_answer(:guesser, "spaghetti")
      answers = @game.get_anonymized_answers
      @suspicious_answer = nil
      answers.each {|key, value| @suspicious_answer=key if value=="spaghetti"}
    end

    it "should raise NotYetAvailableError if called before round is complete" do
      expect {@game.next_round}.
        to raise_error(NotYetAvailableError)
    end
    before do
      @game.more_suspect_answer_is(@suspicious_answer)
      @scores = @game.next_round
    end
    it "should return the correct scores" do
      expect(@scores[:reader]).to eq(1)
      expect(@scores[:guesser]).to eq(0)
      expect(@scores[:judge]).to eq(1)
    end
    it "during the next round whiteboard should show the previous round" do
      wb = @game.get_whiteboard_string
      expect(wb).to include("What food is mentioned?")
      expect(wb).to include("a delicious dessert")
      expect(wb).to include("spaghetti")
    end
    it "should be possible to play another round" do
      if @game.is_questioner(:guesser)
        questioner = :guesser
        other = :reader
      else
        questioner = :reader
        other = :guesser
      end
      @game.submit_question(questioner, "who eats the delicious dessert?")
      @game.submit_answer(:reader, "no one")
      @game.submit_answer(:guesser, "a hungry person")
      answers = @game.get_anonymized_answers
      suspicious_answer = nil
      answers.each {|key, value| suspicious_answer=key if value=="a hungry person"}
      @game.more_suspect_answer_is(suspicious_answer)
      scores = @game.next_round
      expect(scores[:reader]).to eq(2)
      expect(scores[:guesser]).to eq(0)
      expect(scores[:judge]).to eq(2)
    end
  end

end
