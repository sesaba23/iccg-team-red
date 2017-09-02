FactoryGirl.define do
    factory :multiplayerQueue do
        #default values
        id 1
        player1 1
        player2 2
        player3 3
        created false
        players_processed 0
        game_id 1
        created_at {10.years.ago}
        updated_at {1.years.ago}
    end
end