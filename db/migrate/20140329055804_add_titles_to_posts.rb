class AddTitlesToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :title, :string
  end
end
