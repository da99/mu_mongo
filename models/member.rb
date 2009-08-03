# ==================================================
#
# ==================================================
class Member < Sequel::Model
  
  # =========================================================
  #                     CONSTANTS
  # =========================================================  

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
  def self.authenticate(username, pass, ip_address)
      target_member = self[:username => username]

      unless target_member
        LoginAttempt.log_failed_attempt( ip_address )
        raise Member::NoRecordFound, "#{username} was not found." 
      end

      is_correct_password = Member.encrypt(pass, target_member.salt).eql?( target_member.hashed_password )
      return target_member if is_correct_password

      LoginAttempt.log_failed_attempt( ip_address )

      raise IncorrectPassword
  end 
        
  def self.create_it( raw_params, editor)
    allowed_params = case editor
      when nil
        filter_params( raw_params,  [ :password, :confirm_password ] )
      else
        {}
    end
    
    new_record = self.new
    new_record.set new_record.validate_new_values( allowed_params, allowed_params.keys )
    new_record.save
    
  end # === def self.create_it
  
  # =========================================================
  #                    Instance Methods
  # ========================================================= 
  
  def update_it( raw_params, editor )
    allowed_params = case editor
      when self
        self.class.filter_params( raw_params,  [ :password, :confirm_password ] )
      else
        if editor.has_permission_level?(ADMIN)
          self.class.filter_params( raw_params,  [ :permission_level ] )
        else
        {}
        end
    end
    
    return if allowed_params.empty?
    
    update validate_new_values( allowed_params, allowed_params.keys )

  end # === update_it
  
  def validate_new_values( raw_params, keys )
    clean_params = {}
    
    keys.each { |k|
      case k
        when :permission_level
            if !SECURITY_LEVELS.include?(target_perm_level)
              raise ArguementError, "#{raw_params[k]} is not a valid permission level."  
            end
            clean_params[:permission_level] 
        when :password
          errors[:password] << "Password and password confirmation do not match." if pass != pass_confirm   
          errors[:password] << "Password must be longer than 5 characters." if pass.length < 5   
          errors[:password] << "Password must have at least one number." if !pass[/0-9/]
          if errors[:password].empty?
            clean_params[:salt] = begin
              chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
              (1..10).inject('') { |new_pass, i|  
                new_pass << chars[rand(chars.size-1)] 
              }
            end
            
            clean_params[:hashed_password] = Digest::SHA1.hexdigest(pass+salt)
          end # === if
      end # === case
    }
    
    clean_params
  end # === def
 
  
  def has_permission_level?(raw_level)
      target_perm_level = raw_level.instance_of?(Symbol) ? 
                            self.class.const_get(raw_level) : 
                            Integer(raw_level) ;
                            
      if !SECURITY_LEVELS.include?(target_perm_level)
        raise UnknownPermissionLevel, "#{raw_level.inspect} is not a valid permission level." 
      end
      
      case target_perm_level
        when STRANGER
          true
        when MEMBER
          new? ? false : true
        when ADMIN
          self[:id] === 1
      end
  end # ===   

end # Member
########################################################################################
