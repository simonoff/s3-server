require 'securerandom'
require 'tempfile'

class FileGenerator
  ONE_MEGABYTE = 2**20

  class << self
    def with_empty_file(size_in_mb = 1)
      file = Tempfile.new('empty_file.raw')
      file.binmode

      yield file
    ensure
      file.close # Also delete file
    end

    def with_random_file(size_in_mb = 1)
      file = Tempfile.new('random_size_generated_file.raw')
      file.binmode

      size_in_mb.times { file << SecureRandom.random_bytes(ONE_MEGABYTE) }

      yield file
    ensure
      file.close # Also delete file
    end

    def with_lorem_file(size_in_mb = 1)
      lorem = Faker::Lorem.characters(ONE_MEGABYTE)
      file = Tempfile.new('random_size_generated_lorem_file.raw')
      file.binmode

      size_in_mb.times { file << lorem }

      yield file
    ensure
      suppress(NoMethodError) do
        file.close # Also delete file
      end
    end
  end
end
