require 'spec_helper'

describe Skydrive::File do
  describe "#update_content_type_data" do
    before(:each) do
      @file = Skydrive::File.new
    end

    it "when png (and allowed extensions)" do
      @file.name = "test.png"
      @file.update_content_type_data(['doc'])
      expect(@file.icon).to eq("png")
      expect(@file.kind).to eq("PNG image")
      expect(@file.suffix).to eq("png")
      expect(@file.is_embeddable).to be false
    end

    it "when jpg" do
      @file.name = "test.jpg"
      @file.update_content_type_data
      expect(@file.icon).to eq("jpg")
      expect(@file.kind).to eq("JPEG image")
      expect(@file.suffix).to eq("jpg")
      expect(@file.is_embeddable).to be true
    end

    it "when bmp" do
      @file.name = "test.bmp"
      @file.update_content_type_data
      expect(@file.icon).to eq("jpg")
      expect(@file.kind).to eq("Windows BMP image")
      expect(@file.suffix).to eq("bmp")
      expect(@file.is_embeddable).to be true
    end

    it "when doc" do
      @file.name = "test.doc"
      @file.update_content_type_data
      expect(@file.icon).to eq("word")
      expect(@file.kind).to eq("Word document")
      expect(@file.suffix).to eq("doc")
      expect(@file.is_embeddable).to be true
    end

    it "when pdf" do
      @file.name = "test.pdf"
      @file.update_content_type_data
      expect(@file.icon).to eq("pdf")
      expect(@file.kind).to eq("PDF document")
      expect(@file.suffix).to eq("pdf")
      expect(@file.is_embeddable).to be true
    end

    it "when unknown" do
      @file.name = "test.unknown"
      @file.update_content_type_data
      expect(@file.icon).to eq("file")
      expect(@file.kind).to eq("")
      expect(@file.suffix).to eq("unknown")
      expect(@file.is_embeddable).to be false
    end
  end
end
