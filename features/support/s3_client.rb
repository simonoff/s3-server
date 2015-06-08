module S3Client
  class << self
    Thread.abort_on_exception = true
    attr_reader :threads

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

    def <<(thread)
      @threads ||= []
      @threads << thread
    end

    def find_new_completed_job
      @new_completed_job ||= []
      @threads.each do |t|
        if t[:completed]
          @new_completed_job << t
          return t
        end
      end
      nil
    end

    def wait_threads
      @threads.each(&:join)
    end
  end

  class Client
    attr_accessor :s3_params, :expected_size, :actual_size,
                  :file_exist, :previous_scenario_key, :error
  end
end
