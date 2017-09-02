require 'rails_helper'

describe MultiplayerQueuesController do
    describe 'A player wants to play a new game' do
        it 'The player is the only one in the queue' do
             get :enqueue, params: { id: 1}
             get :enqueue, params: { id: 2}
             multiplayerqueue = FactoryGirl.build(:multiplayerQueue , :id => 1)
             expect(QueuedPlayer.all.size).to eq 1
                
        end
    end
end