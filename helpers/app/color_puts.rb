

module Color_Puts 

  # ===================================================
  # ======== Print methods.
  # ===================================================
  
  def puts_white raw_msg = nil
    if !raw_msg && !block_given?
      raise ArgumentError, "No string or block given."
    end
    if raw_msg && block_given?
      raise ArgumentError, "Both string and block given. You can only use one."
    end

    if raw_msg
      msg = raw_msg.to_s
      puts_multi :white, msg
    else
      puts( ENV['NO_COLOR_PUTS'] ? '' : "\e[37m" )
      output = yield
      puts( ENV['NO_COLOR_PUTS'] ? '' :  "\e[0m" )
      output
    end
    
  end

  def puts_red raw_msg
    msg = raw_msg.to_s
    puts_multi :red, msg
  end
  
	def puts_green raw_msg
		msg = raw_msg.to_s
    puts_multi :green, raw_msg
	end
	
	def puts_multi *colored_text
		demand_equal 0, colored_text.size % 2
		demand_array_not_empty colored_text
		final_arr = []
		begin
			color = colored_text.shift
			text  = colored_text.shift
			case color
			when :red
				final_arr << ( ENV['NO_COLOR_PUTS'] ? text.to_s : "\e[1m\e[31m#{text}\e[0m" )
			when :green
				final_arr << ( ENV['NO_COLOR_PUTS'] ? text.to_s : "\e[1m\e[32m#{text}\e[0m" )
			when :white
				final_arr << ( ENV['NO_COLOR_PUTS'] ? text.to_s : "\e[37m#{text}\e[0m" )
			end
		end while !colored_text.empty?

		puts final_arr.join
	end

end # ========= Color_Puts
