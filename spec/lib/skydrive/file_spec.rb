require 'spec_helper'

describe Skydrive::File do
  describe "#update_content_type_data" do
    before(:each) do
      @file = Skydrive::File.new
    end

    it "when png (and allowed extensions)" do
      @file.name = "test.png"
      @file.update_content_type_data(['doc'])
      @file.icon.should eq("png")
      @file.kind.should eq("PNG image")
      @file.suffix.should eq("png")
      expect(@file.is_embeddable).to be false
    end

    it "when jpg" do
      @file.name = "test.jpg"
      @file.update_content_type_data
      @file.icon.should eq("jpg")
      @file.kind.should eq("JPEG image")
      @file.suffix.should eq("jpg")
      expect(@file.is_embeddable).to be true
    end

    it "when bmp" do
      @file.name = "test.bmp"
      @file.update_content_type_data
      @file.icon.should eq("jpg")
      @file.kind.should eq("Windows BMP image")
      @file.suffix.should eq("bmp")
      expect(@file.is_embeddable).to be true
    end

    it "when doc" do
      @file.name = "test.doc"
      @file.update_content_type_data
      @file.icon.should eq("word")
      @file.kind.should eq("Word document")
      @file.suffix.should eq("doc")
      expect(@file.is_embeddable).to be true
    end

    it "when pdf" do
      @file.name = "test.pdf"
      @file.update_content_type_data
      @file.icon.should eq("pdf")
      @file.kind.should eq("PDF document")
      @file.suffix.should eq("pdf")
      expect(@file.is_embeddable).to be true
    end

    it "when unknown" do
      @file.name = "test.unknown"
      @file.update_content_type_data
      @file.icon.should eq("file")
      @file.kind.should eq("")
      @file.suffix.should eq("unknown")
      expect(@file.is_embeddable).to be false
    end
  end
end
