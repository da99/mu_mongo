# /home/da01/megauni/templates/English/mab/Inspect_Cage_list.rb

class Inspect_Cage_list < Bunny_Mustache

  def title
    'Hello, World'
  end

  def total_lines
    The_Bunny_Farm.total_lines
  end

  def path_info
    @app.request.path_info
  end

  def ssl_inspect
    @app.ssl?.inspect
  end

  def url
    @app.request.url
  end

  def mobile_request?
    false
  end

  def head_content
    nil
  end

  def loading?
    nil
  end

  def loading
  end


end # === class Hello_Bunny_GET_list
