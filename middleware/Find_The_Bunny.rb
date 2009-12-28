class Find_The_Bunny

	def initialize new_app
		@app = new_app
	end

	def call new_env
		
		new_env['the_bunny'] ||= {}
    http_meth = new_env['REQUEST_METHOD'].to_s
		
    results = The_Bunny_Farm.bunnies.detect { |control|

      pieces = new_env['PATH_INFO'].strip_slashes.split('/')
      a_name = http_meth

      begin
          
				if pieces.first == control.name.downcase && 
				   !control.public_instance_methods.include?("#{http_meth}_#{pieces.first}")
          
          pieces.shift
          
				end

				if pieces.empty?
				  a_name = "#{a_name}_list"
        end
				
				if control.public_instance_methods.include?(a_name) && 
					 control.instance_method(a_name).arity === pieces.size 
					
					new_env['the_bunny'][:controller]  = control
					new_env['the_bunny'][:action_name] = (a_name['_'] ? a_name.split('_')[1,10].join('_') : a_name )
					new_env['the_bunny'][:args]        = pieces
					break
					
				end

        a_name = "#{a_name}_#{pieces.shift.to_s.gsub(/[^a-zA-Z0-9]/, '_')}"
          
      end until pieces.empty?

			new_env['the_bunny'][:controller]
    }

		if results
			@app.call new_env 
		else
			new_env['bunny.404'] = begin
															 File.read('public/404.html')
														 rescue Object
															 "<h1>Not Found</h1>
															 <p>Check spelling: #{new_env['PATH_INFO']}</p>"
														 end
			raise Bad_Bunny::HTTP_404, "Not found: #{new_env['REQUEST_METHOD']} #{new_env['PATH_INFO']}"
		end

	end

end # === Find_The_Bunny
