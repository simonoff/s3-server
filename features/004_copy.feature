@copy
Feature: Copy a S3 object

  Scenario: Copy a S3 object
    Given I upload a tiny file to /cucumber_bucket/cucumber_key/lorem.txt
    When I copy an existing object to /cucumber_bucket_copy/cucumber_key/lorem.txt
    Then I can verify the success of the upload
    Then I can verify the size
