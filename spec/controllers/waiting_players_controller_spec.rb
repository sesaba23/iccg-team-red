require 'rails_helper'

describe WaitingPlayersController do
    describe 'Should get the given web page' do
        it 'selects the waiting for players template for rendering' do
             get :waiting
        end
    end
end