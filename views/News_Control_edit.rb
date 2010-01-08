# MAB   /home/da01/MyLife/apps/megauni/templates/English/mab/News_Control_edit.rb
# SASS  /home/da01/MyLife/apps/megauni/templates/English/sass/News_Control_edit.sass
# NAME  News_Control_edit

class News_Control_edit < Base_View
  
  def respond_to? raw_meth
    meth = raw_meth.to_s
    return true  if methods.include?(meth)
    return super if not meth[/\Anews_/] 
    col = meth.sub('news_', '')
    news.data.as_hash.has_key?(col.to_sym)
  end

  def method_missing raw_meth, *args
    meth = raw_meth.to_s
    return super if !meth[/\Anews_/] || !args.empty?
    col = meth.sub('news_', '')
    news.data.send(col)
  end

  def title 
    "Editing: #{news.data.title}"
  end

  def news
    @app.env['the.app.news']
  end

  def clubs
    [{:filename=>'Kit Kat', :selected=>false, :not_selected=>true}]
  end

  def news_tags
    [{:filename=>'fun', :selected=>true, :not_selected=>false}]
  end

  def news_href
    filename, club_type, *rest = news.data._id.split('-')
    File.join('/', filename, club_type, rest.join('-'), '/')
  end

  def news_href_update
    File.join('/news', news.data.club_id, '/')
  end
	
end # === News_Control_edit 
