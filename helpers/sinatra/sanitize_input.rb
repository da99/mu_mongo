helpers {

  def clean_room
    @clean_room = params.inject({}) { |m, (k, val)|
      if val.to_s.strip.empty?
          m[k] = nil
      else
          m[k] = Wash.plaintext(val)
      end
      m
    }
  end

  def integerize_splat_or_captures
      raw_vals = ( params[:splat] || params[ :captures ] )
      raise "No Integers/IDs found."  unless raw_vals
      raw_vals.map { |raw_i| 
          raw_i.split('/').map { |i|
              Integer(i) unless i.strip.empty?
          }
       }.flatten.compact
  end # === integerize_splat_or_captures

} # === helpers
