class CreateIps < ActiveRecord::Migration
  def change
    create_table :ips do |t|
      t.string    :ip
      t.datetime  :last_post,   default: Time.new(0)
      t.datetime  :last_thread, default: Time.new(0)
      # ban
      t.boolean   :banned,      default: false
      t.integer   :ban_id

      t.timestamps
    end

    add_index :ips, :ip, unique: true
  end
end
