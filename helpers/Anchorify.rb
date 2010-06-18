
class Anchorify
  
  class << self
    attr_accessor :last_filter_added
    attr_reader :filters, :filter_order
  end

  attr_accessor :filters

  def self.filters
    @filters ||= {}
  end

  def self.filter_order
    @filter_order ||= []
  end

  def self.add_filter name , &blok
    self.filter_order << name
    self.filters[name] ||= {}
    self.filters[name][:options] ||= {}
    self.filters[name][:block] = blok
    self.last_filter_added = filters[name]
    self
  end

  def self.with( opts = {}, &blok )
    last_filter_added[:options].update(opts)
    if block_given?
      last_filter_added[:block]=blok
    end
    self
  end

  def initialize *filters
    @filters = begin
                 if filters.empty?
                   self.class.filter_order
                 else
                   new_filters = filters.compact.uniq
                   invalid_filters = new_filters - filters.keys
                   raise ArgumentError, "Invalid filter names: #{invalid_filters.inspect}"
                   new_filters 
                 end
               end
  end

  def anchorify raw_txt
    txt = raw_txt.to_s.strip
    return '' if !txt || txt.empty?
    filters.inject(txt) { |memo, fil|
      
      the_filter = Anchorify.filters[fil]
      
      case the_filter[:block].arity
      when 1
        the_filter[:block].call memo
      else
        the_filter[:block].call memo, the_filter[:options]
      end
      
    }
  end

end # === class


AutoHtml = Anchorify
%w{ dailymotion google_video image vimeo youtube}.each { |filter|
  require "auto_html/filters/#{filter}"
}

Anchorify.add_filter(:link) do |text|
  find_urls = %r~[\s](http://[^\/]{1}[A-Za-z0-9\@\#\&\/\-\_\?\=\.]+)[\s]~
  (' ' + text + ' ').gsub(find_urls, "<a href=\"\\1\">\\1</a>").strip
end
