class Maid
  
  include FeFe

  describe :install do

    it %~
      Installs FeFe_The_French_Maid into your system.
    ~

    steps {
      require 'rubygems'
      __FILE__.file.relative('../fefe.rb').file.create_alias( Gem.bindir, 'fefe')
      puts 'Finished linking FeFe executable.'
    }

  end
  
  describe :list do
    
    it %!
      Lists all the task collections, but not the tasks.
    !
    
    steps([:collection, nil]) { |collection|
      if collection
        coll_obj = FeFe_The_French_Maid.collection_name_to_class(collection)
        if !coll_obj
          puts "Task collection not found."
          return nil
        end
        coll_obj.tasks.values.each { |t|
          puts( t.name.inspect + (t.options ? ' : ' + t.options.inspect : '') )
        }
      else
        
        __FILE__.file.directory.ruby_files_wo_rb.each { |f|
          puts File.basename(f)
        }
        
      end
    }
  end

end # ======== Maid
