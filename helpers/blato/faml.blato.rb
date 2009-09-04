class Faml 
  include Blato
  TAB_SPACES = 2

  bla :compile, "Turn all files in /../compiled into HTML web.py templates." do
		Dir['**/compiled'].each do |compiled_dir|
			
			dir   = Pow( File.dirname( compiled_dir )  )
			c_dir = Pow( compiled_dir )

			# raise "#{dir} does not exist." if !dir.directory?
			# shout(capture('mkdir %s' % c_dir.to_s.inspect)) if !c_dir.directory?
			
			dir.each { |f|
				if f.file? && f.to_s =~ /\.faml\.rb$/
					content  = compile_file(f)
					dirname  = File.dirname(f.to_s)
					filename = File.basename(f.to_s).sub(/\.faml\.rb$/,'.html')
					Pow( c_dir,  filename ).create do |s|
						s.puts content
					end
				end
			}
		end
  end

  def compile_file(raw_file_name)
    fn = raw_file_name.is_a?(Pow::File) ? raw_file_name : Pow(raw_file_name.to_s)
    starts = fn.read.split('__START__')
    python = ''
    faml = if starts.size == 1
      starts.pop
    else
      python = starts.shift 
      starts.join('__START__')
    end
    lines = faml.lstrip.gsub("\t", ' ' * TAB_SPACES).split("\n")
    new_tag = /^[\ ]{0,}[A-Z\_0-9\-]{1,}\:/
    tags = []
    last_max = 0
    lines.each { |l|
      pieces = l.split(':')
      # SPACES, TAG, ATTRIBUTES, CONTENT
      if l =~ new_tag
        spaces = (l =~ /^(\ {0,})/ && $1.size)
        tags << { :spaces => spaces , 
        :tag => pieces.shift.strip, 
        :attrs => pieces.join(':'),
        :content => "" }
        if spaces < last_max

        else  

        end
        last_max = spaces
      else
        tags.last[:content] += l
      end
    }

    python + compile_tags( tags )

  end



  def compile_tags( tags )
    raise ArgumentError, "Invalid tags: #{tags.inspect}" if !tags
    return "" if tags.empty?
    open_tags = []
    
    t = tags.shift
    
    indent =  " " * t[:spaces]
    attrs = (" " + t[:attrs].to_s )
    attrs = '' if attrs.strip.empty?
    if tags.empty?
      content = "<#{t[:tag]}#{attrs}>\n#{t[:content]}\n#{indent}</#{t[:tag]}>"
    
    elsif tags.first[:spaces] == t[:spaces]
      content = "<#{t[:tag]}#{attrs}>\n#{t[:content]}\n#{indent}</#{t[:tag]}>\n#{compile_tags(tags)}"
    
    elsif tags.first[:spaces] > t[:spaces]
      content = "<#{t[:tag]}#{attrs}>\n#{t[:content]}\n#{compile_tags(tags)}\n#{indent}</#{t[:tag]}>\n#{compile_tags(tags)}"
    
    elsif tags.first[:spaces] < t[:spaces]
      content = "<#{t[:tag]}#{attrs}>\n#{t[:content]}\n#{indent}</#{t[:tag]}>" 
    
    end
    
    indent + content
  end


end # === Faml


