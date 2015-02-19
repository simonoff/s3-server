module CleanerManager
  extend ActiveSupport::Concern

  included do
    after_action :remove_empty_directories, only: :destroy
    after_action :remove_tmp
  end

  def remove_tmp
    suppress(Errno::ENOENT) do
      FileUtils.rm_r(File.join '.', 'public', 'tmp')
    end
  end

  def remove_empty_directories
    until (empty_dirs = find_empty_directories).empty?
      empty_dirs.each { |d| Dir.rmdir d }
    end
  end

  def find_empty_directories
    Dir["#{Rails.application.secrets[:storage][:base_dir]}/**/*"]
      .select { |d| File.directory? d }
      .select { |d| (Dir.entries(d) - %w(. ..)).empty? }
  end
end
