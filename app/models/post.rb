class Post < ActiveRecord::Base
  validates :title,    :length => {maximum: 50}
  validates :message,  :length => {maximum: 3000}
  validates :password, :length => {maximum: 20}

  before_create do
    if self.opening
      self.bump = Time.now
    end
  end

  def self.get_by_id(id)
    Post.where(id: id).first
  end

  def has_picture?
    not self.picture_name == nil
  end

  def last_replies(amount)
    replies = Post.where(thread_id: self.id).order('created_at DESC').limit(amount)
    replies.to_a.reverse
  end

  def picture_url
    return "/images/#{self.picture_name}.#{self.picture_type}"
  end

  def thumb_url
    return "/images/#{self.picture_name}_thumb.#{self.picture_type}"
  end
end
