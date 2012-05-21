class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text      :message
      t.string    :ip
      t.string    :password
      t.boolean   :opening
      # if opening post 
      t.integer   :replies_count, default: 0
      t.boolean   :sticky,        default: false
      t.string    :title
      t.datetime  :bump      
      # else
      t.integer   :thread_id
      t.boolean   :sage,          default: false
      # pictures
      t.string    :picture_name
      t.string    :picture_type
      t.integer   :picture_size

      t.timestamps
    end

    add_index :posts, :thread_id, unique: false
    add_index :posts, :ip,        unique: false
    add_index :posts, :opening,   unique: false
  end
end
