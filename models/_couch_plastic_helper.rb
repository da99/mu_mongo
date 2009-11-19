module CouchPlastic
  
  # =========================================================
  #				Special class for use throughout app.
  # ========================================================= 
  class Helper

    class << self

      def time_string(time_or_str)
        raise "needs implementation."
      end

      def utc_now
        # return as string
        raise "needs implementation."
      end

    end

  end # === class Helper

end # ==== module CouchPlastic
