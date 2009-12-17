class Bunny_Mustache < Mustache
	
	def initialize new_app
		@app = new_app
	end
	
	def js_epoch_time raw_i = nil
		i = raw_i ? raw_i.to_i : Time.now.utc.to_i
    i * 1000
	end

	def copyright_year
		[2009,Time.now.utc.year].uniq.join('-')
	end

	def site_domain
		The_Bunny::Options::SITE_DOMAIN
	end

	def meta_description
	end

	def meta_keywords
	end

	def javascripts
	end

  def flash_msg?
    nil
  end
end # === Bunny_Mustache
