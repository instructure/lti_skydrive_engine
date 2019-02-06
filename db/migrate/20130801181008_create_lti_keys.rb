class CreateLtiKeys < ActiveRecord::Migration[4.2]
  def change
    create_table :lti_keys do |t|
      t.string :key
      t.string :secret
    end
    add_index :lti_keys, :key
  end
end
