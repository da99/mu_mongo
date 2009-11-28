FeFe(:Maid) do

  describe :install do

    it %~
      Installs FeFe_The_French_Maid into your system.
    ~

    steps {
			require 'rubygems'
      sym_link_file {
        from __FILE__.up_directory('fefe.rb')
        to   Gem.bindir, 'fefe'
      }

			puts 'Finished linking FeFe executable.'
    }

  end
  
  describe :list do
    it %!
      Lists all the task collections, but not the tasks.
    !
    
    steps {
      __FILE__.ruby_files_wo_rb.each { |f|
        puts ' ' + File.basename(f)
      }
    }
  end

end

