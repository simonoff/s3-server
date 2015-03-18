require 'dante'
require 'carrierwave'
require 'carrierwave/orm/activerecord'

require File.expand_path('../../../config/application', __FILE__)
APP_PATH = File.expand_path('../../../config/application',  __FILE__)
require File.expand_path('../../../config/boot', __FILE__)
ARGV = ['-p', '10001', 'webrick']
require 'rack/handler'

module S3Server
  module Server
    def self.start
      init
      ::Dante::Runner.new('s3-server')
        .execute(daemonize: true, pid_path: @s3_pid, log_path: @s3_log) do |opts|
        # Restore ARGV values deleted by Dante
        ARGV.insert(0, opts[:port].to_s)
        ARGV.insert(0, '-p')
        require 'rails/commands/commands_tasks'
        Rails::CommandsTasks.new(ARGV).run_command!('server')
      end
    end

    def self.stop
      Dante::Runner.new('s3-server').execute(kill: true, pid_path: @s3_pid)
    end

    private

    def self.init
      Rails.application.load_tasks
      Rake::Task['db:migrate'].invoke

      id = Time.now.utc.strftime('%Y%m%d%H%M%S')
      @s3_pid = "/tmp/s3-server-#{id}.pid"
      @s3_log = "/tmp/s3-server-#{id}.log"
    end
  end
end
