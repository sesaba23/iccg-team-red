require 'rails_helper.rb'

describe "Players", :type => :feature do
  before :each do
    @text = "Orcas are the largest type of dolphin. They are appex predators. There prey includes fish including the great white shark, other whales and sealions."
    @document = FactoryGirl.create(:document, :id => 1, :doc_type => 'text',
                                   :text => @text)
    @game = Game.setup(@document, 1, 2, 3)
    @reader = @game.reader
    @guesser = @game.guesser
    @judge = @game.judge
  end

  it "should land on the correct page at the start of the game" do
    visit(waiting_for_question_game_reader_path(@game.id, @reader.id))
    if @reader.is_questioner?
      expect(page).to have_current_path(ask_game_reader_path(@game.id, @reader.id))
    else
      expect(page).
        to have_current_path(waiting_for_question_game_reader_path(@game.id, @reader.id))
    end
  end

  it "should be able to submit a question and get to the answer page" do
  end

  it "should be able to submit answers and get to the review page" do
  end

  it "should be able to submit judgements and land at the start of the new round" do
  end

  it "should be able to see the summary of the last round on the whiteboard" do
  end

  it "should be able to see their scores" do
  end
end
