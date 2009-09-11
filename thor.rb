#!/home/da01/rubyee/bin/ruby
$KCODE = 'u' # Needed to handle non-ascii file paths.

require 'pow'
require 'open3'
require File.expand_path('~/megauni/helpers/thor/__core_funcs')

Dir['helpers/thor/*.rb'].each do |file|
  file_name = file.sub(/\.rb$/, '')
  if file !~ /core_funcs/
    require Pow( file )
  end
end

