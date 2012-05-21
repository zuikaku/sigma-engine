class CreateBans < ActiveRecord::Migration
  def change
    create_table :bans do |t|
      t.integer   :level
      t.string    :reason
      t.datetime  :expires_at
      t.string    :ip
      
      t.timestamps
    end
  end
end
