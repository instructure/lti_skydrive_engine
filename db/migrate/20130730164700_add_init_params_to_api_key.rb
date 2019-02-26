class AddInitParamsToApiKey < ActiveRecord::Migration[4.2]
  def change
    add_column :api_keys, :init_params, :text
  end
end
