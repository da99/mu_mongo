#
# Authentication and Authorization
#
module MemberAuthAuth

    def self.included(target)
        target.extend ClassMethods
    end # === def

    NO_ACCESS   = -1000
    ADMIN           = 1000
    MEMBER         = 1
    STRANGER      = 0 # Used mainly by other classes/objects to identity
                                   # someone who is unknown or not logged in.
    SECURITY_LEVELS   = [ NO_ACCESS, ADMIN , MEMBER , STRANGER ]
    
    class UnknownPermissionLevel < RuntimeError; end
    
    def is_admin?
        has_permission_level?(ADMIN)
    end
    
    def has_permission_level?(raw_perm_level)
        target_perm_level = Integer(raw_perm_level)
        raise UnknownPermissionLevel, "#{perm_level.inspect} is not a valid permission level." unless SECURITY_LEVELS.include?(target_perm_level)
        case target_perm_level
          when STRANGER
            true
          when MEMBER
            new? ? false : true
          when ADMIN
            self[:id] === 1
        end
    end # ===    
    
    
    module ClassMethods
        def validate_permission_level( raw_level )
            target_perm_level = raw_level.to_s.strip.downcase
            raise ArguementError, "#{raw_level} is not a valid permission level."  unless SECURITY_LEVELS.include?(target_perm_level)
            target_perm_level  
        end # === validate_permission_level
        
        # =========================================================
        # See: Sinatra-authentication (on github)
        # ========================================================= 
        def authenticate(username, pass, ip_address)
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
        
    end # === module ClassMethods
    

end # === module MemberAuthAuth
