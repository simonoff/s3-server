When(/^I upload a (\S+) file to \/(\S+)$/) do |size, uri|
  FileGenerator.with_lorem_file(convert_size(size)) do |file|
    S3Client[:source].s3_params = S3Manager.parse_s3_params(uri)
    S3Client[:source].expected_size = file.size

    S3Manager[:source].upload(file)

    S3Client[:source].actual_size = S3Manager[:source].object_size
  end
end

When(/^I upload a (\S+) file to \/(\S+) with curl$/) do |size, uri|
  FileGenerator.with_lorem_file(convert_size(size)) do |file|
    S3Client[:source].s3_params = S3Manager.parse_s3_params(uri)
    S3Client[:source].expected_size = file.size

    `curl -s -X POST -i http://localhost:10001/#{S3Client[:source].s3_params[0]} \
      -F "Content-Type=multipart/form-data" \
      -F "key=#{S3Client[:source].s3_params[1]}" \
      -F "success_action_status=201" \
      -F "file=@#{file.path}"`

    S3Client[:source].actual_size = S3Manager[:source].object_size
  end
end

When(/^I download a file from \/(\S+)$/) do |uri|
  FileGenerator.with_empty_file do |file|
    S3Client[:source].s3_params = S3Manager.parse_s3_params(uri)
    S3Client[:source].expected_size = S3Manager[:source].object_size

    S3Manager[:source].download(file)

    S3Client[:source].file_exist = File.exist?(file.path)
    S3Client[:source].actual_size = file.size
  end
end

When(/^I copy an existing object to \/(\S+)$/) do |uri|
  # src (Given clause)
  S3Client[:destination].expected_size = S3Manager[:source].object_size

  # dst (When clause)
  S3Client[:destination].s3_params = S3Manager.parse_s3_params(uri)

  S3Manager[:destination].copy(S3Client[:source].s3_params)

  S3Client[:destination].actual_size = S3Manager[:destination].object_size
end

Then(/^I can verify the success of the upload$/) do
  expect(S3Manager[:source].object_exists?).to be true
end

Then(/^I can verify the success of the copy$/) do
  expect(S3Manager[:source].object_exists?).to be true
  expect(S3Manager[:destination].object_exists?).to be true
end

Then(/^I can verify the success of the download$/) do
  expect(S3Client[:source].file_exist).to be true
end

Then(/^I can verify the size$/) do
  S3Client.each_client do |id|
    expect(S3Client[id].actual_size).to eq(S3Client[id].expected_size)
  end
end

Then(/^I remove the object\(s\) for the next test$/) do
  S3Client.each_client do |id|
    S3Manager[id].delete_object
  end
  S3Client.wipe
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
