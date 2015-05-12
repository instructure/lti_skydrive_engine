require 'spec_helper'

describe Skydrive::Folder do
  it "#parse_parent_uri without uri" do
    folder = Skydrive::Folder.new
    folder.server_relative_url = ""
    folder.uri = ""
    folder.parse_parent_uri
    expect(folder.parent_uri).to be_nil
  end

  it "#parse_parent_uri with uri" do
    folder = Skydrive::Folder.new
    folder.server_relative_url = "/personal/ericb_instructure_onmicrosoft_com/Documents/Pictures/Vacations"
    folder.uri = "https://instructure-my.sharepoint.com/personal/ericb_instructure_onmicrosoft_com/_api/Web/Lists(guid'85208d43-a3be-43ca-a737-f6913578427b')/RootFolder"
    folder.parse_parent_uri
    expect(folder.parent_uri[:uri]).to eq("https://instructure-my.sharepoint.com/personal/ericb_instructure_onmicrosoft_com/_api/Web/Lists(guid'85208d43-a3be-43ca-a737-f6913578427b')')")
  end
end
