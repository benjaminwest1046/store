class AddPowerUsertoUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :power_user, :boolean
  end
end
