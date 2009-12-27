module Couch_Plastic


  # =========================================================
  #               Validation-related Methods
  # ========================================================= 

  def clean field, &blok
    v = Cleaner_Dsl.new( human_field_name(field), raw_data[field] )
    begin
      v.execute blok
      clean_data[field] = v.options.clean
    rescue Cleaner_Dsl::Invalid
      v.errors.each { |err|
        errors << err
      }
      raise_if_invalid
    end
  end

  def clean_and_set field, &blok
    new_val = clean(field, &blok)
    new_data.send( "#{field}=", new_val)
  end
  
  def clean_but_ignore_errors field, &blok

    v = Cleaner_Dsl.new( human_field_name(field), raw_data[field] )
    begin
      v.execute blok
      v.options.clean
    rescue Cleaner_Dsl::Invalid
      raise_if_invalid
    end

  end

  def errors
    @errors ||= []
  end

  def raise_if_invalid
    
    if !errors.empty? 
      raise Invalid.new( self, "Document has validation errors." )
    end

    if new_data.as_hash.empty?
      raise NoNewValues, "No new data to save."
    end

    true

  end 


end # ==== module Couch_Plastic

__END__


  # =========================================================
  #                  Module: ClassMethods
  # ========================================================= 

  # =========================================================
  #                  Module: ClassMethods
  # ========================================================= 


  # module ClassMethods
  #  
    # def setter_actions
    #   @crud_tailors ||= {:create=>nil,:update=>nil, :read=>nil, :delete=>nil}
    # end

    # def setter action, &blok
    #   if setter_actions[action]
    #     raise ArgumentError, "Already used: #{action.inspect}" 
    #   end
    #   setter_actions[action] = blok
    # end

    # def validator_actions
    #   @validator_actions ||= {}
    # end

    # def validator *cols, &blok
    #   col = cols.first
    #   if validator_actions[col]
    #     raise ArgumentError, "Validator already exists for: #{col.inspect}"
    #   end
    #   validator_actions[col] = [cols, blok]
    # end 
# 
#   end # === module ClassMethods

  # =========================================================
  #                  Class: SetterDSL
  # =========================================================  
  
  class SetterDSL

    def initialize new_doc
      @doc = new_doc
      @doc_class = new_doc.class
      if @doc.new?
        instance_eval &@doc_class.setter_actions[:create]
      else
        instance_eval &@doc_class.setter_actions[:update]
      end
    end
	
		def doc
			@doc
		end

    def from raw_member_level, &blok

      member_level = case raw_member_level
        when :self
          self
        when Symbol
          if @doc.respond_to?(raw_member_level)
            @doc.send raw_member_level
          else
            raw_member_level
          end
        else
          raw_member_level
      end

      if !@doc.manipulator && member_level == Member::STRANGER
        instance_eval &blok 
      elsif @doc.manipulator && @doc.manipulator.has_power_of?(member_level)
        instance_eval &blok
      else 
        # Do nothing.
      end

    end

    def demand *cols
      cols.flatten.each { |k|
        ValidatorDSL.new @doc, k
      }
    end
    
    def ask_for *cols
      cols.flatten.each { |k|
        if @doc.raw_data.has_key?(k)
          ValidatorDSL.new @doc, k
        end
      }
    end  

  end # === class SetterDSL


  # =========================================================
  #   Implements the Validator DSL for Couch_Plastic models.
  # =========================================================

  class ValidatorDSL

    class No_More_Errors < StandardError; end

    READERS = [ 
      :doc, :col, :val, :original_val,
      :allow_set, :after_proc,
      :default_error_msg,
      :only_one_more_error_allowed 
    ]
    
    private  # ============================================== 
      attr_writer *READERS

      READERS.each { |sym|
        eval(%~
          def #{sym}?
            @#{sym}
          end
        ~);
      }

    public  # ==============================================
      attr_reader *READERS

    def initialize(raw_doc, raw_col)

      self.doc                         = raw_doc
      self.col                         = raw_col.to_sym
      self.val                         = doc.raw_data[col]
      self.original_val                = val
      
      self.allow_set                   = true
      self.only_one_more_error_allowed = false

      instance_eval &(doc.class.validator_actions[col][1])

      self.doc.clean_data[self.col] = self.val

      if allow_set?
        doc.new_data.send(self.col.to_s + '=', self.val)
      end

      instance_eval &after_proc if after_proc?

    end

    def method_missing *args 
      if args.size == 1 
        meth_name = args.first
        return val if meth_name == col
        return original_val if meth_name.to_s == "original_#{col}"
        return doc.new_data.send(meth_name) if doc.new_data.has_key?(meth_name)
        return doc.clean_data[meth_name] if doc.clean_data.has_key?(meth_name)
      end
      super(*args)
    end


    private # ==== PRIVATE METHODS ======================


    def _add_to_errors_ msg
      @doc.errors << msg
      raise No_More_Errors, "---" if only_one_more_error_allowed?
      msg
    end
    
    def _choose_and_add_error_msg_ *msgs, &blok
      msg = ([ 
        default_error_msg,
        block_given?  && instance_eval( &blok ),
      ] + msgs).detect { |m| m }

      _add_to_errors_ msg
    end

    def _cap_col_name_
      doc.human_field_name(col).capitalize
    end

    public # =========================


    # === SETTING RELATED METHODS ====

    def dont_set
      self.allow_set = false
    end

    def dont_set_if &blok
      dont_set if instance_eval( &blok )
      allow_set?
    end

    def set_to new_val
      self.val = new_val
    end

    def override &blok
      dont_set
      instance_eval &blok
    end

    def set_other(raw_col, new_val = nil, &blok)

      new_col = raw_col.to_sym

      if new_val && block_given?
        raise ArgumentError, ":new_val and :blok must not be both set." 
      end

      result = block_given? ? 
                instance_eval( &blok ) :
                new_val

      @doc.new_data.as_hash[new_col] = result
    end

    # === MISCELLANEOUS METHODS ====
    
    def after &blok
      self.after_proc = blok
    end

    def validate new_col
      if block_given?
        raise ArgumentError, "This method does not accept a block."
      end
      self.class.new @doc, new_col
    end

    def default_error_msg( *args )
      case args.size
        when 0
          @default_error_msg
        when 1
          @default_error_msg = msg
        else
          raise ArgumentError, "Only 0 or 1 args allowed: #{args.inspect}"
      end
    end
   
    # Executes even if :doc has pre-existing errors.
    # Executes block and stops when the first
    # error in the blok is encountered.
    def detect &blok
      self.only_one_more_error_allowed = true
      begin
        instance_eval &blok
      rescue No_More_Errors
      end
      self.only_one_more_error_allowed = false
      nil
    end

    def if_not_new &blok
      return false if @doc.new?
      instance_eval &blok
    end

    # === TIME METHODS ====

    def to_datetime(time_or_str)
      @val = Couch_Plastic::Helper.time_string(time_or_str)
    end

    def to_datetime_or_now(nil_or_time_or_str = nil)
      v = nil_or_time_or_str
      @val = v ? to_datetime(v) : Couch_Plastic::Helper.utc_now_as_string
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
      return true if @val.is_a?(Symbol)
      if !@val.is_a?(String)
        raise ArgumentError, "#{col.inspect} has to be either a String or Symbol."
      end

      if @val.empty?
        raise ArgumentError, "Can't use symbolize on an empty string: #{col.inspect}" 
      end
      @val = @val.to_s.to_sym
    end

    def strip
      @val = @val.to_s.strip
    end

    def split
      if !@val.is_a?(Array)
        @val = @val.to_s.split
      end
    end

    def must_not_be_empty &err_msg
      if @val.empty?
        msg = "#{_cap_col_name_} is required."
        _choose_and_add_error_msg_( msg, &err_msg)
      end
      true
    end

    def must_be_string &err_msg_blok
      if !@val.is_a?(String)
        raise "Programmer Error: #{col.inspect} must be a string."
      end

      msg =  "#{_cap_col_name_} ."
      _choose_and_add_error_msg_( msg, &err_msg_blok )

      true
    end

    # Turns :val into a stripped string if it does not
    # respond to :size.
    def min_size( size, &blok )
      strip if !@val.respond_to?(:jsize)
      return true if @val.jsize >= size 

      msg = "#{_cap_col_name_} needs to be at least #{size} characters in length."
      _choose_and_add_error_msg_(msg, &blok)
      false
    end

    # Turns :val into a stripped string if it does not
    # respond to :size.
    def between_size( min, max, str = nil, &blok ) 
      strip if !@val.respond_to?(:jsize)
      return true if @val.jsize.between?(min, max)

      msg = "#{_cap_col_name_} needs to be between #{min} and #{max} characters in length."
      _choose_and_add_error_msg_((str && str % [min, max]), msg, &blok)
      false
    end

    def match(s_or_regex, err_msg = nil,  &err_msg_blok)

      they_match = case s_or_regex
        when String
          msg = "#{_cap_col_name_} must match #{s_or_regex}."
          @val == s_or_regex
        when Regexp
          msg = "#{_cap_col_name_} is invalid."
          @val =~ s_or_regex
      end

      return true if they_match
      _choose_and_add_error_msg_(err_msg, msg, &err_msg_blok)
      false

    end
    
    def clean_with regex, &blok_for_regex
      @val = if block_given?
        @val.gsub(regex, &blok_for_regex)
      else
        @val.gsub(regex, '')
      end
    end


  end # ==== class Validator

