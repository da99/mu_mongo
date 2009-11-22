def redirect &blok
  RedirectDSL.new &blok 
end


configure do

  class RedirectDSL
  
    private
      attr_writer :from, :to
    
    def inititalize &blok
      instance_eval &blok
      if !@from || !@to
        raise ArgumentError, "Both need to be set: :to, :from (#{@to.inspect}, #{@from.inspect})"
      end 
      @from.each { |f|
        self.class.instance_eval %~
         get #{f.inspect} do 
          redirect #{@to.inspect}
         end
        ~
      }
    end

    def from *args
      @from= args.flatten
    end
    
    def to path_or_regex
      @to = path_or_regex
    end

  end # === RedirectDSL

end # === configure

