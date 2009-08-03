class LoginAttempt < Sequel::Model

  MAX = 4
  class TooManyFailedAttempts < RuntimeError; end
    
  # =========================================================
  #                      CLASS METHODS
  # =========================================================
  
  def self.log_failed_attempt( ip_address )
    new_values = { :ip_address=>ip_address, :created_at=>Time.now.utc.strftime("%Y-%m-%d") }
    la = LoginAttempt[ new_values ] || LoginAttempt.new( new_values)
    la.total = la.total.to_i + 1 # <== Blatant race condition problem, but it will do for now.
    
    if self.total  >= MAX
        raise TooManyFailedAttempts, "#{self.total} login attemps for #{self.created_at}" 
    end
        
    la.save
  end
  
  # =========================================================
  #                   INSTANCE METHODS
  # =========================================================
  


end # ===== LoginAttempt
