
module CouchPlastic

  class Validator

    class << self
      def validate(doc, col, &blok)
        v = new(doc, col, &blok)
      end
    end

    attr_reader :doc, :col, :original_val
    attr_reader :allow_other_validations, :after_proc
    attr_reader :allow_set
    attr_accessor :only_one_more_error_allowed

    def initialize(doc, col, &blok)
      @allow_set = true
      @doc = doc
      @col = col.to_sym
      @val = doc.raw_data[@col]
      @allow_other_validations = false
      @original_val = @val
      self.only_one_more_error_allowed = true

      instance_eval &blok

      if @allow_set
        doc.new_values[@col] = @val
      end
      if after_proc
        @allow_other_validations = true
        instance_eval &blok
        @allow_other_validations = false
      end
    end

    def method_missing *args 
      if args.size == 1 
        return @val if args.first == col
        return @original_val if args.first.to_s == "original_#{col}"
      end
      super(*args)
    end

    # ==== PRIVATE METHODS ======================
    private

    def _add_to_errors_ msg
      
      @doc.errors << msg
      
      if self.only_one_more_error_allowed
        raise NoErrorsAllowed, "No more errors allowed."
      end
      
      msg

    end
    
    def _choose_and_add_error_msg_ msg, &blok
    end

    def _col_human_name
    end


    public # =========================


    # === SETTING RELATED METHODS ====

    def allow_set?
      @allow_set
    end

    def dont_set
      @allow_set = false
    end

    def dont_set_if &blok
      result = instance_eval &blok
      dont_set if result
      allow_set?
    end

    def set_to new_val
      @val = new_val
    end

    def override &blok
      dont_set
      instance_eval &blok
    end

    def set_other(col, new_val = nil, &blok)
      if new_val && block_given?
        raise ArgumentError, ":new_val and :blok must not be both set." 
      end
      @doc.new_values[col.to_sym] = if block_given?
        instance_eval &blok
      else
        new_val
      end
    end

    # === MISCELLANEOUS METHODS ====
    
    def after &blok
      @after_proc = blok
    end

    def validate(new_col)
      if allow_other_validations
        self.class.validate(doc, new_col)
      end
    end

    def default_error_msg( msg )
      @default_error_msg = msg
    end
   
    # Executes even if :doc has pre-existing errors.
    # Executes block and stops when :doc errors encounters
    # the first error in the blok.
    def detect &blok
      self.only_one_more_error_allowed = true
      instance_eval &blok
      self.only_one_more_error_allowed = false
      nil
    end

    # === TIME METHODS ====

    def to_datetime(time_or_str)
      CouchPlastic.time_string(time_or_str)
    end

    def to_datetime_or_now(nil_or_time_or_str)
      v = nil_or_time_or_str
      v ? to_datetime(v) : CouchPlastic.utc_now
    end

    # === ARRAY METHODS ====

    def if_in(arr, &blok)
      if arr.include?(@val)
        instance_eval &blok
      else
        false
      end
    end

    def if_not_in(arr, &blok)
      if !arr.include?(@val)
        instance_eval &blok
      else
        false
      end
    end

    # === STRING METHODS ====

    def symbolize
      @val = @val.to_s.to_sym
    end

    def must_be_string &err_msg_blok
      
      if !@val.is_a?(String)
        msg =  "#{@doc.human_name(@col)} must not be empty."
        _choose_and_add_error_msg_( msg, &err_msg_blok )
        return false
      end

      true

    end

    # Turns :val into a stripped string if it does not
    # respond to :size.
    def min_size( size, &blok )
      strip if !@val.respond_to?(:size)
      return true if @val.size >= size 

      msg = "#{_col_human_name_} needs to be at least #{size} characters in length."
      _choose_and_add_error_msg_(msg, &blok)
      false
    end

    # Turns :val into a stripped string if it does not
    # respond to :size.
    def between_size( min, max, &blok ) 
      strip if !@val.respond_to?(:size)
      return true if @val.size.between?(min, max)

      msg = "#{_col_human_name_} needs to be between #{min} and #{max} characters in length."
      _choose_and_add_error_msg_(msg, &blok)
      false
    end

    def strip
      @val = @val.to_s.strip
    end

    def match(s_or_regex, &err_msg_blok)

      they_match = case s_or_regex
        when String
          msg = "#{_col_human_name_} must match #{s_or_regex}."
          @val == s_or_regex
        when Regex
          msg = "#{_col_human_name_} is invalid."
          @val =~ s_or_regex
      end

      return true if they_match
      _choose_and_add_error_msg_(msg, &err_msg_blok)
      false

    end
    
    def clean_with regex, &blok_for_regex
      @val = @val.gsub(regex, '', &blok_for_regex)
    end



  end # ==== class Validator

end # ==== module CouchPlastic
