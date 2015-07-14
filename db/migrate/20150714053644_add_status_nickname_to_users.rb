class AddStatusNicknameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :status_nickname, :string
  end
end
