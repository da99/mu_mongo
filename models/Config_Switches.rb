
class	Config_Switches

	attr_reader :values_hash

	def initialize &blok
		@store = Class.new {
			def values_hash
				@values_hash ||= {}
			end
		}.new
		instance_eval &blok
	end

	def exec &blok
		@store.instance_eval &blok
	end

	def store_hash
		@store.values_hash
	end

	def on
		true
	end
	
	def off
		false
	end
	
	def strings *args
		args.each { |field|
			eval %~
				def self.#{field}
					store_hash[:#{field}]
				end
			
				def self.#{field}?
					!!store_hash[:#{field}]
				end

				def @store.#{field} val
					values_hash[:#{field}] = val
				end
			~
		}
	end
	alias_method :string, :strings

	def arrays *args
		args.each { |field|
			eval %~
				def self.#{field}
					store_hash[:#{field}] || []
				end

				def self.#{field}?
					!!store_hash[:#{field}]
				end
				
				def @store.#{field} *args
					values_hash[:#{field}] = if args.is_a?(Array) && args.first.is_a?(Array) &&args.size == 1
																			args.first
																		else
																			args
																		end
				end
				
			~
		}
	end
	alias_method :array, :arrays

	def hashes *args
		args.each { |field|
			eval %~
				def self.#{field}
					store_hash[:#{field}] || {}
				end

				def self.#{field}?
					case store_hash[:#{field}]
					when Hash
						!store_hash[:#{field}].empty?
					else
						!!store_hash[:#{field}]
					end
				end

				def @store.#{field} hsh
					values_hash[:#{field}] = hsh
				end
			~
		}
	end
	alias_method :hash, :hashes

	def allow name, val_up
		val_down = !!!val_up
		eval %~
			def self.#{name}?
				!!store_hash[:#{name}] 
			end
		
			def @store.#{name}
				values_hash[:#{name}] = #{name}_up
			end
			
			def @store.#{name}_up
				#{val_up.inspect}
			end
			
			def @store.#{name}_down
				#{val_down.inspect}
			end
		~
	end

end # === class Config_Switches
