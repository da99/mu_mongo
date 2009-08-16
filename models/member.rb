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

  
  # =========================================================
  #                    Instance Methods
  # ========================================================= 
  
  def_alter( :create ) do
    allow_any_stranger
    required_fields :password
  end # === def self.create_it!  
  
  def_alter( :after_create ) do
    un = Username.new
    un.raw_data=( {:owner_id=>self[:id]}.merge(raw_data) )
  end
  
  
  def_alter( :update ) do
  
    allow_only self, :ADMIN
    
    if raw_data[:EDITOR] == self
        optional_fields :password
    elsif raw_data[:EDITOR].admin?
        optional_fields :permission_level
    end    
    
  end # === def update_it!
  
    
  def_setter( :password, :force ) { |raw_params |
      fn = :password
      pass = raw_params[ fn ].to_s.strip
      confirm_pass = raw_params[:confirm_password].to_s.strip
      
      if pass.empty?
        self.errors[fn] << "Password is required."
      else
        self.errors[fn] << "Password and password confirmation do not match." if pass != confirm_pass 
        self.errors[fn] << "Password must be longer than 5 characters." if pass.length < 5   
        self.errors[fn] << "Password must have at least one number." if !pass[/[0-9]/]
      end

      return nil if !self.errors[fn].empty?
      
      # Salt and encrypt values.
      self[:salt] = begin
                      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
                      (1..10).inject('') { |new_pass, i|  
                        new_pass += chars[rand(chars.size-1)] 
                        new_pass
                      }
                    end
      
      self[:hashed_password] = Digest::SHA1.hexdigest(pass+salt)
      pass_confirm
      
  } # === def set_password
  
  
  def_setter( :permission_level ) { |raw_params |
    fn = :permission_level
    new_level = raw_params[fn]
    if !SECURITY_LEVELS.include?(new_level)
      raise InvalidPermissionLevel, "#{new_level} is not a valid permission level."  
    end
    
    self[fn] = new_level
    
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
        when self
          true
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
  
end # Member
########################################################################################
