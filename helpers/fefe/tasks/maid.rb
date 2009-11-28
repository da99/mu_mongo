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
    
    steps([:collection, nil]) { |collection|
      if collection
        coll_obj = FeFe_The_French_Maid.require_collection(collection)
        if !coll_obj
          puts "Task collection not found."
          return nil
        end
        coll_obj.tasks.values.each { |t|
          puts( t.name.inspect + (t.options ? ' : ' + t.options.inspect : '') )
        }
      else
        __FILE__.ruby_files_wo_rb.each { |f|
          puts File.basename(f)
        }
      end
    }
  end

end

