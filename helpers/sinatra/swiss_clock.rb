# require 'tzinfo'

##########################################################
# I made this instead of the using ActiveSupport 
# for time-related methods.
##########################################################
module SwissClock

  # =========================================================
  # Returns a string for :strftime methods.
  # The format is for American English users.
  # =========================================================
  def time_string_format
    '%a, %b %d, %Y @ %I:%M %p'
  end
  
  # =========================================================
  # Need a reason to use slow :tzinfo instead of something faster?
  # See here: http://www.ruby-forum.com/topic/79431
  # =========================================================
  def utc_to_local( utc, tz_string )
    TZInfo::Timezone.get(tz_string).utc_to_local( utc )
  end
  

  # =========================================================
  # 
  # =========================================================
  def utc_to_local_string( tz_string, utc_time, string_format=nil)
    string_format ||= SwissClock.time_string_format
    utc_to_local(tz_string, utc_time).strftime(string_format)
  end
  
  # =========================================================
  # Returns valid timezone or false. Does not raise exception.
  # =========================================================
  def valid_timezone?( tz_name )
    begin
      validate_timezone(tz_name)
    rescue SwissClock::Invalid
      false
    end
  end
  
  # =========================================================
  # 
  # =========================================================
  def validate_timezone( tz_name )
    begin
      TZInfo::Timezone.get(tz_name)
    rescue TZInfo::InvalidTimezoneIdentifier
      raise Invalid, "Timezone Unknown: #{$!.message}"
    end
  end
  
end # === SwissClock
