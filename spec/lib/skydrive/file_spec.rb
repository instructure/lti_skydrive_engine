require 'spec_helper'

describe Skydrive::File do
  describe "#update_content_type_data" do
    before(:each) do
      @file = Skydrive::File.new
    end

    it "when png (and allowed extensions)" do
      @file.name = "test.png"
      @file.update_content_type_data(['doc'])
      @file.icon.should eq("/skydrive/images/icon-png.png")
      @file.kind.should eq("PNG image")
      @file.suffix.should eq("png")
      @file.is_embeddable.should be_false
    end

    it "when jpg" do
      @file.name = "test.jpg"
      @file.update_content_type_data
      @file.icon.should eq("/skydrive/images/icon-jpg.png")
      @file.kind.should eq("JPEG image")
      @file.suffix.should eq("jpg")
      @file.is_embeddable.should be_true
    end

    it "when bmp" do
      @file.name = "test.bmp"
      @file.update_content_type_data
      @file.icon.should eq("/skydrive/images/icon-jpg.png")
      @file.kind.should eq("Windows BMP image")
      @file.suffix.should eq("bmp")
      @file.is_embeddable.should be_true
    end

    it "when doc" do
      @file.name = "test.doc"
      @file.update_content_type_data
      @file.icon.should eq("/skydrive/images/icon-word.png")
      @file.kind.should eq("Word document")
      @file.suffix.should eq("doc")
      @file.is_embeddable.should be_true
    end

    it "when pdf" do
      @file.name = "test.pdf"
      @file.update_content_type_data
      @file.icon.should eq("/skydrive/images/icon-pdf.png")
      @file.kind.should eq("PDF document")
      @file.suffix.should eq("pdf")
      @file.is_embeddable.should be_true
    end

    it "when unknown" do
      @file.name = "test.unknown"
      @file.update_content_type_data
      @file.icon.should eq("/skydrive/images/icon-file.png")
      @file.kind.should eq("")
      @file.suffix.should eq("unknown")
      @file.is_embeddable.should be_false
    end
  end
end
