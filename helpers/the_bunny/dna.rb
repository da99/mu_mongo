
module Bunny_DNA
  
  attr_reader :the_stage
  
  def initialize new_stage
    @the_stage = new_stage
  end

  def render_html txt
    @the_stage.response.body = txt
    @the_stage.response.header['Content-Type']   = 'text/html'
    @the_stage.response.header['Content-Length'] = txt.size.to_s
  end

end # === Bunny_DNA
