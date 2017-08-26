Feature: User starts a new game
  
  As a logged user
  So that I can start a new game
  I want to join a waiting queue

Background: user is logged in
  
  Scenario: Start New game
    Given I am on the start new game page
    When I follow "New Game"
    Then I should be on waiting player page