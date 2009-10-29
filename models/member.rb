require 'bcrypt'


# ==================================================
#
# ==================================================
class Member 
  include CouchPlastic
  
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
   
  #one_to_many :usernames, :key=>:owner_id
  
    
  # =========================================================
  #                      HOOKS
  # =========================================================
  

  # =========================================================
  #                     Class Methods.
  # =========================================================

  # Based on Sinatra-authentication (on github).
  # Raises: Member::IncorrectPassword
  def self.validate_username_and_password( username, pass )
      un = Username.find_by_username_or_raise( username )
      return un.owner if BCrypt::Password.new(un.owner.hashed_password) === (pass + un.owner.salt) 
      raise IncorrectPassword, "Try again."
  end # === self.authenticate


  # =========================================================
  #                    Data Class Methods
  # =========================================================

  def self.create( editor, raw_vals )
    raise "No logged in members are allowed to created Members." if !editor
    new_doc = new
    new_doc.set_required_values( raw_vals, :password, :username )
    new_doc.set_optional_values( raw_vals, :avatar_link )
    new_doc.save

    begin
      Username.create( editor, raw_vals )
    rescue Username::NotUnique
      new_doc.delete!
      new_doc.errors << 'Username already taken.'
      new_doc.validate_or_raise
    end

  end

  def self.edit( editor, raw_vals )
    doc = find_by_id_or_raise(raw_vals[:id])
    doc.valid_editor_or_raise( editor, doc.owner, ADMIN )
    doc
  end

  def self.update( editor, raw_vals )
    doc = edit(editor, raw_vals)
    if doc.owner?(editor)
        doc.set_optional_values( raw_vals, :password )
    else
      if editor.admin?
        doc.set_optional_values( raw_vals, :permission_level ) 
      end
    end
    doc.save
  end
  

  # =========================================================
  #                    Instance Methods
  # ========================================================= 

  # Future versions of Sequel may alter implementation of :inspect.
  # By using a custom implementation, we cane make sure
  # the customized version of :inspect_values is always used.
  def inspect
    @inspect_this ||= "#<#{self.class} id=#{self.original[:id]}>"
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
          self == Member.first && self.permission_level == ADMIN
        when EDITOR
          self.permission_level === EDITOR
        else
          raise InvalidPermissionLevel, "#{raw_level.inspect} is not a valid permission level." 
      end
      
  end # === def security_clearance?


  # ================= AUTHORIZATIONS ========================


  
  # =============== VALIDATORS =============================

  def password=(raw_data)
    pass         = raw_data[ :password ].to_s.strip
    confirm_pass = raw_data[:confirm_password].to_s.strip
    
    self.errors << "Password and password confirmation do not match." if pass != confirm_pass 

    if pass.empty?
      self.errors <<  "Password is required."
    elsif pass.length < 5
      self.errors << "Password must be longer than 5 characters."    
    elsif !pass[/[0-9]/]
      self.errors << "Password must have at least one number."
    end

    return nil if !self.errors.empty?
    
    # Salt and encrypt values.
    self.new_values[:salt] = begin
                    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
                    (1..10).inject('') { |new_pass, i|  
                      new_pass += chars[rand(chars.size-1)] 
                      new_pass
                    }
                  end
    
    self.new_values[:hashed_password] = BCrypt::Password.create( pass + self.new_values[:salt] ).to_s
    confirm_pass
      
  end # === def set_password
  
  
  def permission_level= raw_data
    fn = :permission_level
    new_level = raw_data[fn]
    if !SECURITY_LEVELS.include?(new_level)
      raise InvalidPermissionLevel, "#{new_level} is not a valid permission level."  
    end
    
    self.new_values[fn] = new_level
    
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
  
  
