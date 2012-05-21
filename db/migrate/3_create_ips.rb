class CreateIps < ActiveRecord::Migration
  def change
    create_table :ips do |t|
      t.string    :ip
      t.datetime  :last_post
      t.datetime  :last_thread
      # ban
      t.boolean   :banned
      t.integer   :ban_id

      t.timestamps
    end

    add_index :ips, :ip, unique: true
  end
end
