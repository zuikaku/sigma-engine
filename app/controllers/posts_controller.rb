class PostsController < ApplicationController
  before_filter :set_password
  before_filter :get_ip

  def index
    show_page(1)
  end

  def page
    if (page_number = params[:page].to_i) < 1
      return redirect_to :root
    else
      show_page(page_number)
    end
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
    # if given ID matches for reply, not OP-post, show OP-post anyway
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
    @threads = Post.where(opening: true).order('bump DESC').paginate(per_page: THREADS_PER_PAGE,
                                                                     page:     page_number)
    if @threads.empty? and page_number != 1
      not_found
    else
      render template: 'posts/index'
    end
  end

  def process_post
    def validate_content
      # wakaba-mark for message contents
      @post.message = parse(@post.message)
      # check lengths of message, password and title
      unless @post.valid?
        @post.errors.to_hash.each_value do |error_array|
          error_array.each { |e| @errors << e }
        end
      end
      # check picture
      if (picture_result = validate_picture).kind_of?(Array)
        @errors += picture_result
      end
      # OP-post should have both picture and text, reply may have one of them
      if @post.opening
        @errors << t('errors.missing picture') if not @post.has_picture?
        @errors << t('errors.missing message') if @post.message.empty?
      else
        unless @post.has_picture? or not @post.message.empty?
          @errors << t('errors.missing content')
        end
      end
      return @errors.empty?
    end

    def validate_picture
      picture = params[:post][:picture]
      errors  = Array.new
      # check if user uploaded something in the first place
      return true if picture.kind_of?(String)
      # check file size and content type
      if picture.tempfile.size > MAX_PICTURE_SIZE
        errors << "#{t('errors.pic size should be')} #{MAX_PICTURE_SIZE/1024} kb."
      end
      if not ALLOWED_PICTURE_TYPES.include?(picture.content_type)
        allowed = Array.new
        ALLOWED_PICTURE_TYPES.each { |type| allowed << type.split('/')[1].upcase }
        errors << t('errors.pic type should be') + allowed.join(', ')
      end
      # procceed if everything's correct
      if errors.empty?
        # trying to find the same file in the database
        hash = Digest::MD5.hexdigest(picture.tempfile.read)
        type = picture.content_type.split('/')[1]
        @post.picture_type = type
        @post.picture_size = picture.tempfile.size
        # if the same file is already saved, give it's name and do nothing
        if (hash_record = Picture.where(md5_hash: hash).first)
          @post.picture_name = hash_record.name
          return true
        else
          # if uploaded file seems to be new, save and register
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
          @post.picture_name = index
          return true
        end
      else
        # just to know that user tried to upload something, but failed
        @post.picture_name = 'sosnooley' 
        return errors
      end
    end

    def validate_posting_permission
      # make sure that parent thread is present and open
      unless @post.opening
        if (@thread = Post.get_by_id(params[:id].to_i))
          @post.thread_id = @thread.id
          @errors << t('errors.thread closed') if @thread.closed
        else
          @errors << t('errors.thread vanished')
        end
      end
      # no posting if you are banned
      @errors << t('errors.banned') if @ip.banned
      # check posting speed 
      if @post.opening
        checking  = @ip.last_thread
        limit     = 10 # TODO: make this customizable
      else
        checking  = @ip.last_post
        limit     = 5 # TODO: make this customizable
      end
      checking = (Time.now - checking).to_i
      @errors << t('errors.posting too fast') if checking < limit
      return @errors.empty?
    end

    def control_board_limit
      # delete the last thread if limit is reached
      if Post.where(opening: true).count > BOARD_LIMIT
        Post.where(opening: true).order('bump ASC').first.delete
      end
    end

    def reply(response, status)
      # if response is class Post, render haml partial, 
      # otherwise reply with text string
      @ip.save
      if response.kind_of?(Post)
        return render(partial: 'post', object: response, status: status)
      elsif response.kind_of?(Array)
        string = String.new
        response.each { |e| string += "#{e}<br/>" }
        response = string
      end
      return render(text: response, status: status)
    end

    # sleep(1) # for now
    # post creation algorythm
    @errors = Array.new
    params_dup = params[:post].dup # that's bad, mkay
    params_dup.delete(:picture)
    @post = Post.new(params_dup)
    @post.opening = (params[:action] == 'create_thread')
    cookies['password'] = { value:    params[:post][:password],
                            path:     root_path,
                            expires:  Time.new + 99999999 }
    # run ALL the validations!
    validate_content if validate_posting_permission
    if @errors.empty?
      # everything's okay
      @post.save
      control_board_limit
      if @post.opening
        @ip.last_thread = @post.created_at
        return reply(url_for(action:  'show', 
                             id:      @post.id, 
                             format:  'xhtml'), :created)
      else
        # update parent thread 
        @thread.bump = @post.created_at if @thread.replies_count < BUMP_LIMIT
        @thread.replies_count += 1
        @ip.last_post = @post.created_at
        return reply(@post, :created) if @thread.save
      end
    else
      # show all the errors
      return reply(@errors, :not_acceptable)
    end
  end
  
  def set_password
    # if no password cookie is provided, set it
    if not cookies.has_key?('password')
      @password = (100000000 + rand(1..899999999)).to_s
      cookies['password'] = { value:    @password,
                              path:     root_path,
                              expires:  Time.new + 99999999 }
    else
      @password = cookies['password']
    end
  end

  def get_ip
    unless(@ip = Ip.get_by_ip(request.remote_ip))
      @ip = Ip.create(ip: request.remote_ip)
    end
  end
end
