require 'bcrypt'


# ==================================================
#
# ==================================================
class Member < Sequel::Model
  
  # =========================================================
  #                     CONSTANTS
  # =========================================================  

  class IncorrectPassword < StandardError; end
  class InvalidPermissionLevel < StandardError; end
  
  SECURITY_LEVELS_HASH = { :NO_ACCESS   => -1000,
                           :ADMIN       => 1000,
                           :EDITOR      => 10,
                           :MEMBER      => 1,
                           :STRANGER    => 0 }

  SECURITY_LEVELS      = SECURITY_LEVELS_HASH.values
  SECURITY_LEVEL_NAMES = SECURITY_LEVELS_HASH.keys
  SECURITY_LEVELS_HASH.each do |k,v|
    const_set k, v
  end
  
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
  # Raises: Member::IncorrectPassword
  def self.validate_username_and_password( username, pass )
      un = Username[:username => username]
      
      raise NoRecordFound, "#{username} was not found." if !un
      
      return un.owner if BCrypt::Password.new(un.owner.hashed_password) === (pass + un.owner.salt) 

      raise IncorrectPassword, "Try again."
  end # === self.authenticate

  
  # =========================================================
  #                    Instance Methods
  # ========================================================= 

  # Future versions of Sequel may alter implementation of :inspect.
  # By using a custom implementation, we cane make sure
  # the customized version of :inspect_values is always used.
  def inspect
    "#<#{model.name} @values=#{inspect_values.inspect}>"
  end
  
  # Default :inspect_values is 
  # over-ridden to prevent :hashed_password and :salt 
  # from being displayed.
  def inspect_values
    safe_values = values.clone
    safe_values.delete :hashed_password
    safe_values.delete :salt
    safe_values
  end

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
                            raw_level ;
                                  
      case target_perm_level
        when self
          true
        when NO_ACCESS
          false
        when STRANGER
          true
        when MEMBER
          new? ? false : true
        when ADMIN
          self == Member.first && self[:permission_level] == ADMIN
        when EDITOR
          self[:permission_level] === EDITOR
        else
          raise InvalidPermissionLevel, "#{raw_level.inspect} is not a valid permission level." 
      end
      
  end # === def security_clearance?


  # ================= AUTHORIZATIONS ========================


  allow_creator STRANGER do
    require_columns :password
  end
  
  def after_create
    Username.creator self, raw_data
  end # === def after_create
  
  allow_updator :self do
    optional_columns :password
  end

  allow_updator ADMIN do 
    optional_columns :permission_level
  end    
  

  # =============== VALIDATORS =============================


  validator :password do
    fn = :password
    pass = raw_data[ fn ].to_s
    confirm_pass = raw_data[:confirm_password].to_s.strip
    
    self.errors.add( fn, "and password confirmation do not match.") if pass != confirm_pass 
    self.errors.add( fn, "must be longer than 5 characters.") if pass.length < 5   
    self.errors.add( fn, "must have at least one number.") if !pass[/[0-9]/]

    return nil if !self.errors[fn].empty?
    
    # Salt and encrypt values.
    self[:salt] = begin
                    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
                    (1..10).inject('') { |new_pass, i|  
                      new_pass += chars[rand(chars.size-1)] 
                      new_pass
                    }
                  end
    
    self[:hashed_password] = BCrypt::Password.create( pass + self[:salt] ).to_s
    confirm_pass
      
  end # === def set_password
  
  
  validator :permission_level do
    fn = :permission_level
    new_level = raw_data[fn]
    if !SECURITY_LEVELS.include?(new_level)
      raise InvalidPermissionLevel, "#{new_level} is not a valid permission level."  
    end
    
    self[fn] = new_level
    
  end # === def set_permission_level
  

  
  
end # Member


__END__

  # =========================================================
  # Returns the time passed to it to the Member's local time
  # as a String, formatted i18n to their Country preference.
  # Default value of :utc is Time.now.utc
  # =========================================================
  def local_time_as_string( utc = nil )
    utc ||= Time.now.utc
    @tz_proxy ||= TZInfo::Timezone.get(self.timezone)
    @tz_proxy.utc_to_local( utc ).strftime('%a, %b %d, %Y @ %I:%M %p')
  end # ===  
  
  
