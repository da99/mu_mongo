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
  #                     Class Methods.
  # =========================================================

  def self.first
    raise "Not implemented."
  end

  # Based on Sinatra-authentication (on github).
  # 
  # Parameters:
  #   raw_vals - Hash with at least 2 keys: :username, :password
  # 
  # Raises: 
  #   Member::IncorrectPassword
  #
  def self.authenticate( raw_vals )
      
      un = CouchDoc.GET_by_id( raw_vals[:username] )

      correct_password = BCrypt::Password.new(un.owner.hashed_password) === (raw_vals[:password] + un.owner.salt)
      
      if correct_password
        return un.owner
      end

      raise IncorrectPassword, "Password is invalid for: #{raw_vals[:username]}"

  end # === self.authenticate


  # =========================================================
  #                    Data Class Methods
  # =========================================================

  def self.create( editor, raw_vals )
    
    raise "No logged in members are allowed to created Members." if editor

    doc = new
    doc.password= raw_vals
    doc.set_optional_values( raw_vals, :avatar_link )
    
    doc.save_create

    begin
      Username.create( doc, raw_vals )
    rescue Username::NotUnique
      doc.delete!
      doc.errors << 'Username already taken.'
      doc.validate
    end
    
    doc

  end

  def self.edit( editor, raw_vals )
    doc = CouchDoc.GET_by_id(raw_vals[:id])
    doc.validate_editor( editor, doc.owner, ADMIN )
    doc
  end

  def self.update( editor, raw_vals )
    doc = edit(editor, raw_vals)
    if doc.owner?(editor)
        doc.set_optional_values( raw_vals, :password )
    else
      if editor.has_power_of?(:ADMIN)
        doc.set_optional_values( raw_vals, :permission_level ) 
      end
    end
    doc.save_update
  end
  

  # =========================================================
  #                    Instance Methods
  # ========================================================= 

  def usernames
    assoc_cache[:usernames] ||= CouchDoc.GET_usernames_by_owner( self.original[:_id] )
  end


  # By using a custom implementation, we cane make sure
  # sensitive information is not shown.
  def inspect
    assoc_cache[:inspect_string] ||= "#<#{self.class} id=#{self.original[:_id]}>"
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



  
  # =============== VALIDATORS =============================

  def password=(raw_data)
    pass         = raw_data[:password ].to_s.strip
    confirm_pass = raw_data[:confirm_password].to_s.strip
    
    if pass != confirm_pass 
      self.errors << "Password and password confirmation do not match." 
    
    elsif pass.empty?
      self.errors <<  "Password is required."
    
    elsif pass.length < 5
      self.errors << "Password must be longer than 5 characters."    
    
    elsif !pass[/[0-9]/]
      self.errors << "Password must have at least one number."
    end

    return nil if !self.errors.empty?
    
    # Salt and encrypt values.
    self.new_values[:salt] =  begin
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
  
  
end # === model Member


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
  
  
