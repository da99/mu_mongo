

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
      puts "\e[37m#{msg}\e[0m"
    else
      puts "\e[37m"
      output = yield
      puts "\e[0m"
      output
    end
    
  end

  def puts_red raw_msg
    msg = raw_msg.to_s
    puts "\e[1m\e[31m#{msg}\e[0m"
  end
  
	def puts_green raw_msg
		msg = raw_msg.to_s
		puts "\e[1m\e[32m#{raw_msg}\e[0m"
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
				final_arr << "\e[1m\e[31m#{text}\e[0m"
			when :green
				final_arr << "\e[1m\e[32m#{text}\e[0m"
			when :white
				final_arr << "\e[37m#{text}\e[0m"
			end
		end while !colored_text.empty?

		puts final_arr.join
	end

end # ========= Color_Puts
