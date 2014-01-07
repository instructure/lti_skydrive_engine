module Skydrive
  class File
    attr_accessor :uri, :file_size, :name, :server_relative_url, :time_created, :time_last_modified, :title, :content_tag,
                  :content_type, :is_image, :is_text, :is_video, :mime_comment, :icon, :kind, :suffix, :is_embeddable,
                  :homework_submission_url, :mounted_path

    def direct_url
      "BLAH BLAH BLAH"
    end

    def update_content_type_data(allowed_extensions=nil)
      self.is_embeddable = true
      mm = MimeMagic.by_path(self.name)
      if mm
        if mm.image?
          case mm.to_s
            when 'image/png'
              self.icon = "/#{mounted_path}/images/icon-png.png"
            when 'image/jpeg'
              self.icon = "/#{mounted_path}/images/icon-jpg.png"
            else
              self.icon = "/#{mounted_path}/images/icon-jpg.png"
          end
        elsif mm.text?
          if mm.extensions & ['doc', 'docx']
            self.icon = "/#{mounted_path}/images/icon-word.png"
          else
            self.icon = "/#{mounted_path}/images/icon-file.png"
          end
        elsif mm.to_s == 'application/pdf'
          self.icon = "/#{mounted_path}/images/icon-pdf.png"
        else
          self.icon = "/#{mounted_path}/images/icon-file.png"
        end
        self.kind = mm.comment
        self.suffix = mm.extensions.last

        if !allowed_extensions || (allowed_extensions & mm.extensions).size > 0
          self.is_embeddable = true
        else
          self.is_embeddable = false
        end
      else
        self.icon = "/#{mounted_path}/images/icon-file.png"
        self.kind = ''
        self.suffix = self.name.split('.').try(:last) || ''
        self.is_embeddable = false
      end
    end
  end
end
