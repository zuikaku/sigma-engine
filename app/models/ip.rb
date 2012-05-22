class Ip < ActiveRecord::Base
  def self.get_by_ip(ip)
    Ip.where(ip: ip).first
  end

  def posting_speed_value(thread)
    self.last_thread if thread
    self.last_post unless thread
  end
end
