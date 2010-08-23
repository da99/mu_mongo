require 'models/Delegator_DSL'

module BASE_MAB
  
  Method_Overload = Class.new(RuntimeError)

  extend Delegator_DSL

  delegate_to "config.get",        :rings_used
  delegate_to "config.get_or_put", :ring

  def config
    @config ||= \
      Config_Switches.new {
        levels :ring, Club::MEMBERS, nil
      }
  end

  def send_within_ring level, meth_name, *args, &blok
    target = "#{level}_#{meth_name}"
    omni   = "omni_#{meth_name}"
    
    target_def = respond_to?(target)
    omni_def   = respond_to?(omni)

    final = if target_def && omni_def
              raise Method_Overload, "Can't define both: #{target}, #{omni}"
            elsif omni_def
              omni
            else
              target
            end
    
    send(final, *args, &blok)
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
            send_within_ring("#{level}", "\#{meth.first}", *(meth[1]), &(meth.last))
          }
        end
        
        ring nil
      end
    ~
  }

  [ %w{ member insider }, %w{ insider owner } ].each { |first, second|
    eval %~
      def #{first}_or_#{second} &blok
        #{first} &blok
        #{second} &blok
      end
    ~
  }

end # === module





