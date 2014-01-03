class AddInitParamsToApiKey < ActiveRecord::Migration
  def change
    add_column :api_keys, :init_params, :text
  end
end
