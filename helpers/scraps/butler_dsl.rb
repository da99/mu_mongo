module Butler_Dsl

  attr_reader :dir, :file

  def self.included new_class
    if !new_class.include?(Demand_Arguments_Dsl)
      new_class.send :include, Demand_Arguments_Dsl
    end
  end

end # === Butler_Dsl

class Sym_Link_Dsl
  attr_reader :from, :to
  def initialize &blok
    instance_eval &blok
  end

  def from *args
		return @from if args.empty?
    @from = File.join(*args)
  end

  def to *args
		return @to if args.empty?
    @to = File.join(*args)
  end
end # === Sym_Link_Dsl
