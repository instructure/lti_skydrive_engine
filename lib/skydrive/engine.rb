module Skydrive
  class Engine < ::Rails::Engine
    OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ssl_version] = 'SSLv3'
    config.autoload_paths << File.expand_path('../../', __FILE__)

    isolate_namespace Skydrive

    initializer :static_assets do |app|
      app.middleware.insert_before ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
    end

    initializer :append_migrations do |app|
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
