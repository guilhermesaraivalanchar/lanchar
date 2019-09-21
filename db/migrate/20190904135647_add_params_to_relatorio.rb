class AddParamsToRelatorio < ActiveRecord::Migration[5.2]
  def change
    add_column :relatorios, :param_1, :text
    add_column :relatorios, :param_2, :text
    add_column :relatorios, :param_3, :text
    add_column :relatorios, :param_4, :text
    add_column :relatorios, :param_5, :text
    add_column :relatorios, :param_6, :text
    add_column :relatorios, :param_7, :text
    add_column :relatorios, :param_8, :text
    add_column :relatorios, :param_9, :text
    add_column :relatorios, :param_10, :text
  end
end
