require 'rails_helper'

describe "Players" do
  before do
    text = "Orcas are the largest type of dolphin. They are appex predators. There prey includes fish including the great white shark, other whales and sealions."
    @document = FactoryGirl.create(:document, :id => 1, :doc_type => 'text',
                                   :text => text)
    @game = Game.setup(@document, 1, 2, 3)
    @reader = @game.reader
    @guesser = @game.guesser
    @judge = @game.judge
  end

  it "should be able to determine who is questioner and ask a question" do
    expect(@reader.question_available?).to be_falsey
    expect(@guesser.question_available?).to be_falsey
    expect(@judge.question_available?).to be_falsey
    if @reader.is_questioner?
      @reader.submit_question("What superlative is involved?")
    elsif @guesser.is_questioner?
      @guesser.submit_question("What's the document about?")
    end
    if @game.is_questioner(:reader)
      expect(@game.get_question).to eq("What superlative is involved?")
    else
      expect(@game.get_question).to eq("What's the document about?")
    end
  end

  it "should be able to determine what the question was and give answers" do
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    @game.submit_question(questioner, "What superlative is involved?")
    
    expect(@reader.question_available?).to be_truthy
    expect(@guesser.question_available?).to be_truthy
    expect(@judge.question_available?).to be_truthy
    expect(@reader.get_question).to eq(@game.get_question)
    expect(@guesser.get_question).to eq(@game.get_question)
    expect(@judge.get_question).to eq(@game.get_question)
    @reader.submit_answer("being the largest")
    @guesser.submit_answer("winning bigly")
    expect(@reader.get_guessers_answer).to eq("winning bigly")
    expect(@reader.get_readers_answer).to eq("being the largest")
    expect(@guesser.get_guessers_answer).to eq("winning bigly")
    expect(@guesser.get_readers_answer).to eq("being the largest")
  end

  it "should not be able to get another's answer before they submit their own" do
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    @game.submit_question(questioner, "What superlative is involved?")
    @reader.submit_answer("being the largest")
    expect(@guesser.get_readers_answer).to be_falsey
  end

  it "should not be able to get another's answer before they submit their own" do
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    @game.submit_question(questioner, "What superlative is involved?")
    @guesser.submit_answer("being the largest")
    expect(@reader.get_guessers_answer).to be_falsey
  end

  it "should be able to get their own answer before the other player submits theirs" do
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    @game.submit_question(questioner, "What superlative is involved?")
    @guesser.submit_answer("being the largest")
    expect(@guesser.get_guessers_answer).to eq("being the largest")
  end

  it "should be able to get their own answer before the other player submits theirs" do
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    @game.submit_question(questioner, "What superlative is involved?")
    @reader.submit_answer("being the largest")
    expect(@reader.get_readers_answer).to eq("being the largest")
  end

  it "should be able to see that both answers are available" do
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    @game.submit_question(questioner, "What superlative is involved?")
    @game.submit_answer(:reader, "being the largest")
    @game.submit_answer(:guesser, "winning bigly")
    expect(@judge.answers_available?).to be_truthy
    expect(@guesser.answers_available?).to be_truthy
    expect(@reader.answers_available?).to be_truthy
  end

  it "should be able to get anonymized answers once both answers are available" do
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    @game.submit_question(questioner, "What superlative is involved?")
    @game.submit_answer(:reader, "being the largest")
    @game.submit_answer(:guesser, "winning bigly")
    answers = @judge.get_answers
    [:answer1, :answer2].each {|key| expect(answers.has_key?(key)).to be_truthy}
    ["being the largest", "winning bigly"].each {|val| expect(answers.has_value?(val)).
                                                   to be_truthy}
  end

  it "should be in a new round after a judgement is made" do
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    @game.submit_question(questioner, "What superlative is involved?")
    @game.submit_answer(:reader, "being the largest")
    @game.submit_answer(:guesser, "winning bigly")
    @judge.first_answer_suspicious
    expect(@game.new_round?).to be_truthy
    expect(@reader.new_round?).to be_truthy
    expect(@guesser.new_round?).to be_truthy
    expect(@judge.new_round?).to be_truthy
  end

  it "should be able to see a correct judgement on the whiteboard" do
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    @game.submit_question(questioner, "What superlative is involved?")
    @game.submit_answer(:reader, "being the largest")
    @game.submit_answer(:guesser, "winning bigly")
    answers = @judge.get_answers
    incorrect_answer = nil
    answers.each {|key, value| incorrect_answer = key if value=="winning bigly"}
    @judge.more_suspect_is(incorrect_answer)
    lines = @judge.get_whiteboard_hashes
    expect(lines.first[:guesser_marked]).to be_truthy
    lines = @reader.get_whiteboard_hashes
    expect(lines.first[:guesser_marked]).to be_truthy
    lines = @guesser.get_whiteboard_hashes
    expect(lines.first[:guesser_marked]).to be_truthy
  end

  it "should be able to see an incorrect judgement on the whiteboard" do
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    @game.submit_question(questioner, "What superlative is involved?")
    @game.submit_answer(:reader, "being the largest")
    @game.submit_answer(:guesser, "winning bigly")
    answers = @judge.get_answers
    incorrect_answer = nil
    answers.each {|key, value| incorrect_answer = key if value=="being the largest"}
    @judge.more_suspect_is(incorrect_answer)
    lines = @judge.get_whiteboard_hashes
    expect(lines.first[:guesser_marked]).to be_falsey
    lines = @reader.get_whiteboard_hashes
    expect(lines.first[:guesser_marked]).to be_falsey
    lines = @guesser.get_whiteboard_hashes
    expect(lines.first[:guesser_marked]).to be_falsey
  end

  it "should be able to get their intial scores" do
    scores = @reader.get_scores
    scores.each {|key, value| expect(value).to eq(0)}
    scores = @judge.get_scores
    scores.each {|key, value| expect(value).to eq(0)}
    scores = @guesser.get_scores
    scores.each {|key, value| expect(value).to eq(0)}
  end

  it "should be able to get correct scores after one round if the judgement is correct" do
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    if questioner == :reader
      @reader.submit_question("What superlative is involved?")
    else
      @guesser.submit_question("What superlative is involved?")
    end
    @reader.submit_answer("being the largest")
    @guesser.submit_answer("winning bigly")
    answers = @judge.get_answers
    incorrect_answer = nil
    answers.each {|key, value| incorrect_answer = key if value=="winning bigly"}
    @judge.more_suspect_is(incorrect_answer)
    scores = @judge.get_scores
    expect(scores[:reader]).to eq(1)
    expect(scores[:guesser]).to eq(0)
    expect(scores[:judge]).to eq(1)
  end

  it "should be able to get correct scores after one round if the judgment is incorrect" do
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    if questioner == :reader
      @reader.submit_question("What superlative is involved?")
    else
      @guesser.submit_question("What superlative is involved?")
    end
    @reader.submit_answer("being the largest")
    @guesser.submit_answer("winning bigly")
    answers = @judge.get_answers
    incorrect_answer = nil
    answers.each {|key, value| incorrect_answer = key if value=="being the largest"}
    @judge.more_suspect_is(incorrect_answer)
    scores = @guesser.get_scores
    expect(scores[:reader]).to eq(0)
    expect(scores[:guesser]).to eq(1)
    expect(scores[:judge]).to eq(0)
  end

  it "should be able to see that the game is over after three consecutive incorrect judgements" do
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    if questioner == :reader
      @reader.submit_question("What superlative is involved?")
    else
      @guesser.submit_question("What superlative is involved?")
    end
    @reader.submit_answer("being the largest")
    @guesser.submit_answer("winning bigly")
    answers = @judge.get_answers
    incorrect_answer = nil
    answers.each {|key, value| incorrect_answer = key if value=="being the largest"}
    @judge.more_suspect_is(incorrect_answer)
    # round 1 ends
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    if questioner == :reader
      @reader.submit_question("Who is the largest?")
    else
      @guesser.submit_question("Who is the largest?")
    end
    @reader.submit_answer("a whale")
    @guesser.submit_answer("a dolphin")
    answers = @judge.get_answers
    incorrect_answer = nil
    answers.each {|key, value| incorrect_answer = key if value=="a whale"}
    @judge.more_suspect_is(incorrect_answer)
    #round 2 ends
    
    expect(@judge.is_game_over).to be_falsey
    expect(@reader.is_game_over).to be_falsey
    expect(@guesser.is_game_over).to be_falsey
    
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    if questioner == :reader
      @reader.submit_question("What type of dolphin?")
    else
      @guesser.submit_question("What type of dolphin?")
    end
    @reader.submit_answer("orca")
    @guesser.submit_answer("Orca")
    answers = @judge.get_answers
    incorrect_answer = nil
    answers.each {|key, value| incorrect_answer = key if value=="orca"}
    @judge.more_suspect_is(incorrect_answer)
    #game ends
    expect(@judge.is_game_over).to be_truthy
    expect(@reader.is_game_over).to be_truthy
    expect(@guesser.is_game_over).to be_truthy
  end

  it "should be able to retrieve their correct final scores after the game has concluded" do
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    if questioner == :reader
      @reader.submit_question("What superlative is involved?")
    else
      @guesser.submit_question("What superlative is involved?")
    end
    @reader.submit_answer("being the largest")
    @guesser.submit_answer("winning bigly")
    answers = @judge.get_answers
    incorrect_answer = nil
    answers.each {|key, value| incorrect_answer = key if value=="being the largest"}
    @judge.more_suspect_is(incorrect_answer)
    # round 1 ends
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    if questioner == :reader
      @reader.submit_question("Who is the largest?")
    else
      @guesser.submit_question("Who is the largest?")
    end
    @reader.submit_answer("a whale")
    @guesser.submit_answer("a dolphin")
    answers = @judge.get_answers
    incorrect_answer = nil
    answers.each {|key, value| incorrect_answer = key if value=="a whale"}
    @judge.more_suspect_is(incorrect_answer)
    #round 2 ends    
    questioner = @game.is_questioner(:reader) ? :reader : :guesser
    if questioner == :reader
      @reader.submit_question("What type of dolphin?")
    else
      @guesser.submit_question("What type of dolphin?")
    end
    @reader.submit_answer("orca")
    @guesser.submit_answer("Orca")
    answers = @judge.get_answers
    incorrect_answer = nil
    answers.each {|key, value| incorrect_answer = key if value=="orca"}
    @judge.more_suspect_is(incorrect_answer)
    #game ends

    scores = @guesser.get_scores
    expect(scores[:guesser]).to eq(3)
    expect(scores[:reader]).to eq(0)
    expect(scores[:judge]).to eq(0)
  end
end
