@upload
Feature: Upload a tiny file (singlepart)

  Scenario: Upload a file (1 MB)
    When I upload a tiny file to /cucumber_bucket/cucumber_key/lorem.txt
    Then I can verify the success of the upload
    Then I can verify the size
    Then I remove the object for the next test
