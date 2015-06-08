@stress_test
Feature: Stress test

  # Run this test with the folowing commands:
  # - bundle exec rails s -p 10001
  # - bundle exec puma -t 2:10 -p 10001
  Scenario: Stess test
    When I upload several files in parallel
    Then I can make several copies during uploads
    Then I can wait the end of parallel processes
    Then I can verify the size
    Then I remove the object(s) for the next test
