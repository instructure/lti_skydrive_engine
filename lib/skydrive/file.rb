require 'mimemagic'

module Skydrive
  class File
    attr_accessor :uri, :file_size, :name, :server_relative_url, :time_created, :time_last_modified, :title, :content_tag,
                  :content_type, :is_image, :is_text, :is_video, :mime_comment, :icon, :kind, :suffix, :is_embeddable,
                  :homework_submission_url

    def update_content_type_data(allowed_extensions=nil)
      self.is_embeddable = true
      mm = MimeMagic.by_path(self.name)
      if mm
        if mm.image?
          case mm.to_s
            when 'image/png'
              self.icon = "png"
            when 'image/jpeg'
              self.icon = "jpg"
            else
              self.icon = "jpg"
          end
        elsif mm.text? || mm.subtype == "msword"
          if mm.extensions & ['doc', 'docx']
            self.icon = "word"
          else
            self.icon = "file"
          end
        elsif mm.to_s == 'application/pdf'
          self.icon = "pdf"
        else
          self.icon = "file"
        end
        self.kind = mm.comment
        self.suffix = mm.extensions.last

        if allowed_extensions.blank? || (allowed_extensions & mm.extensions).size > 0
          self.is_embeddable = true
        else
          self.is_embeddable = false
        end
      else
        self.icon = "file"
        self.kind = ''
        self.suffix = self.name.split('.').try(:last) || ''
        self.is_embeddable = false
      end
    end
  end
end
