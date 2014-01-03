module Skydrive
  class Folder
    attr_accessor :uri, :parent_uri, :name, :server_relative_url, :files, :folders, :icon

    def parse_parent_uri
      if self.uri && self.server_relative_url.split('/').count > 4
        self.parent_uri = { uri: self.uri.split(/\//)[0...-1].join('/') + "')" }
      else
        self.parent_uri = nil
      end
    end
  end
end