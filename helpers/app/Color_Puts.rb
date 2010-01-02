
require 'term/ansicolor'

module Color_Puts 

  %w{ white red green }.each { |color|
    eval( %~
      def puts_#{color} msg = nil, &blok
        colorize_and_print :#{color}, msg, &blok
      end

      def colorize_#{color} msg = nil, &blok
        colorize :#{color}, msg, &blok
      end
    ~)
  }

  def colorize_and_print color, msg = nil, &blok
    print(
      colorize color, msg, &blok
    )
  end
  
  def colorize color, msg = nil
    Term::ANSIColor.send(color) {
      Term::ANSIColor.bold { 
        block_given? ? yield : msg 
      } 
    }
  end

end # === module
