

require 'RedCloth'
configure do
module ImgTag
  def img( opts )



    html_attrs = ''

    # Add src
    attrs = opts[:text].gsub('<br />', '').strip.split("\n").map {|c| c.strip }
    html_attrs =" src=\"#{attrs.shift.split('<').first.strip}\" "

    # Add Width and Height dimensions, if any.
    opts[:text].scan( /(w|h)\ +([0-9px]+)/i ).each do |d, q|
      a = ( d.downcase == 'w' ? 'width' : 'height' )
      html_attrs += " #{a}=\"#{q.to_i}\" "
    end

    # Add alt text by finding the first line by avoiding the line where
    # we found the width/height.
    alt_text = (  attrs.detect { |a| !$1 || !a[$2] } || '*'  )

    html_attrs += " alt=\"#{alt_text}\"  title=\"#{alt_text}\" "

    # Add other options.
    [:class, :id].each do |a|
      html_attrs += " #{a}=\"#{opts[a]}\"" if opts[a]
    end

    html = "<img #{html_attrs} /> \n "
  end
end

end # === configure

helpers {

  def textile_to_html(txt)
    r = RedCloth.new(txt)
    r.extend ImgTag
    r.filter_html = true
    r.to_html
  end

}

