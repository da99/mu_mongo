
class Cleaner_Dsl

	Invalid = Class.new(StandardError)

  attr_reader :options

  def initialize human_field_name, field_val 
    
    @options = Struct.new(
			:capitalized_field_name,
      :original, 
      :clean, 
      :error_msg,
			:error_recording
    ).new

		@options.capitalized_field_name = human_field_name.capitalize
		@options.original               = field_val
		@options.clean                  = field_val
		@options.error_msg              = "#{capitalized_field_name} is invalid."
		@options.error_recording        = true
		
  end
  
	def execute blok
		instance_eval( &blok  )
	end

  def errors
    @errors ||= []
  end

  def add_error msg
    if options.error_recording
			errors << msg
		end
		raise Invalid 
    msg
  end
  
  def choose_and_add_error *custom_msgs, &blok
    msg = (custom_msgs + [ 
      block_given?  && instance_eval( &blok ),
			options.error_msg,
    ] ).detect { |m| m }

    add_error msg
  end

  public # =========================

  # === SETTING RELATED METHODS ====

  def set_to new_val
    options.clean = new_val
  end

  # === MISCELLANEOUS METHODS ====

  def capitalized_field_name
    options.capitalized_field_name 
  end

	def no_error_recording
		options.error_recording = false
	end

  def error_msg( *args )
    case args.size
      when 0
        options.error_msg
      when 1
        options.error_msg = msg
      else
        raise ArgumentError, "Only 0 or 1 args allowed: #{args.inspect}"
    end
  end
 
	def must_equal val, err_msg = nil
    if !val.eql?( options.clean )
      choose_and_add_error err_msg
    end
  end

  # === TIME METHODS ====

  def to_datetime(time_or_str)
    set_to Couch_Plastic::Helper.time_string(time_or_str)
  end

  def to_datetime_or_now(nil_or_time_or_str = nil)
    v = nil_or_time_or_str
    set_to( v ? to_datetime(v) : Couch_Plastic::Helper.utc_now_as_string )
  end

  # === ARRAY METHODS ====

  def if_in(arr, &blok)
    if arr.include?(options.clean)
      instance_eval( &blok )
    else
      false
    end
  end

  def if_not_in(arr, &blok)
    if !arr.include?(options.clean)
      instance_eval( &blok )
    else
      false
    end
  end

  # === STRING METHODS ====

  def symbolize
    return true if options.clean.is_a?(Symbol)
    if !options.clean.is_a?(String)
      raise ArgumentError, "#{options.clean.inspect} has to be either a String or Symbol: #{options.clean.inspect}."
    end

		strip

    if options.clean.empty?
      raise ArgumentError, "Can't use :symbolize on an empty string: #{options.original.inspect}" 
    end
    set_to options.clean.to_sym
  end

  def strip
    set_to options.clean.to_s.strip
  end

  alias_method :strip_it, :strip

  def split
		set_to  options.clean.to_s.split
  end

  alias_method :split_it, :split
  
  def clean_with regex, &blok_for_regex
    options.clean = if block_given?
      options.clean.gsub(regex, &blok_for_regex)
    else
      options.clean.gsub(regex, '')
    end
  end

  def must_not_be_empty &err_msg
    if options.clean.empty?
      msg = "#{capitalized_field_name} is required."
      choose_and_add_error( msg, &err_msg)
    end
    true
  end

  def must_be_string &err_msg_blok
    if !options.clean.is_a?(String)
      raise "Programmer Error: #{options.clean.inspect} must be a string."
    end

    msg =  "#{capitalized_field_name} ."
    choose_and_add_error( msg, &err_msg_blok )

    true
  end

  # Turns :val into a stripped string if it does not
  # respond to :size.
  def min_size( size, err_msg = nil, &blok )
		
    int = size.to_i
    raise ArgumentError, "Min size has to be bigger than 0." if int < 1
		
    strip if !options.clean.respond_to?(:jsize)
    return true if options.clean.jsize >= size 

    msg = "#{capitalized_field_name} must be at least #{size} characters in length."
    choose_and_add_error(err_msg, msg, &blok)
    false
		
  end

  # Turns :val into a stripped string if it does not
  # respond to :size.
  def between_size( min, max, str = nil, &blok ) 
    strip if !options.clean.respond_to?(:jsize)
    return true if options.clean.jsize.between?(min, max)

    msg = "#{capitalized_field_name} needs to be between #{min} and #{max} characters in length."
    choose_and_add_error((str && str % [min, max]), msg, &blok)
    false
  end
  
  def match(s_or_regex, err_msg = nil,  &err_msg_blok)

    they_match = case s_or_regex
      when String
        msg = "#{capitalized_field_name} must match #{s_or_regex}."
        options.clean == s_or_regex
      when Regexp
        msg = "#{capitalized_field_name} is invalid."
        options.clean =~ s_or_regex
    end

    return true if they_match
    choose_and_add_error(err_msg, msg, &err_msg_blok)
    false

  end
  

end # ==== class Validator
