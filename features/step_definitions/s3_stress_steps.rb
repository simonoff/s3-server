When(/^I upload several files in parallel$/) do
  20.times do
    S3Client << Thread.new do
      sleep rand(4)

      id = "id_#{SecureRandom.hex}".to_sym
      size = rand(100) + 1
      uri = "#{rand(10)}/up_#{id}/lorem.txt"

      Thread.current[:id] = id
      FileGenerator.with_lorem_file(size) do |file|
        S3Client[id].s3_params = S3Manager.parse_s3_params(uri)
        S3Client[id].expected_size = file.size

        S3Manager[id].upload(file)

        S3Client[id].actual_size = S3Manager[id].object_size
        Thread.current[:completed] = true
      end
    end
  end
end

Then(/^I can make several copies during uploads$/) do
  copied_objects = []
  while copied_objects.length < 10
    if (t = S3Client.find_new_completed_job)
      copied_objects << t[:id]
      perform_async_copy(t[:id])
    end
    sleep 1
  end
end

Then(/^I can wait the end of parallel processes$/) do
  S3Client.wait_threads
end

def perform_async_copy(src_id)
  dest_id = "id_#{SecureRandom.hex}".to_sym
  uri = "#{rand(10)}/cp_#{dest_id}/lorem.txt"

  S3Client[dest_id].expected_size = S3Manager[src_id].object_size
  S3Client[dest_id].s3_params = S3Manager.parse_s3_params(uri)
  S3Manager[dest_id].copy(S3Client[src_id].s3_params)
  S3Client[dest_id].actual_size = S3Manager[dest_id].object_size
end
