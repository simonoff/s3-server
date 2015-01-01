When(/^I upload a tiny file to \/(\S+)$/) do |uri|
  FileGenerator.with_lorem_file do |file|
    S3Client.s3_params = S3Manager.parse_s3_params(uri)
    S3Client.expected_size = file.size

    S3Manager.upload(file)

    S3Client.actual_size = S3Manager.object_size
  end
end

When(/^I download a file from \/(\S+)$/) do |uri|
  FileGenerator.with_empty_file do |file|
    S3Client.s3_params = S3Manager.parse_s3_params(uri)
    S3Client.expected_size = S3Manager.object_size

    S3Manager.download(file)

    S3Client.file_exist = File.exist?(file.path)
    S3Client.actual_size = file.size
  end
end

Then(/^I can verify the success of the upload$/) do
  expect(S3Manager.object_exists?).to be true
end

Then(/^I can verify the success of the download$/) do
  expect(S3Client.file_exist).to be true
end

Then(/^I can verify the size$/) do
  expect(S3Client.actual_size).to eq(S3Client.expected_size)
end

def save_s3_params(bucket, key)
  S3Client.s3_params = [bucket, key]
end

def save_content_legnth(length)
  S3Client.content_length = length
end
