class PostsController < ApplicationController
  before_filter :set_password

  def index
    show_page(1)
  end

  def page
    page_number = params[:page].to_i
    show_page(page_number)
  end

  def create_thread
    post_only
    process_post
  end

  def create_reply
    post_only
    process_post
  end

  def show 
    if (@thread = Post.get_by_id(params[:id].to_i))
      unless @thread.opening
        redirect_to(action: 'show',
                    id:     @thread.thread_id,
                    anchor: @thread.id,
                    format: 'xhtml')
      end
      @replies = Post.where(thread_id: @thread.id)
    else
      not_found
    end
  end

  private
  def show_page(page_number)
    @threads = Post.where(opening: true).order('bump DESC').paginate(per_page: 3,
                                                                     page: page_number)
    if @threads.empty? and page_number != 1
      not_found
    else
      render template: 'posts/index'
    end
  end

  def process_post
    def validate_content(post)
      unless post.valid?
        post.errors.to_hash.each_value do |error_array|
          error_array.each { |e| @errors << e }
        end
      end
      if (picture_result = validate_picture(post)).kind_of?(Array)
        @errors += picture_result
      end
      if post.opening
        @errors << t('errors.missing picture') if not post.has_picture?
        @errors << t('errors.missing message') if post.message.empty?
      else
        unless post.has_picture? or not post.message.empty?
          @errors << t('errors.missing content')
        end
      end
      return @errors.empty?
    end

    def validate_picture(post)
      picture = params[:post][:picture]
      errors  = Array.new
      return true if picture.kind_of?(String)
      if picture.tempfile.size > MAX_PICTURE_SIZE
        errors << "#{t('error.pic size should be')} #{MAX_PICTURE_SIZE/1024} kb"
      end
      if not ALLOWED_PICTURE_TYPES.include?(picture.content_type)
        allowed = Array.new
        ALLOWED_PICTURE_TYPES.each { |type| allowed << type.split('')[1] }
        errors << "#{t('error.pic type should be')} #{allowed.join(', ')}"
      end
      if errors.empty?
        hash = Digest::MD5.hexdigest(picture.tempfile.read)
        type = picture.content_type.split('/')[1]
        post.picture_type = type
        post.picture_size = picture.tempfile.size
        if (hash_record = Picture.where(md5_hash: hash).first)
          post.picture_name = hash_record.name
          return true
        else
          path = "#{Rails.root}/public/images"
          Dir::mkdir path if not File.directory?(path)
          index = Time.now.to_i.to_s + rand(9).to_s
          path  += '/' + index
          thumb = path + '_thumb'
          path  += '.' + type
          thumb += '.' + type
          FileUtils.copy(picture.tempfile.path, path)
          pic = Magick::ImageList.new(path)[0]
          pic.resize_to_fit!(200, 200) if (pic.columns > 200 or pic.rows > 200)
          pic.write(thumb)
          Picture.create(md5_hash: hash,
                         name:     index, 
                         size:     picture.tempfile.size)
          post.picture_name = index
          return true
        end
      else
        return errors
      end
    end

    def validate_parent_thread(post)
      if (thread = Post.get_by_id(params[:id].to_i))
        post.thread_id = thread.id
        (thread.bump = Time.new) if thread.replies_count < 500
        thread.replies_count += 1
        thread.save
        return true
      else
        @errors << t('errors.thread vanished')
        return false
      end
    end

    def reply(response, status)
      if response.kind_of?(Post)
        render(partial: 'post', object: response, status: status)
      elsif response.kind_of?(Array)
        puts response.inspect
        string = String.new
        response.each { |e| string += "#{e}<br/>" }
        render(text: string, status: status)
      end
    end

    sleep(1)
    @errors = Array.new
    params_dup = params[:post].dup
    params_dup.delete(:picture)
    post = Post.new(params_dup)
    post.opening = (params[:action] == 'create_thread')
    cookies['password'] = { value:    params[:post][:password],
                            path:     root_path,
                            expires:  Time.new + 99999999 }

    if validate_content(post) and validate_parent_thread(post)
      post.save
      if post.opening
        return redirect_to(action: 'show', id: post.id, format: 'xhtml')
      else
        return reply(post, :created)
      end
    else
      return reply(@errors, :not_acceptable)
    end
  end
  
  def set_password
    if not cookies.has_key?('password')
      @password = (100000000 + rand(1..899999999)).to_s
      cookies['password'] = { value:    @password,
                              path:     root_path,
                              expires:  Time.new + 99999999 }
    else
      @password = cookies['password']
    end
  end
end
