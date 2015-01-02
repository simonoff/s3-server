@multipart_upload
Feature: Upload a large file (multipart)

  Scenario: Upload a file (20 MB)
    When I upload a large file to /cucumber_bucket/cucumber_key/lorem.txt
    Then I can verify the success of the upload
    Then I can verify the size
