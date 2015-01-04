module S3Client
  class << self
    attr_accessor :s3_params, :actual_size, :expected_size, :file_exist,
      :previous_scenario_key
  end
end
