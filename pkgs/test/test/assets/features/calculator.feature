Feature: Test Calculator
  Scenario: Test sum
    Given I have a Calculator
    When I add 1 and 1
    Then the result should be 2