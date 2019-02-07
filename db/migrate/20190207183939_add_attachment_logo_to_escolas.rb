class AddAttachmentLogoToEscolas < ActiveRecord::Migration[5.2]
  def self.up
    change_table :escolas do |t|
      t.attachment :logo
    end
  end

  def self.down
    remove_attachment :escolas, :logo
  end
end
