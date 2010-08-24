require 'models/Delegator_DSL'
require 'models/Sentry_Sender'

module BASE_MAB
  
  Method_Overload = Class.new(RuntimeError)
  RINGS = Club::MEMBERS

  extend Delegator_DSL

  delegate_to "config.get",        :rings_used
  delegate_to "config.get_or_put", :ring

  def config
    @config ||= \
      Config_Switches.new {
        levels :ring, Club::MEMBERS, nil
      }
  end

  def method_missing meth_name, *args, &blok
    target = "#{ring}_#{meth_name}"
    omni   = "omni_#{meth_name}"
    
    target_def = respond_to?(target)
    omni_def   = respond_to?(omni)

    final = if target_def && omni_def
              raise Method_Overload, "Can't define both: #{target}, #{omni}"
            elsif omni_def
              omni
            elsif target_def
              target
            else
              nil
            end
    
    wrapper_meth = "#{meth_name}_wrapper"
    return(send(wrapper_meth, *args, &blok)) if !final && respond_to?(wrapper_meth)
    return(super) if not final
    send(final, *args, &blok)
  end

  def send_to_current_ring *args, &blok
    send_within_ring ring, *args, &blok
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

  def everybody &blok
    RINGS.each { |rg|
      send rg, &blok
    }
  end

  Club::MEMBERS.each { |level|
    args = %~
    "\#{meth.first}", *(meth[1]), &(meth.last)
    ~.strip

    eval %~
      def #{level} &blok
        ring :#{level}
        
        instance_eval &blok
        
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

  def _guide txt, &blok
    div.section.guide do
      h3 txt
      blok.call
    end
  end

  def _about header, body
    div.section.about {
      h3 header.m!
      div.body body.m!
    }
  end
  
  def about! &blok
    div.col.about! &blok
  end
 
  def publish! &blok
    div.col.publish! &blok
  end 
  
end # === module





