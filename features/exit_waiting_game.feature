Feature: User wants to quit the game while he is waiting for other players
  
  As a logged user
  I am waiting other users to start a new game
  So I can quit the waiting game 

Background: user is waiting for other players to play a game
  Given the following users exist:
    | id | name     | email              | password | admin |
    | 1  | user-1    | user-1@team-read.org | foobar   | false |
    | 2  | user-2    | user-2@team-read.org | foobar   | false |
    | 3  | user-3    | user-3@team-read.org | foobar   | false |
  And the user "user-1" is log-in
  And I am on the start new game page
  When I follow "Start Game now!"
  
  Scenario: Quit waiting game and go to home page
    Given I should be on waiting player page
    And I follow "Quit Game" 
    Then I should be on the start new game page
    And I should see "user-1"
    