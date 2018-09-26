class AddAttachmentImagemToCombos < ActiveRecord::Migration[5.2]
  def self.up
    change_table :combos do |t|
      t.attachment :imagem
    end
  end

  def self.down
    remove_attachment :combos, :imagem
  end
end
