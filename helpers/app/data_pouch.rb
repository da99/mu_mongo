
#
# Treat each instance as a Hash, with keys accessible
# as methods. If a key/method
# was not used, it will not be included in the Hash
# given by :as_hash
#
class Data_Pouch

  def initialize *fields
    @field_hash = {}
    fields.each { |raw_fld|
      fld = raw_fld.is_a?(String) ? raw_fld.strip.to_sym : raw_fld
      @field_hash[fld] = (fld.to_s + '=').to_sym
    }
    
    @fields       = @field_hash.keys
    @fields_equal = @field_hash.values
    @data         = {}
  end

  def method_missing *args
    if args.size == 1 && @fields.include?(args.first)
      return @data[args.first]
    end

    if args.size == 2 && @fields_equal.include?(args.first)
      return @data[@field_hash.index(args.first)] = args.last
    end

    super
  end

  def as_hash
    @data
  end

end # ======== Data_Pouch

