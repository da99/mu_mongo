class LogInAttempt < Sequel::Model

  MAX = 4
  class TooManyFailedAttempts < StandardError; end
    
  # =========================================================
  #                      CLASS METHODS
  # =========================================================
  
  def self.log_failed_attempt( ip_address )
    params = { :ip_address=>ip_address, :created_at=>Time.now.utc.strftime("%Y-%m-%d") }
    old_la = LogInAttempt.filter(params).first
    
    return LogInAttempt.create( params ).total if !old_la
   
    # Why use ".this.update"? Answer: http://www.mail-archive.com/sequel-talk@googlegroups.com/msg02150.html
    old_la.this.update :total => 'total + 1'.lit
    new_total = old_la[:total] + 1  

    if new_total >= MAX
        raise TooManyFailedAttempts,  "#{new_total} log-in attemps for #{old_la.ip_address}"
    end
    
    new_total

  end # === def self.log_failed_attempt
  
  # =========================================================
  #                   INSTANCE METHODS
  # =========================================================
  

end # ===== LogInAttempt
