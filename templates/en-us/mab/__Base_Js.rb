require 'models/Js_Dsl'

module Base_Js

	def js &blok
		Js_Dsl.new(&blok).to_s
	end
  
  def js! &blok
		Js_Dsl.new {
      instance_eval &blok
      return_false
    }.to_s
  end

  def a_click *args, &blok
    if args.size == 1 && !block_given?
      raise "Can't use :a (for :a_show) in a :show block more than once." if @a_show
      @a_show = true
      a_show(*args)
    else
      tag!( :a, *args, &blok )
    end
  end

end # === module Base_Js
