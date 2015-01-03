When(/^I upload a (\S+) file to \/(\S+)$/) do |size, uri|
  FileGenerator.with_lorem_file(convert_size(size)) do |file|
    S3Client.s3_params = S3Manager.parse_s3_params(uri)
    S3Client.expected_size = file.size

    S3Manager.upload(file)

    S3Client.actual_size = S3Manager.object_size
  end
end

When(/^I upload a (\S+) file to \/(\S+) with curl$/) do |size, uri|
  FileGenerator.with_lorem_file(convert_size(size)) do |file|
    S3Client.s3_params = S3Manager.parse_s3_params(uri)
    S3Client.expected_size = file.size

    `curl -s -X POST \
      -F "Content-Type=multipart/form-data" \
      -F "key=#{S3Client.s3_params[1]}" \
      -F "success_action_status=201" \
      -F "file=@#{file.path}" \
      -i http://localhost:3000/#{S3Client.s3_params[0]}`

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

When(/^I copy an existing object to \/(\S+)$/) do |uri|
  # src (Given clause)
  src_s3_params = S3Client.s3_params
  S3Client.expected_size = S3Manager.object_size

  # dst (When clause)
  S3Client.s3_params = S3Manager.parse_s3_params(uri)

  S3Manager.copy(src_s3_params)

  S3Client.actual_size = S3Manager.object_size
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

def convert_size(size)
  case size
  when 'tiny'
    1
  when 'large'
    20
  else
    fail 'Invalid size parameter'
  end
end
