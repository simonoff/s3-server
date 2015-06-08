@copy
Feature: Delete several S3 objects

  Scenario: Delete several S3 objects
    Given I upload a tiny file to /cucumber_bucket/cucumber_key/lorem_1.txt
    Given I upload a tiny file to /cucumber_bucket/cucumber_key/lorem_2.txt
    When I remove several existing objects "cucumber_key/lorem_1.txt|cucumber_key/lorem_2.txt" from bucket /cucumber_bucket
    Then I can verify the success of the deletion
