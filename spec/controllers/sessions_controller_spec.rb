require 'rails_helper'

describe SessionsController do
    
    describe 'Should get the log-in web page' do
        it 'should get new' do
             expect(get: login_path).to route_to(controller: "sessions", action: "new")
        end
        
    end
end