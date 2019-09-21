class CreateDownloads < ActiveRecord::Migration[5.2]
  def change
    create_table :downloads do |t|
      t.references :user, index: true
      t.string :path

      t.timestamps
    end
  end
end
