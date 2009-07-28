require 'tmail'
#
# All methods and validations regarding email for Member Model.
#
module MemberEmail

    def self.included(target)
        target.extend ClassMethods
        target.before_validation  { 
            find_email_validation_errors
        }
    end
    
    VALID_EMAIL_CHARS   = /\A[a-zA-Z0-9\.\-\_\+\@]{7,}\z/
    EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
    VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/

    def find_email_validation_errors
    # ==== email   
      unless self.email.blank?       
        self.errors.add(:email, "Invalid email format. Check your spelling. ") unless Member.valid_email_format?( email )
        self.errors.add(:email, "Email rejected. Check your spelling. Contact support if you continue having trouble.") if new? && Member.first(:email=>email)                  
      end
      
      true
    end # === def 
    
    module ClassMethods
    
        # =========================================================
        # Returns either the email address or false. 
        # Does not raise Sequel::ValidationFailed exception.
        # =========================================================  
        def valid_email_format?( email )
            begin
              validate_email_format( email )
            rescue Sequel::ValidationFailed
              false
            end
        end
        
        # =========================================================
        # Raises Sequel::ValidationFailed if email address format is not valid.
        # =========================================================
        def validate_email_format(   email_address    ) 

            raise( Sequel::ValidationFailed, "Wrong Class: Email has to be an instance of a String." ) unless email_address.instance_of?(String)
            email_address = email_address.strip.downcase

            raise( Sequel::ValidationFailed, ("Invalid Characters: Email has invalid characters.")) unless email_address =~ VALID_EMAIL_CHARS

            raise( Sequel::ValidationFailed, ('Invalid Format: Email format unrecoginized.')) unless email_address =~ VALID_EMAIL_FORMAT

            begin
              validated_email = TMail::Address.parse( email_address ).to_s
            rescue TMail::SyntaxError
              raise( Sequel::ValidationFailed,  "Invalid Format: Email format could not be recognized."  )
            end

            validated_email
        end # end self.validate_email         
        
    end # === module ClassMethods

end # === module
