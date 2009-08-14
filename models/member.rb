# ==================================================
#
# ==================================================
class Member < Sequel::Model
  
  # =========================================================
  #                     CONSTANTS
  # =========================================================  

  class IncorrectPassword < RuntimeError; end
  class InvalidPermissionLevel < RuntimeError; end
  
  NO_ACCESS   = -1000
  ADMIN       = 1000
  EDITOR      = 10
  MEMBER      = 1
  STRANGER    = 0 # Used mainly by other classes/objects to identity
                  # someone who is unknown or not logged in.
                  
  SECURITY_LEVELS   = [ NO_ACCESS, ADMIN , MEMBER , EDITOR, STRANGER ]
  
  # =========================================================
  #                   ASSOCIATIONS
  # =========================================================  
  one_to_many :usernames, :key=>:owner_id
  
    
  # =========================================================
  #                      HOOKS
  # =========================================================

  
  # =========================================================
  #               Hooks to Other Classes 
  # =========================================================

                  

  # =========================================================
  #                     Class Methods.
  # =========================================================

  # === See: Sinatra-authentication (on github)
  # Raises: LoginAttempt::TooManyFailedAttempts based on ip_address.
  # Raises: Member::IncorrectPassword
  def self.authenticate(username, pass, ip_address)
      target_member = self[:username => username]

      unless target_member
        LoginAttempt.log_failed_attempt( ip_address )
        raise NoRecordFound, "#{username} was not found." 
      end

      is_correct_password = Digest::SHA1.hexdigest(pass + target_member.salt).eql?( target_member.hashed_password )
      return target_member if is_correct_password

      LoginAttempt.log_failed_attempt( ip_address )

      raise IncorrectPassword, "Try again."
  end # === self.authenticate
  
  
  def self.create_it!( raw_params )
      
    mem = new
    
    mem.require_fields raw_params, :password
    
    # Save and create username.
    if mem.save_it!( raw_params )
      un_vals = { :owner_id=>mem[:id] }.merge( raw_params )
      Username.create_it!( un_vals  )
      mem
    end
    
  end # === def self.create_it!
  
  # =========================================================
  #                    Instance Methods
  # ========================================================= 
  
  def update_it!( raw_params )
  
    case raw_params[:EDITOR]
      when self
        optional_fields( raw_params,  :password  )
      else
        if editor.admin?
          optional_fields( raw_params,  :permission_level  )
        end
    end
    
    save_it! raw_params

  end # === def update_it!
  
  
  def has_permission?( action, editor )
    case action
      when :create
        true
      when :update
        self == editor || ( editor && editor.admin? )
      else 
        false
    end 
  end
  
  
  def_set_meth( :password, :force ) { |rec, fn,  raw_params |
      pass = raw_params[ fn ].to_s.trim
      confirm_pass = raw_params[:confirm_password].to_s.trim
      
      if pass.empty?
        rec.errors[fn] << "Password is required."
      else
        rec.errors[fn] << "Password and password confirmation do not match." if pass != confirm_pass 
        rec.errors[fn] << "Password must be longer than 5 characters." if pass.length < 5   
        rec.errors[fn] << "Password must have at least one number." if !pass[/0-9/]
      end

      return nil if !rec.errors[fn].empty?
      
      # Salt and encrypt values.
      rec[:salt] = begin
                      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
                      (1..10).inject('') { |new_pass, i|  
                        new_pass += chars[rand(chars.size-1)] 
                        new_pass
                      }
                    end
      
      rec[:hashed_password] = Digest::SHA1.hexdigest(pass+salt)
      pass_confirm
      
  } # === def set_password
  
  
  def_set_meth( :permission_level ) { |rec, fn, raw_params |
  
    new_level = raw_params[fn]
    if !SECURITY_LEVELS.include?(new_level)
      raise InvalidPermissionLevel, "#{new_level} is not a valid permission level."  
    end
    
    rec[fn] = new_level
    
  } # === def set_permission_level
  
  
  def admin?
    has_power_of?(:ADMIN)
  end
  
  
  def editor?
    has_power_of?(:EDITOR)
  end
  
  
  def has_power_of?(raw_level)
      
      # Let's turn raw value into a proper instance:
      # 1000 => 1000
      # :ADMIN => 1000
      target_perm_level = raw_level.instance_of?(Symbol) ? 
                            self.class.const_get(raw_level) : 
                            Integer(raw_level) ;
                                  
      case target_perm_level
        when STRANGER
          true
        when MEMBER
          new? ? false : true
        when ADMIN
          self[:id] === 1
        when EDITOR
          self[:permission_level] === EDITOR
        else
          raise InvalidPermissionLevel, "#{raw_level.inspect} is not a valid permission level." 
      end
      
  end # === def security_clearance?


end # Member
########################################################################################
