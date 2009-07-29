# ==================================================
#
# ==================================================
class Member < Sequel::Model
  
  include MemberAuthAuth
  include MemberEmail
  include MemberPassword
  include MemberUsername
  
  # =========================================================
  #                   ASSOCIATIONS
  # =========================================================  
  trashable :newspapers, :key=>:owner_id
  trashable :newspaper_articles, :key=>:author_id
  trashable :newspaper_jobs, :class=>'NewspaperTeammate', :key=>:member_id
  
    
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
  
  def changes_from_editor(params, mem = nil)

    case mem
        when self
            @current_editor = mem
            @editable_by_editor = [:password, :confirm_password, :email]
        when nil
            if new?
                @current_editor = :new_member 
                @editable_by_editor = [:username, :password, :confirm_password, :email]  
             end
        else
            if mem.is_admin?
                @current_editor = mem 
                @editable_by_editor = [:password,  :email]         
            end
    end # case
    
    super
  end # === def

  def validate_new_values
    
  end # === find_validation_errors 
  

end # Member
########################################################################################
