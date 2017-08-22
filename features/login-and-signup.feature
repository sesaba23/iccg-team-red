Feature: User Sign-up and login

  As a user who wants to play iccg
  I want to sign-up as a new user in the platform
  and will be able to log-in before start playing

  Scenario: Sign-up as a user
    Given I am on the home page
    Then I should see "Welcome to the iccg game web"
    And I should see "sign-up"
    When I click on "sign-up" link
    Then I should go to the sign-up page