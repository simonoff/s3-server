@curl_upload
Feature: Upload a large file (multipart with cURL)

  Scenario: Upload a file (20 MB)
    When I upload a large file to /cucumber_bucket/cucumber_key/lorem.txt with curl
    Then I can verify the success of the upload
    Then I can verify the size
    Then I remove the object for the next test
