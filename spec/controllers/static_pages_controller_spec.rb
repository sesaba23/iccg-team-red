require 'rails_helper'

describe StaticPagesController do
    render_views
    describe 'Should get the given web page' do
        it 'selects the home template for rendering' do
             get :home
        end
        it 'selects the help template for rendering' do
            get :help
       end
       it 'selects the about template for rendering' do
            get :about
       end
       it 'selects the contact template for rendering' do
        get :contact
   end
    end
end