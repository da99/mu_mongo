module CouchPlastic
  
  # =========================================================
  #				Special class for use throughout app.
  # ========================================================= 
  class Helper

    class << self

      def time_string(time_or_str)
        t = Time.parse(time_or_str.to_s)
        t.strftime('%Y-%m-%d %H:%M:%S')
      end

      def utc_now
        Time.now.utc
      end

      def utc_now_as_string
        time_string(utc_now)
      end

    end

  end # === class Helper

end # ==== module CouchPlastic
