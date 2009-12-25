class LogInAttempt
  include CouchPlastic

  MAX = 4
  class TooManyFailedAttempts < StandardError; end
    
  # =========================================================
  #                      CLASS METHODS
  # =========================================================
  
  def self.log_failed_attempt( ip_address )
return 0

    params = { :ip_address=>ip_address, :created_at=>utc_today }
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

  def self.too_many?(ip_address)
return false


    return false
    old_la = LogInAttempt.where(:ip_address=>ip_address, :created_at=>utc_today).first
    return false if !old_la
    old_la[:total] >= MAX
  end

  def self.utc_today
    Time.now.utc.strftime("%Y-%m-%d")
  end
  
  # =========================================================
  #                   INSTANCE METHODS
  # =========================================================
  

end # ===== LogInAttempt
