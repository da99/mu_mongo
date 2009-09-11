class Gems < Thor
    
    include CoreFuncs 
    
    desc :update,  "Installs and updates all gems from manifest (.gems)" 
    def update
      gem_manifest = Pow('~/', primary_app, '.gems')
      raise "Gems manifest does not exists: .gems" if !gem_manifest.exists?
      
      gems_to_install = File.read(gem_manifest).strip.split("\n")
      
      if development?
        dev_gems = Pow('~/', primary_app, '.development_gems' )
        gems_to_install = gems_to_install + File.read(dev_gems).strip.split("\n")
      end
      
      installed =  capture_all('gem list')
      if gems_to_install.empty?
        whisper  "No gems to install."
      else
        gems_to_install.each { |g|
          gem_name = g.split.first
          if installed["#{gem_name} ("]
            whisper "Already installed: #{gem_name}"
          else
            whisper capture_all( "gem install #{g}")
          end
        }
      end    
      whisper 'Please wait as gems are updated...'
      whisper( output = capture_all('gem update') )
      output
    end   
     
end # === namespace :gems
