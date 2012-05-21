class ApplicationController < ActionController::Base
  protect_from_forgery

  def not_found
    render(template: 'not_found', status: :not_found)
  end

  private
  def post_only
    return not_found if not request.post?
  end

  def ajax_used?
    return params[:ajax] == 'on'
  end

  def parse(text)
    text.strip!
    text.gsub!('&', '&amp;')
    text.gsub!('<', '&lt;')
    text.gsub!('>', '&gt;')
    text.gsub!(/\*\*(.+?)\*\*/, bold('\1'))
    text.gsub!(/\*(.+?)\*/,     italic('\1'))
    text.gsub!(/__(.+?)__/,     underline('\1'))
    text.gsub!(/%%(.+?)%%/,     spoiler('\1'))
    @id_counter = 0
    text.gsub! /&gt;&gt;(\d+)/ do |id|
      if @id_counter < 10 
        @id_counter += 1
        id = id[8..id.length].to_i
        if (post = Post.get_by_id(id))
          id = post.thread_id
          id = post.id if post.opening
          url = url_for(controller: 'posts',
                        action:     'show',
                        id:         id,
                        anchor:     post.id,
                        format:     'xhtml')
          "<div class='post_link'><a href='#{url}'>&gt;&gt;#{id}</a></div>"
        else
          "&gt;&gt;#{idd}"
        end
      else
        "&gt;&gt;#{idd}"
      end
    end
    text.gsub!(/^&gt;(.+)$/,  quote('\1'))
    text.gsub!(/\r\n(\r\n)+/, '<br /><br />')
    text.gsub!(/\r\n/,        '<br />')
    return text
  end

  def bold(text)
      "<b>#{text}</b>"
  end

  def italic(text)
    "<i>#{text}</i>"
  end

  def underline(text)
    "<u>#{text}</u>"
  end

  def spoiler(text)
    "<span class='spoiler'>#{text}</span>"
  end

  def quote(text)
    "<span class='quote'>&gt; #{text.strip}</span><br />"
  end
end
