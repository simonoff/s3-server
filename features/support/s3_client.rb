module S3Client
  class << self
    def [](key)
      @clients ||= {}
      @clients[key] ||= Client.new
    end

    def each_client
      @clients.keys.each do |client_id|
        yield client_id
      end
    end

    def wipe
      @clients.clear
    end
  end

  class Client
    attr_accessor :s3_params, :expected_size, :actual_size,
                  :file_exist, :previous_scenario_key
  end
end
