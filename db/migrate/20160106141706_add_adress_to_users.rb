class AddAdressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :street, :string
    add_column :users, :zipcode, :string
    add_column :users, :city, :string
    add_column :users, :latitude, :float
    add_column :users, :longitude, :float
  end
end
