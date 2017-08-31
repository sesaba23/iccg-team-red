Feature: User tries to join to a new game
  
  As a logged user
  So I want to start a new game
  I will be able to join a game when available

Background: user is log-in in
  Given the following users exist:
    | name     | email              | password | admin |
    | user1    | user@team-read.org | foobar   | false |
  And the user "user1" is log-in
  
  Scenario: Start New game
    Given I am on the start new game page
    When I follow "Search Players"
    Then I should be on waiting player page
  
  Scenario: Go to waiting page if user exist in queue
    Given the user "sesaba23" is waiting for players
    And I am on the start new game page
    Then I should be on waiting player page
  
  Scenario: Go to game page if user is playing on a game
    Given the user "sesaba23" exist on a game
    And I am on the start new game page
    And I am on waiting player page
    And I am on the game page for "sesaba23"
    Then I should see "Game started"