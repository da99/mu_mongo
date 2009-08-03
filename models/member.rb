# ==================================================
#
# ==================================================
class Member < Sequel::Model
  
  # include MemberAuthAuth
  
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
  
  

  def self.create_it( raw_params, editor)
    allowed_params = case editor
      when nil
        self.class.filter_params( raw_params,  [ :password, :confirm_password ] )
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
        {}
    end
    
    return if allowed_params.empty?
    
    update validate_new_values( allowed_params, allowed_params.keys )

  end # === update_it
  
  def validate_new_values( raw_params, keys )
    clean_params = {}
    
    keys.each { |k|
      case k
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
  
    

end # Member
########################################################################################
