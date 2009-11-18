
def allow(class_obj, &blok) 

  ActionDSL.new(self, class_obj, blok)

end

get '/options/' do
  ActionDSL::ACTIONS.inject('') { |m,a|
    m += a.inspect + '<br /><pre>' + options.send("news_#{a}").inspect + '</pre>'
    m
  }
end

configure do 
  class ActionDSL

    ACTIONS = [:new, :show, :edit, :create, :update, :delete].uniq

    def initialize scope, class_obj, blok
      @class_obj = class_obj
      @app_scope = scope
      instance_eval &blok
    end

    def reset
      @options = { :require_log_in => true,
        :class=>@class_obj
      }
    end

    ACTIONS.each { |a|
      eval("
        def #{a} &blok
          reset
          set_action #{a.inspect}
          if block_given? 
            instance_eval &blok
          end
          configure {
            set @class_obj.to_s.underscore + '_' + action.to_s, @options
          }
        end
      ")
    } 

    def success_msg msg=nil, &blok
      @options[:success_msg] = msg || blok
    end

    def error(*errs, &blok)
      @options[:rescue] = {}
      errs.each { |e|
        case e
          when Symbol
            e_class = case e
              when :no_record
                @class_obj.const_get((e.to_s + '_found').camelize)
              when :unauthorized
                @class_obj.const_get((e.to_s + '_' + manipulator_name.to_s).camelize)
              else
                @class_obj.const_get(e.to_s.camelize)
            end
            e_class = 
            @options[:rescue][e_class] = blok
          when String
            raise ArgumentError, "Strings are not allowed here: #{e.inspect}"
          else
            @options[:rescue][e] = blok
        end
      }
    end

    def redirect path=nil, &blok
      @options[:redirect] = path || blok
    end

    attr_reader :action

    def set_action  action_name
      if !ACTIONS.include?(action_name)
        raise ArgumentError, action_name.inspect
      end
      @action = action_name
    end

    def manipulator_name
      case action
        when :new
          :new
        when :create
          :creator
        when :updator
          :updator
        when :edit
          :editor
        when :show
          :reader
        when :delete
          :deletor
      end
    end

  end # === class ActionDSL 
end # === configure

configure {

  class RogerRoger
    attr_accessor :config
    def initialize &blok
      self.config = {}
      instance_eval &blok
    end
    def method_missing *args, &blok
      self.config[args.shift] = [args, blok ]
    end
    def to_hash
      self.config
    end
  end

  

} # configure

class Validator
  def initialize(obj, col, &blok)
    @obj = obj
    @val = obj.send(col)
    instance_eval &blok 
  end
  def success_msg(msg=nil, &blok)
    @obj.success << "#{@val}: #{msg}" if !block_given?
    @obj.success << (instance_eval &blok) if block_given?
  end
  def failure(msg=nil, &blok)
    @obj.errors << "#{@val}: #{msg}" if !block_given?
    @obj.errors << (instance_eval &blok) if block_given?
  end
  def select_error(*args, &blok)
    instance_eval &blok
  end
end

class Tester

  class << self

    def validators
      @validators ||= {}
    end

    def setter col, &blok
      validators[col] = blok
    end

  end

  setter(:name) {
    success_msg "Ok"
    select_error {
      success_msg "Not ok"
    }
    failure {
      "failed"
    }
  }

  setter(:family_name) {
    success_msg "Ok"
  }

  def errors
    @errors ||= []
  end

  def success
    @success ||= []
  end

  def name
    "Ted"
  end

  def family_name
    "Danson"
  end

  def validate
    self.class.validators.each { |k,v| 
      Validator.new(self, k, &v)
    }
  end

end

def test_roger
  a = Tester.new
  a.validate
  [a.success, a.errors]
end


module CouchPlastic

  class Validator

    # === SPECIAL METHODS ====
    
    def validator(new_col, &blok)
      # Must inherit existing values
      # of current Validator.
      # Example: Member, :add_life + :add_life_username
    end

    def default_error_msg( msg )
    end
    
    def detect &blok
    end

    def set_to new_val
    end

    def override &blok
    end

    def set_other(col, val = nil, &blok)
    end

    def dont_set_if &blok
    end

    # === TIME METHODS ====

    def to_datetime(s)
    end

    def to_datetime_or_now
    end

    # === ARRAY METHODS ====

    def if_in(arr, &blok)
    end

    def if_not_in(arr, &blok)
    end

    def select_error &blok
    end

    # === STRING METHODS ====

    def symbolize
    end

    def must_be_string
    end

    def min_size( size )
    end

    def between_size( min, max ) 
    end

    def strip
    end

    def match(s_or_regex, &err_msg_blok)
    end
    
    def clean_with regex, &blok_for_regex
    end

    def match_original_after_cleaning(regex, &err_msg)
    end

  end

end
