module MemberPassword

    class IncorrectPassword < RuntimeError; end
    attr_accessor :password, :confirm_password    
    
    def self.included(target)
    
        target.extend ClassMethods
        
        target.before_validation { 
            find_password_validation_errors
        }
    end # === def
    
    def find_password_validation_errors
            # ==== password
              if new?
                self.password = self.password.to_s.strip
                if self.password.empty?
                  self.errors.add(:password, "Password is required.")
                else
                  self.salt = Member.random_string(10) # if !self.salt
                  self.hashed_password = Member.encrypt( self.password, self.salt)
                end
              end

            # ==== confirm password
              if new?
                self.confirm_password = self.confirm_password.to_s.strip
                if self.password != self.confirm_password
                  self.errors.add(:password, "Password confirmation does not match password. Re-type both.")
                end
              end
              
       true
    end # === def find_password_validation_errors

    module ClassMethods
    
        def random_string(len)
            chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
            (1..len).inject('') { |new_pass, i|  
              new_pass << chars[rand(chars.size-1)] 
            }
        end # ===     
    

        def encrypt(pass, salt)
            Digest::SHA1.hexdigest(pass+salt)
        end # ===


    end # === class


end # === MemberPassword
