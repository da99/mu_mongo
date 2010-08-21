require 'models/Delegator_DSL'

module BASE_MAB
  
  extend Delegator_DSL

  delegate_to "config.get", :rings_used
  delegate_to "config.get_or_put", :ring

  def config
    @config ||= Config_Switches.new {
      levels :ring, Club::MEMBERS, nil
    }
  end

  def send_with_security_level level, meth_name, *args, &blok
    
    method_should_exists = Club::MEMBERS.detect { |perm|
                              respond_to?("#{perm}_#{meth_name}")
                            }
    
    method_name = if method_should_exists
                    "#{level}_#{meth_name}"
                  else
                    "omni_#{meth_name}"
                  end
    
    send(method_name, *args, &blok)
  end
  
  def ensure_no_one_left
    left = Club::MEMBERS - rings_used
    raise "Security levels not used: #{left.inspect}" unless left.empty?
    true
  end

  Club::MEMBERS.each { |level|
    eval %~
      def #{level} &blok
        ring :#{level}
        
        gath = Gather.new(&blok)
        show_if '#{level}?' do
          gath.meths.each { |meth|
            send_with_security_level("#{level}", "\#{meth.first}", *(meth[1]), &(meth.last))
          }
        end
        
        ring nil
      end
    ~
  }

end # === module
