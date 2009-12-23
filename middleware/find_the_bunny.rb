class Find_The_Bunny

	def initialize new_app
		@app = new_app
	end

	def call new_env
		
		new_env['the_bunny'] ||= {}
    http_meth = new_env['REQUEST_METHOD'].to_s
		
    results = The_Bunny_Farm.controllers.detect { |control|
      
      pieces = new_env['PATH_INFO'].strip_slashes.split('/')
      a_name = http_meth

      begin
        
				if pieces.first == control.name.downcase && 
					!control.public_instance_methods.include?("#{http_meth}_#{pieces.first}")
					pieces.shift
				end

				pieces.push('list') if pieces.empty?
				a_name = [a_name, pieces.shift.split('-')].compact.join('_')
				
				if control.public_instance_methods.include?(a_name) && 
					control.instance_method(a_name).arity === pieces.size 
					
					new_env['the_bunny'][:controller]  = control
					new_env['the_bunny'][:action_name] = (a_name['_'] ? a_name.split("_")[1,100].join('_') : a_name)
					new_env['the_bunny'][:args]        = pieces
					break
					
				end
          
      end until pieces.empty?

			new_env['the_bunny'][:controller]
    }

		@app.call new_env 

	end

end # === Find_The_Bunny
