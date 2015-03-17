module S3Server
  class Engine < ::Rails::Engine
    isolate_namespace S3Server

    config.autoload_paths += %W(#{config.root}/lib/)
    config.autoload_paths += %W(#{config.root}/lib/modules)
  end
end
