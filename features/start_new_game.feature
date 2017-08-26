Feature: User starts a new game
  
  As a logged user
  So that I can start a new game
  I want to join a waiting queue

Background: user is loggedin
  Given the following users exist:
    | name     | email              |
    | sesaba23 | sesaba23@gmail.com |
  And the user "sesaba23" is loggedin
  And I am on the start new game page
  
  Scenario: Start New game
    When I follow "New Game"
    Then I should be on waiting player page
  
  Scenario: Go to waiting page if user exist in queue
    Given the user "sesaba23" is waiting for players
    Then I should be on waiting player page