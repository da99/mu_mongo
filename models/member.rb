# ==================================================
#
# ==================================================
class Member < Sequel::Model
  
  # include MemberAuthAuth
  # include MemberEmail
  # include MemberPassword
  # include MemberUsername
  
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
  
  # =========================================================
  #                    Instance Methods
  # ========================================================= 
  
  def columns_for_editor(params, mem = nil)

    case mem
        when self
            [:password, :confirm_password, :email]
        when nil
            if new?
                [:username, :password, :confirm_password, :email]  
            end
        else
            if mem.is_admin?
              [:password,  :email]    
            end
    end # case
    
  end # === def

  def validate_new_values(raw_params, mem=nil)
    params = raw_params.values_at( *(columns_for_editor(raw_params, mem)) )
    params.each do |k,v|
      send("#{k}=", v)
    end
  end # === def validate_new_values
  

end # Member
########################################################################################
