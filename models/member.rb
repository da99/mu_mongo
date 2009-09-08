# ==================================================
#
# ==================================================
class Member < Sequel::Model
  
  # =========================================================
  #                     CONSTANTS
  # =========================================================  

  class IncorrectPassword < StandardError; end
  class InvalidPermissionLevel < StandardError; end
  
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
  # Raises: Member::IncorrectPassword
  def self.validate_username_and_password( username, pass )
      mem = self[:username => username]
      
      raise NoRecordFound, "#{username} was not found." if !mem
      
      return mem if Digest::SHA1.hexdigest(pass + mem.salt).eql?( mem.hashed_password )

      raise IncorrectPassword, "Try again."
  end # === self.authenticate

  
  # =========================================================
  #                    Instance Methods
  # ========================================================= 
  
  def_create do
    allow_only :STRANGER
    require_column :password
  end # === def_create
  
  def_after_create  do
    Username.editor_create self, raw_data
  end # === def_after_create
  
  def_update do
  
    allow_only self, :ADMIN
    
    if self.current_editor == self
        optional_columns :password
    elsif self.current_editor.admin?
        optional_columns :permission_level
    end    
    
  end # === def_update
  
    
  def_setter( :password, :not_a_column ) { 
      fn = :password
      pass = raw_data[ fn ].to_s.strip
      confirm_pass = raw_data[:confirm_password].to_s.strip
      
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
  
  
  def_setter( :permission_level ) { 
    fn = :permission_level
    new_level = raw_data[fn]
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
  
  
end # Member
########################################################################################


__END__


  
  VALID_USERNAME_FORMAT = /\A[a-zA-Z0-9\-\_\.]{2,25}\z/
  VALID_USERNAME_FORMAT_IN_WORDS = "letters, numbers, underscores, dashes and periods."
  VALID_EMAIL_CHARS   = /\A[a-zA-Z0-9\.\-\_\+\@]{8,}\z/
  EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
  VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/
  
  
  
  class IncorrectPassword < StandardError
  end

  
  def password=(pass)
    @password = pass.strip
    self.salt = Member.random_string(10) if !self.salt
    self.hashed_password = Member.encrypt(@password, self.salt)
  end
  
  #############################################################
  protected
  #############################################################
    
  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass+salt)
  end # ===
  
  def self.random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    (1..len).inject('') { |new_pass, i|  
      new_pass << chars[rand(chars.size-1)] 
    }
  end # ===


  
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
  
  
