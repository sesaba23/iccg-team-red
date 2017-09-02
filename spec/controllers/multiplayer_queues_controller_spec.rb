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

    describe 'A player is waiting for start a new game' do
        before (:each) do
            @multiplayerqueue = FactoryGirl.build(:multiplayerQueue , :id => 1)
            @multiplayerqueue.enqueue_player(1)    
        end
        it 'he wants to quit of waiting process' do
            get :quit, params: { id: 1}
            @multiplayerqueue.delete_user_from_queue(1)
            expect(QueuedPlayer.find_by_user_id(1)).to be_falsey
        end
    end
end