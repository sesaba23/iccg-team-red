require 'rails_helper'
require 'byebug'

describe Game do

  before do
    # 'build' creates but doesn't save object; 'create' also saves it
    @document1 = FactoryGirl.create(:document, :id => 1, :doc_type => 'text',
                                    :text => 'GLaDOS is a sentient computer. She promisses cake, but the cake is a lie.')
    @document2 = FactoryGirl.create(:document, :id => 2, :doc_type => 'link',
                                    :text => 'https://en.wikipedia.org/wiki/Aesop%27s_Fables')
    @document3 = FactoryGirl.create(:document, :id => 3, :doc_type => 'embedded_youtube',
                                    :text => 'https://www.youtube.com/embed/_qah8oIzCwk')
    @document4 = FactoryGirl.create(:document, :id => 4, :doc_type => 'link',
                                    :text => 'http://www.aesopfables.com/cgi/aesop1.cgi?1&Androcles')
  end

  #################### CREATORS ####################
  
  describe "setup" do
    it "should create a new game in a valid initial state" do
      @game = Game.setup(@document1, 1, 2, 3)
      expect(@game).to be_present
      expect(@document1.games.to_a).to include(@game)
      expect(@game.new_round?).to be_truthy
      @game.get_scores.each {|role, score| expect(score).to eq(0)}
      expect(@game.whiteboard).to be_present
      expect(@game.reader).to be_present
      expect(@game.guesser).to be_present
      expect(@game.judge).to be_present
    end
  end

  #################### MUTATORS ####################
  
  describe "submit_question" do
    before do
      @game = Game.setup(@document1, 1, 2, 3)
      @questioner = @game.is_questioner(:reader) ? :reader : :guesser
    end
    
    it "should raise RoleMismatchError if role not current questioner" do
      role = @game.is_questioner(:reader) ? :guesser : :reader
      expect {@game.submit_question(role, "But I have a question!")}.
               to raise_error(RoleMismatchError)
    end
    it "should raise NoContentError if question is empty" do
      expect {@game.submit_question(@questioner, "")}.
        to raise_error(NoContentError)
    end
    it "should submit a question to the game after only failed attempts to submit a question" do
      begin
        @game.submit_question(@questioner, "")
      rescue
        @game.submit_question(@questioner, "now I'll submit a nonempty question")
      end
      expect(@game.get_question).to eq("now I'll submit a nonempty question")
    end
    it "should raise NotYetAvailableError if a question has already been submitted" do
      @game.submit_question(@questioner, "bla?")
      expect {@game.submit_question(@questioner, "blaaa?")}.
        to raise_error(NotYetAvailableError)
    end
    it "should pass a question to the game if a question is expected" do
      @game.submit_question(@questioner, "Is the text about elephants?")
      expect(@game.get_question).to eq("Is the text about elephants?")
    end
  end

  describe "submit_answer" do
    before do
      @game = Game.setup(@document1, 1, 2, 3)
      @questioner = @game.is_questioner(:reader) ? :reader : :guesser
    end

    it "should raise NotYetAvailableError if no question has yet been submitted" do
      expect {@game.submit_answer(:reader, "pi is 3.145926")}.
        to raise_error(NotYetAvailableError)
    end
    
    it "should raise NoContentError if answer is empty" do
      @game.submit_question(@questioner, "abcd?")
      expect {@game.submit_answer(:guesser, "")}.
        to raise_error(NoContentError)
    end

    it "after a question has been submitted should allow to submit an answer to the game" do
      @game.submit_question(@questioner, "abcd?")
      @game.submit_answer(:guesser, "yes")
      expect(@game.answer_available(:guesser)).to be_truthy
      expect(@game.answer_available(:reader)).to be_falsey
      expect(@game.get_answer(:guesser)).to eq("yes")
      @game.submit_answer(:reader, "no")
      expect(@game.answer_available(:guesser)).to be_truthy
      expect(@game.answer_available(:reader)).to be_truthy
      expect(@game.get_answer(:reader)).to eq("no")
    end

    it "should raise NotYetAvailableError if an answer was already submitted" do
      @game.submit_question(@questioner, "abcd?")
      @game.submit_answer(:guesser, "yes")
      expect {@game.submit_answer(:guesser, "I changed my mind: the answer is no")}.
        to raise_error(NotYetAvailableError)
      @game.submit_answer(:reader, "no")
      expect {@game.submit_answer(:reader, "I changed my mind, the answer is yes")}.
        to raise_error(NotYetAvailableError)
    end
  end

  describe "more_suspect_answer_is" do
    before do
      @game = Game.setup(@document1, 1, 2, 3)
      questioner = @game.is_questioner(:reader) ? :reader : :guesser
      @game.submit_question(questioner, "Who eats Great Whites?")
      @game.submit_answer(:guesser, "humans")
    end

    it "should raise a NotYetAvailableError if called before both answers have been submitted" do
      expect {@game.more_suspect_answer_is(:answer1)}.
        to raise_error(NotYetAvailableError)
    end
  
    it "after answers were submitted should allow to submit a judgement to the game" do
      @game.submit_answer(:reader, "Orcas")
      answers = @game.get_anonymized_answers
      suspect_answer = nil
      answers.each {|key, value| suspect_answer = key if value=="humans"}
      @game.more_suspect_answer_is(suspect_answer)
      expect(@game.new_round?).to be_truthy
    end

    it "should be possible to submit a new question after a judgement was made" do
      @game.submit_answer(:reader, "Orcas")
      answers = @game.get_anonymized_answers
      suspect_answer = nil
      answers.each {|key, value| suspect_answer = key if value=="humans"}
      @game.more_suspect_answer_is(suspect_answer)
      expect(@game.new_round?).to be_truthy
      expect(@game.question_available).to be_falsey
      questioner = @game.is_questioner(:reader) ? :reader : :guesser
      @game.submit_question(questioner, "How do orcas kill great whites?")
      expect(@game.question_available).to be_truthy
      expect(@game.get_question).to eq("How do orcas kill great whites?")
    end

    it "should end the game if judge failed thrice in a row" do
      @game.submit_answer(:reader, "Orcas")
      answers = @game.get_anonymized_answers
      suspect_answer = nil
      answers.each {|key, value| suspect_answer = key if value=="Orcas"}
      @game.more_suspect_answer_is(suspect_answer)
      ### round 1 ends
      questioner = @game.is_questioner(:reader) ? :reader : :guesser
      @game.submit_question(questioner, "How do orcas kill great whites?")
      @game.submit_answer(:guesser, "humans")
      @game.submit_answer(:reader, "Orcas")
      answers = @game.get_anonymized_answers
      suspect_answer = nil
      answers.each {|key, value| suspect_answer = key if value=="Orcas"}
      @game.more_suspect_answer_is(suspect_answer)
      ### round 2 ends
      questioner = @game.is_questioner(:reader) ? :reader : :guesser
      @game.submit_question(questioner, "How do orcas kill great whites?")
      @game.submit_answer(:guesser, "humans")
      @game.submit_answer(:reader, "Orcas")
      answers = @game.get_anonymized_answers
      suspect_answer = nil
      answers.each {|key, value| suspect_answer = key if value=="Orcas"}
      @game.more_suspect_answer_is(suspect_answer)
      ### game ends
      expect(@game.is_over).to be_truthy
    end
  end

  #################### OBSERVERS ####################

  describe "get_question" do
    before do
      @game = Game.setup(@document1, 1, 2, 3)
      @questioner = @game.is_questioner(:reader) ? :reader : :guesser
    end

    it "should raise NotYetAvailableError if called before a question is submitted this round" do
      expect {@game.get_question}.to raise_error(NotYetAvailableError)
    end

    it "should return the question if a question has already been submitted for this round" do
      @game.submit_question(@questioner, "?")
      expect(@game.get_question).to eq("?")
    end
  end

  describe "get_anonymized_answers" do
    before do
      @game = Game.setup(@document1, 1, 2, 3)
      @questioner = @game.is_questioner(:reader) ? :reader : :guesser
      @game.submit_question(@questioner, "is there any cake?")
      @game.submit_answer(:reader, "the cake is a lie")
    end

    it "should raise NotYetAvailableError if called before both answers were submitted" do
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

  describe "get_question" do
    before do
      @game = Game.setup(@document1, 1, 2, 3)
      @questioner = @game.is_questioner(:reader) ? :reader : :guesser
    end
    
    it "should raise NotYetAvailableError if question not yet submitted in this round" do
      expect {@game.get_question}.
        to raise_error(NotYetAvailableError)
    end
    
    it "should return the current question" do
      @game.submit_question(@questioner, "Who eats Great Whites?")
      expect(@game.get_question).
        to eq("Who eats Great Whites?")
    end
  end

  describe "question_available" do
    before do
      @game = Game.setup(@document1, 1, 2, 3)
      @questioner = @game.is_questioner(:reader) ? :reader : :guesser
    end

    it "should return false if there is no question yet for this round" do
      expect(@game.question_available).
        to eq(false)
    end
    it "should return true if there is a question for this round" do
      @game.submit_question(@questioner, "Is the text about whales?")
      expect(@game.question_available).to eq(true)
    end
  end

  describe "answers_available" do
    before do
      @game = Game.setup(@document1, 1, 2, 3)
      @questioner = @game.is_questioner(:reader) ? :reader : :guesser
      @game.submit_question(@questioner, "is the text about dolphins?")
      @game.submit_answer(:reader, "yes")
    end

    it "should return false if one or both answers are not yet available" do
      expect(@game.answers_available).to be_falsey
    end
    it "should return true if answer are available" do
      @game.submit_answer(:guesser, "yes")
      expect(@game.answers_available).to be_truthy
    end
  end

  describe "document_type" do
    it "should return the document type" do
      @game1 = Game.setup(@document1, 1, 2, 3)
      @game2 = Game.setup(@document3, 1, 2, 3)
      @game3 = Game.setup(@document2, 1, 2, 3)
      @game4 = Game.setup(@document4, 1, 2, 3)
      games = [@game1, @game2, @game3, @game4]
      document_types = [:text, :link, :embedded_youtube]
      games.each {|game| expect(document_types).to include(game.get_document_type)}
    end
  end

  describe "document_content" do
    before do
      @game1 = Game.setup(@document1, 1, 2, 3)
      @game2 = Game.setup(@document2, 1, 2, 3)
      @game3 = Game.setup(@document3, 1, 2, 3)
      @game4 = Game.setup(@document4, 1, 2, 3)
    end

    it "should return the text if the document is a text" do
      expect(@game1.document_content).
        to eq('GLaDOS is a sentient computer. She promisses cake, but the cake is a lie.')
    end

    it "should return the link if the document is a link" do
      expect(@game2.document_content).
        to eq('https://en.wikipedia.org/wiki/Aesop%27s_Fables')
    end

    it "should return the youtube link if document is embedded_youtube" do
      expect(@game3.document_content).
        to eq('https://www.youtube.com/embed/_qah8oIzCwk')
    end
  end

  describe "get_whiteboard_hashes" do
    it "should return a summary of the previous round" do
      @game = Game.setup(@document1, 1, 2, 3)
      questioner = @game.is_questioner(:reader) ? :reader : :guesser
      @game.submit_question(questioner, "Who eats Great Whites?")
      @game.submit_answer(:guesser, "humans")
      @game.submit_answer(:reader, "Orcas")
      answers = @game.get_anonymized_answers
      suspect_answer = nil
      answers.each {|key, value| suspect_answer = key if value=="humans"}
      @game.more_suspect_answer_is(suspect_answer)
      first_line = @game.get_whiteboard_hashes.first
      expect(first_line[:questioner]).to eq(questioner.to_s)
      expect(first_line[:question]).to eq("Who eats Great Whites?")
      expect(first_line[:reader_answer]).to eq("Orcas")
      expect(first_line[:guesser_answer]).to eq("humans")
      expect(first_line[:guesser_marked]).to be_truthy
      expect(first_line[:timestamp]).to be_present
    end
  end
end
