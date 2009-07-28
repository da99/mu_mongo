#
# All methods and validations regarding usernames.
#
module MemberUsername

    MIN_USERNAME_LENGTH  = 2
    MAX_USERNAME_LENGTH  = 30
    VALID_USERNAME_FORMAT = /\A[a-zA-Z0-9\-\_\.]{#{MIN_USERNAME_LENGTH},#{MAX_USERNAME_LENGTH}}\z/
    VALID_USERNAME_FORMAT_IN_WORDS = "letters, numbers, underscores, dashes and periods."
    
    attr_reader   :old_username
    
    def self.included(target)
        target.extend ClassMethods
        target.before_validation { 
             find_username_validation_errors
        }

    end # === def    
    
    def by_line_name
        username
    end 
    
    def find_username_validation_errors
    # ==== Username
      if !new?
        @old_username = this.naked.first[:username]
      end

      self.username = self.username.to_s.strip
      
      if self.username.size < MIN_USERNAME_LENGTH
        self.errors.add(:username, "Username too short. Has to be #{MIN_USERNAME_LENGTH} or more characters.")
      elsif self.username.size > MAX_USERNAME_LENGTH
        self.errors.add(:username, "Username too big. Has to be between #{MIN_USERNAME_LENGTH} and #{MAX_USERNAME_LENGTH} characters.")
      else
        unless Member.valid_username_format?(self.username)
          self.errors.add(:username, "Username is invalid. Try using just: #{VALID_USERNAME_FORMAT_IN_WORDS}")
        end
      end
      
      if changed_columns.include?(:username) 
        old_member = Member[:username=>self.username]
        if old_member && old_member.id != self.id
          self.errors.add(:username, "Username already taken. Try another.") 
        end
      end
      
      true
    
    end # === def find_username_validation_errors

        
    module ClassMethods
        # =========================================================
        # Returns either the username or false. 
        # Does not raise Sequel::ValidationFailed exception.
        # =========================================================
        def valid_username_format?(username)
            begin
              validate_username_format(username)
            rescue Sequel::ValidationFailed
              false
            end
        end
  
        # =========================================================
        # Raises Sequel::ValidationFailed if username is in invalid format.
        # =========================================================
        def validate_username_format(username)
            raise(  Sequel::ValidationFailed , "Username: has to be a string."  ) unless username.instance_of?(String)

            username                = username.strip
            valid_username_chars    = VALID_USERNAME_FORMAT
            raise(  Sequel::ValidationFailed, "Usernames have to be between 2 and 25 characters with only the following characters:" +
                            " letters (English), numbers, underscores, periods, dashes (minus signs)."  ) unless username =~ valid_username_chars

            username
        end  
    end # === module

end # === module



__END__

        target.after_update { |u_m|
            # :paper_trail_for_username_change
            username_diff = PaperTrail.diff_hash( {:username=>old_username}, {:username=> u_m.username} ) 

            if username_diff
              new_paper_trail = PaperTrail.new( :model_class_name=> u_m.class.name, 
                                                :action=>'UPDATE', 
                                                :body=>username_diff )
              u_m.add_paper_trail( new_paper_trail )  
            end
          } 
