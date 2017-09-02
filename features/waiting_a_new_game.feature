Feature: User tries to join to a new game
  
  As a logged user
  So I want to start a new game
  I will be able to join a game when available

Background: user is log-in in
  Given the following users exist:
    | id | name     | email              | password | admin |
    | 1  | user-1    | user-1@team-read.org | foobar   | false |
    | 2  | user-2    | user-2@team-read.org | foobar   | false |
    | 3  | user-3    | user-3@team-read.org | foobar   | false |
  And the user "user-1" is log-in
  
  Scenario: Start New game and wait for players
    Given I am on the start new game page
    And I should see "Click below to join a new Game"
    When I follow "Start Game now!"
    And I am the only player in the queue
    Then I should be on waiting player page
  
  Scenario: Go to waiting page if user exist in queue
    Given the user "user-1" is waiting for players
    And I am on the start new game page
    Then I should be on waiting player page
  
  Scenario: Go to game page if user is playing on a game
    Given the user "user-1" exist on a game
    And I am on the start new game page
    And I am on waiting player page
    And I am on the game page for "sesaba23"
    Then I should see "Game started"