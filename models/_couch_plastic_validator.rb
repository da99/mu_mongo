module CouchPlastic


  # =========================================================
  #               Validation-related Methods
  # ========================================================= 

  def validate
    SetterDSL.new self
    raise_if_invalid
  end

  def errors
    @errors ||= []
  end

  def raise_if_invalid
    
    if !errors.empty? 
      raise Invalid.new( self, "Document has validation errors." )
    end

    if new_data.empty?
      raise NoNewValues, "No new data to save."
    end

    true

  end 

  # =========================================================
  #                  Module: ClassMethods
  # ========================================================= 

  module ClassMethods
   
    def setter_actions
      @crud_tailors ||= {:create=>nil,:update=>nil, :read=>nil, :delete=>nil}
    end

    def setter action, &blok
      if setter_actions[action]
        raise ArgumentError, "Already used: #{action.inspect}" 
      end
      setter_actions[action] = blok
    end

    def validator_actions
      @validator_actions ||= {}
    end

    def validator *cols, &blok
      col = cols.first
      if validator_actions[col]
        raise ArgumentError, "Validator already exists for: #{col.inspect}"
      end
      validator_actions[col] = [cols, blok]
    end 

  end # === module ClassMethods

 
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

      if !current_editor && member_level == Member::STRANGER
        instance_eval &blok 
      elsif current_editor && current_editor.has_power_of?(member_level)
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
  #   Implements the Validator DSL for CouchPlastic models.
  # =========================================================

  class ValidatorDSL

    READERS = [ 
      :doc, :col, :val, :original_val,
      :allow_set, :allow_other_validations, :after_proc,
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
      self.only_one_more_error_allowed = true

      self.allow_other_validations     = false

      instance_eval &(doc.class.validator_actions[col][1])

      if allow_set?
        doc.new_data[self.col] = self.val
      end

      if after_proc?
        self.allow_other_validations = true
        instance_eval &blok
        self.allow_other_validations = false
      end

    end

    def method_missing *args 
      if args.size == 1 
        return val if args.first == col
        return original_val if args.first.to_s == "original_#{col}"
      end
      super(*args)
    end


    private # ==== PRIVATE METHODS ======================


    def _add_to_errors_ msg
      @doc.errors << msg
      raise NoErrorsAllowed, "---" if self.only_one_more_error_allowed?
      msg
    end
    
    def _choose_and_add_error_msg_ raw_msg = nil, &blok
      msg = [ 
        default_error_msg,
        block_given?  && instance_eval( &blok ),
        raw_msg
      ].detect { |m| m }

      _add_to_errors_ msg
    end

    def _cap_col_name_
      doc.human_name(col).capitalize
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

      new_col = col.to_sym

      if new_val && block_given?
        raise ArgumentError, ":new_val and :blok must not be both set." 
      end

      result = block_given? ? 
                instance_eval( &blok ) :
                new_val

      @doc.new_data[new_col] = result
    end

    # === MISCELLANEOUS METHODS ====
    
    def after &blok
      self.after_proc = blok
    end

    def validate(new_col, &blok)
      if allow_other_validations
        self.class.new(doc, new_col, &blok)
      end
    end

    def default_error_msg( msg )
      @default_error_msg = msg
    end
   
    # Executes even if :doc has pre-existing errors.
    # Executes block and stops when the first
    # error in the blok is encountered.
    def detect &blok
      self.only_one_more_error_allowed = true
      instance_eval &blok
      self.only_one_more_error_allowed = false
      nil
    end

    # === TIME METHODS ====

    def to_datetime(time_or_str)
      @val = CouchPlastic::Helper.time_string(time_or_str)
    end

    def to_datetime_or_now(nil_or_time_or_str = nil)
      v = nil_or_time_or_str
      @val = v ? to_datetime(v) : CouchPlastic::Helper.utc_now_as_string
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
        msg = "#{_cap_col_name_} must not be empty"
        _choose_and_add_error_msg_( msg, &err_msg)
      end
      true
    end

    def must_be_string &err_msg_blok
      
      if !@val.is_a?(String)
        msg =  "#{_cap_col_name_} must not be empty."
        _choose_and_add_error_msg_( msg, &err_msg_blok )
        return false
      end

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
    def between_size( min, max, &blok ) 
      strip if !@val.respond_to?(:jsize)
      return true if @val.jsize.between?(min, max)

      msg = "#{_cap_col_name_} needs to be between #{min} and #{max} characters in length."
      _choose_and_add_error_msg_(msg, &blok)
      false
    end

    def match(s_or_regex, &err_msg_blok)

      they_match = case s_or_regex
        when String
          msg = "#{_cap_col_name_} must match #{s_or_regex}."
          @val == s_or_regex
        when Regex
          msg = "#{_cap_col_name_} is invalid."
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
