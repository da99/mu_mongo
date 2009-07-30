require 'ruby2ruby'
require 'parse_tree'
require 'parse_tree_extensions'

require 'sequel'
require 'sequel/extensions/inflector'

# ============= Include lib files.
# require Pow!( '../lib/wash' )
# require Pow!( '../lib/to_html' )


module Sinatra

    module ClubManager # ==========================
        
        def self.registered(app)
            app.helpers Helpers    
            app.set :valid_resource_actions, [:view, :index, :show, :create, :list, :edit, :update, :trash, :untrash]
            app.before {
          
            
                # Chop off trailing slash.
                if request.get? && request.path_info.size > 2 && request.path_info[ request.path_info.size - 1 , 1] == '/' 
                    redirect( request.path_info.sub(/\/$/, '' ) , 301 ) # Permanent redirect.
                end         
                
                # require_url_with_www!
                  #missing_www = request.local_net? ?
                  #              false :
                  #              request.env['HTTP_HOST'] !~ /^www\./i
                  #                  
                  #url_with_www = "http://www.#{request.env['HTTP_HOST']}#{request.env['REQUEST_URI']}"  
                  #if missing_www                
                  ##    redirect( url_with_www, 301) 
                  #end            
                  
                # url must not be blank
                if test? && request.env['REQUEST_URI'].to_s.strip.length.zero? 
                    raise ArgumentError, "POSSIBLE SECURITY ISSUES: URL is blank." 
                end
            } # === before                    
        end 
        
        module Helpers # ===============================   
        
            # ==================================================================
            # Ajax helpers.
            # ==================================================================

            def to_js_epoch_time(epoch_time)
              epoch_time.to_i * 1000
            end

            def render_success_msg(msg)
              describe_action :Main, :success_msg
              delete_form_draft_cookie
              @success_msg = msg
              @partial ||= template_name
              
              halt( 200, render_mab )
            end

            
            def render_error_msg( http_error_code, msg)
                describe_action :Main, :error_msg
                @error_msg = msg
                halt( 200, render_mab)
            end
        
            # === Miscellaneous helpers ========================
               def publicize_path(path)
                 File.join( options.public, Wash.path( path ) )
              end

                def clean_room
                  @clean_room = params.inject({}) { |m, (k, val)|
                    if val.to_s.strip.empty?
                        m[k] = nil
                    else
                        m[k] = Wash.plaintext(val)
                    end
                    m
                  }
                end

            def integerize_splat_or_captures
                raw_vals = ( params[:splat] || params[ :captures ] )
                raise "No Integers/IDs found."  unless raw_vals
                raw_vals.map { |raw_i| 
                    raw_i.split('/').map { |i|
                        Integer(i) unless i.strip.empty?
                    }
                 }.flatten.compact
            end # === integerize_splat_or_captures
            
            def dev_log_it( msg )
                puts(msg) if development?
            end                    
            
            # === Member related helpers ========================
            
            def logged_in?
              session[:member_username] && !current_member.new?
            end # === def      
    
            def current_member=(mem)
                raise "CURRENT MEMBER ALREADY SET" if mem && session[:member_username]
                session[:member_username] = mem.username
            end    
    
            def current_member
              return Member.new if session[:member_username].to_s.strip.empty?
              @current_member ||= Member[:username => session[:member_username] ]
              return Member.new unless @current_member
              @current_member
            end # === def
            
            def check_creditials!
              # return true if Ramaze::Action.current.method.to_s.eql?('error')
              dev_log_it("CREDITIAL CHECK >>> #{current_action[:controller].inspect} #{current_action[:action].inspect}")
              
              return true if logged_in? && current_member.has_permission_level?( current_action[:perm_level] )
              return true if current_action[:perm_level].eql?( :STRANGER )
              
              if request.get?
                session[:desired_uri] = request.env['REQUEST_URI']
                redirect('/login')
              else
                render_error_msg( 200, "Not logged in. Login first and try again."  )
              end
              
            end # === def check_creditials!            
            
            
            # === Action related helpers. ===========================
                            
            
               def  describe_action( props )
                    @current_action_props = props
                    check_creditials!
               end
                
               def current_action
                    @current_action_props
               end    
            
        end # === module: Helpers

        # ==========================================
        # Instance Methods
        # ==========================================   
                            
        def strigify_proc( raw_proc )
            raw_proc.to_ruby.gsub( /^proc \{|\}$/, '' )
        end 
    
    end # === module: ClubManager

    register ClubManager
end # === module: Sinatra




__END__


  def error
  
    response['Content-Type'] = 'text/html' # In case the controller changed it, like the CSSController.

    if BusyConfig.development?
      return error_wo_customizations if request.get?

      error = Ramaze::Dispatcher::Error.current
      title = error.message

      respond %(
        <div class="error_msg">
          <div class="title">#{error.message}</div>
          <div class="msg"><pre>
            #{PP.pp request, '', 200}
            <br /><hr /><br />
            #{error.backtrace.join("\n            ")}
          </pre></div>
        </div>
      ).ui
      
    end
    

    
    begin
      respond Pow!('../public/500.html').read
    rescue
      respond %~
        <html>
          <head>
            <title>Error Page</title>
          </head>
          <body>
            Something went wrong. Check back later :(
          </body>
        </html>
      ~.unindent
    end
      
  end

   # ==================================================================
    # Methods to handle permission levels.
    # ==================================================================
    def __perm_levels__
      @perm_levels ||={}
    end

    def set_permission_level( new_level, *actions )
      actions.each { |raw_target_action| 
        target_action = raw_target_action.to_sym
        if __perm_levels__.has_key?(target_action)
          raise PermissionLevelAlreadySet,  "Permission level can not be set more than once: #{raw_target_action.inspect}" 
        end
        __perm_levels__[target_action] = new_level
      }
    end

    def get_permission_level(target_action)
      __perm_levels__.fetch( target_action.to_sym,  Member::NO_ACCESS )
    end
