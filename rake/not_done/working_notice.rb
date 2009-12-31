

class Site_Is

  include FeFe
  
  CONFIG_RU        = '~/' + APP_NAME + '/config.ru'
  CONFIG_SITE_DOWN = '/~' + APP_NAME + '/config.site_down.rb'
  
  CONFIG_RU_ORIGINAL = CONFIG_RU.sub( File.basename(CONFIG_RU), 'config.original.ru')

  describe :down do
    it 'Puts up a maintenence page for all actions. Takes into account AJAX and POST requests.'
    
    steps {
      CONFIG_RU.file.rename_to( CONFIG_RU_ORIGINAL )
      CONFIG_SITE_DOWN.file.rename_to( CONFIG_RU )
      run_task 'git:update'
      run_task 'git:commit', :msg=>"Added temporary maintainence page." 
      puts_white shell_out('git push heroku master')
    }
    
  end # === task :start
  
  describe :up do 
    it 'Takes down maintence page.'
  
    steps {
      demand_file_exists CONFIG_RU_ORIGINAL
      CONFIG_RU.file.rename_to(CONFIG_SITE_DOWN)
      CONFIG_RU_ORIGINAL.file.rename_to(CONFIG_RU)
      run_task 'git:update'
      run_task 'git:commit', :msg=>'Took down site maintainence page.'
      run_task 'git:push'
    }

  end # === task :over
  
end # === namespace :maintain

