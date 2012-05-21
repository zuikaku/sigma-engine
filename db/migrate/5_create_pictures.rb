class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string  :md5_hash
      t.string  :name
      t.integer :size
      t.timestamps
    end

    add_index :pictures, :md5_hash, unique: true
  end
end
