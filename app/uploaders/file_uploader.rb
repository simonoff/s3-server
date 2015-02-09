class FileUploader < CarrierWave::Uploader::Base
  attr_writer :filename

  storage :file

  def store_dir
    base_dir = Rails.application.secrets[:storage][:base_dir]

    key_prefix = model.key.split('/')
    if key_prefix.length > 1
      Rails.root.join(base_dir, model.bucket.name, *key_prefix[0..-2])
    else
      Rails.root.join(base_dir, model.bucket.name)
    end
  end

  def cache_dir
    File.join('tmp', 'uploads')
  end
end
