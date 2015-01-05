@download
Feature: Download a file

  Scenario: Download a file
    Given I upload a tiny file to /cucumber_bucket/cucumber_key/lorem.txt
    When I download a file from /cucumber_bucket/cucumber_key/lorem.txt
    Then I can verify the success of the download
    Then I can verify the size
    Then I remove the object for the next test
