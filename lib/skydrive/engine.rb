module Skydrive
  class Engine < ::Rails::Engine
    config.autoload_paths << File.expand_path('../../', __FILE__)

    isolate_namespace Skydrive

    initializer :append_migrations do |app|
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
