###########################################################
# Check for first parameter that is a file name like "-model_member" or "-model_plant".
# Use Array#delete to remove argument since Sinatra is boisterous over arguments 
# it does not recognise.
# Then, do the same for test/spect output format
dont_reset_term         = ARGV.delete( ARGV.detect {|a| a =~ /\-dont_reset_terminal/ } ).to_s[/\w+/]
spec_file                     = ARGV.delete( ARGV.detect {|a| a =~ /\_/ } ).to_s[/\w+/]
spec_output_format   = ARGV.delete( ARGV.detect {|a| a =~ /\-r(r|s)/  } )
###########################################################

unless dont_reset_term
  system('reset')
  puts 'Specs are running...'
end

###########################################################
# Require files.
###########################################################
require 'rubygems'
# require 'sinatra'
# require 'sinatra/test/spec'                                                       
# require 'mocha' 

alias :describe_wo_check_dup :describe

def set_current_file(new_file)
  @current_file=new_file
end

def describe *args, &blok
  @prev_contexts ||= []
  args[0] = "#{@current_file} - #{args.first}"
  raise ArgumentError, "#{args.first} already used before." if @prev_contexts.include?(args.first)
  @prev_contexts << args.first
  describe_wo_check_dup *args, &blok
end

# The following is necessary when working with rcov. -------------------------
this_app_file = __FILE__
this_root = Pow!.to_s

# Sinatra::Application.default_options.merge!( 
#   :root =>this_root,
#   :views => this_root + '/views',
#   :public => this_root + '/public',
#   :app_file => this_app_file
# )
# --------------------------------------------------------------------------------------------

require Pow!('start_it')
raise '$KCODE not set to UTF8 in start file.' unless $KCODE == 'UTF8'

# Add in RDox style console ouput after Sinatra is included 
# so argument won't conflict with other Ruby gems.
ARGV.unshift( spec_output_format ) if spec_output_format  

if spec_file
    # Require just one spec file if specified. ########################
    set_current_file spec_file
    if spec_file
      require( Pow! / "spec/#{spec_file}")
    end    
else
    # Require all files in this directory (except this __FILE__) if no single file specified. 
    Dir.new( BusyConfig.expand_path("spec")   ).each { |file_name|
      set_current_file file_name
      require( BusyConfig.expand_path("/spec/#{file_name}") )  if file_name =~ /\.(rb)$/ && File.basename(file_name) != File.basename(__FILE__)
    }
    ###########################################################

end # 'if/else spec_file'

