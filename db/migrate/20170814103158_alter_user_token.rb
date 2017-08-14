class AlterUserToken < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :remember_token, :token
    remove_column :users, :encrypted_password
    remove_column :users, :confirmation_token

  end
end
