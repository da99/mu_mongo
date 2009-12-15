require File.join(File.dirname(File.expand_path(__FILE__)), 'spec')
module Bacon

  module SpecDoxOutput
    def handle_summary
      print ErrorLog  if Backtraces
      puts "%d specifications (%d requirements), %d \e[31mfailures\e[0m, %d \e[31merrors\e[0m" %
        Counter.values_at(:specifications, :requirements, :failed, :errors)
    end
  end

end
