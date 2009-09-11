require 'pow'
require 'open3'

Dir['helpers/thor/*.rb'].each do |file|

  require Pow( file )

end
