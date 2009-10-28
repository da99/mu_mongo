require 'markaby'

class SinatraMabWrapper
    attr_accessor :app_scope
    def method_missing(*args)
           app_scope.send(*args)
    end
    
    def respond_to?(*args)
        return false if args.include?(:builder)
        return true if app_scope.respond_to?(*args)
        false
    end  
end # === class 


class TemplateCache
    class << self
        def cache 
            @the_cache ||= {}
        end
        def reset
            @the_cache = {}
        end
    end # === class
end # === class

# =========================================================
# Set up Markaby customizations.
# =========================================================
class Markaby::Builder
  def save_to(name,  &new_proc)
        instance_variable_set( :"@#{name}" , capture(&new_proc) )       
  end # === save_to
  
  def add_template_root(new_template_dir)
    @template_roots ||= []
    @template_roots << new_template_dir
  end # === add_template_root

  def partial( raw_file_name )
    
    file_name = raw_file_name.to_s
    file_name += '.rb' if !file_name['.rb']
    
    # Find template file.
    if File.exists?(file_name)
      partial_filepath = file_name 
    elsif File.exists?(file_name + '.rb')
      partial_filepath = file_name + '.rb'
    else
      template_roots.each { |template_root|
        temp_file_path = File.join( template_root, file_name )
        if File.exists?( temp_file_path )
          partial_filepath = temp_file_path
          break
        end
      }
    end

    if !partial_filepath
      raise "Partial template file not found: #{file_name} in template roots: #{template_roots.join( '  ,  ' )}"
    end
    
    # Get & Render the contents of template file.
    the_app.dev_log_it "Rendering partial: #{partial_filepath}"
    text( 
        capture { 
            eval File.read(partial_filepath), nil, partial_filepath, 1  
        } 
    )
    ''
  end # === partial

  def checkbox selected, attrs
    defaults = { :type=>'checkbox' }
    if selected
      defaults[:checked] = 'checked'
    end
    input attrs.update(defaults)     
  end
  
end # === class Markaby::Builder
        


module Sinatra
    module RenderMab
        
        def self.registered(app)
            app.helpers RenderMab::Helpers
            Markaby::Builder.set(:indent, 1)  if !app.production?
            Markaby::Builder.set(:indent, 0)  if app.production?
        end
        
        module Helpers
            
            # ==================================================================
            # Template helpers.
            # ==================================================================
            
            def array_to_string(arr)
               
                  all_errors = arr.flatten
                  all_errors.size === 1 ?
                      all_errors.first  :
                      '* ' + all_errors.join("\n* ")   
               
            end
            
            def skin_name
                @skin_name ||= 'jinx'
            end
            
            def skins_dir
                File.join( options.views )
            end
            
            def template_file_path
                File.join( skins_dir, template_file_name )
            end
            
            def page_name
                @page_file_name ||=  template_file_name.sub( '.rb', '')
            end
            
            def template_file_name
                if !current_action
                    raise "CURRENT ACTION PROPERTIES NOT DEFINED for: #{self.inspect}"
                end
                @template_file_name ||= current_action[:controller].to_s.underscore + "_" + current_action[:action].to_s.underscore + '.rb'
                regular_file_path = File.join(skins_dir, @template_file_name) 
                partial_file_path  = File.join(skins_dir, "__" + @template_file_name)
                
                return @template_file_name if TemplateCache.cache.has_key?(regular_file_path)
                return "__" + @template_file_name if TemplateCache.cache.has_key?(partial_file_path)
                
                return @template_file_name if File.exists?( regular_file_path )
                return  "__" + @template_file_name if File.exists?( partial_file_path )
                
                raise "TEMPLATE NOT FOUND: #{ regular_file_path }"

            end # === def 
            
            def template_is_a_partial?
                @is_partial_template ||= template_file_name =~ /\A__/
            end
            
            def template_file_content
                if self.options.cache_the_templates
                  TemplateCache.cache[ template_file_path ] ||= File.read( template_file_path )
                else
                  File.read( template_file_path )
                end
            end
            
            def layout_file_path
                File.join( skins_dir,  layout_file_name )
            end
            
            def layout_file_name
                'layout.rb' 
            end
            
            def layout_file_content
                layout_file_name = 
                 @layout_file_content ||= begin
                    File.read( layout_file_path )
                  rescue Errno::ENOENT
                        nil
                  end
                  raise "LAYOUT NOT FOUND: #{layout_file_name}" unless @layout_file_content
                  @layout_file_content
            end
        
            # Returns: String with fully rendered template.
            # Arguments:
            #   opts - Options: 
            #     :template - Relative to Ramaze::Global.view_root
            #                Defaults to controller name underscored and action with '.rb'
            #                at the end. Example: "jinx/newspaper_index.rb"
            #     :layout  - Relative to Ramaze::Global.view_root + '/layouts'.
            #                Defaults to 'jinx'.
            #                Set to nil to prevent layout being used.
            #                Leave out '.rb' since it is automatically added.
            #     :locals  - Hash with keys/values to be combined with the curreny local instance
            #                variables.
            def render_mab( opts = {} )
          
                response['Content-Type']   = 'text/html; charset = utf-8'
                response['Accept-Charset'] = 'utf-8'
                response['Cache-Control']  = 'no-cache'
                response['Pragma']         = 'no-cache'
                
                # Find template. ==================================================
                
                # ======= See if we need to use a layout.
                use_layout = !template_is_a_partial? && ( !opts.has_key?(:layout) || ( opts.has_key?(:layout) && opts[:layout] ) )
                                
                # Setup instance variables for Markaby. ==========================
                iv_hash = instance_variables.inject({}) do |m, iv|
                   key = iv.gsub('@', '').to_sym
                   m[key] = instance_variable_get(iv)
                   m
                end
                
                # Setup Markaby Builder. =========================================
                sin_wrap = SinatraMabWrapper.new
                sin_wrap.app_scope= self
                ivs = { :content_file_path=>template_file_path, 
                        :the_app=>sin_wrap,
                        :template_roots => [skins_dir],
                        :app_vars => iv_hash
                      } 

                # =================================================================
                # Determine if a layout is required.
                if !use_layout 
                    dev_log_it "Rendering Template w/o Layout: #{template_file_name}" 
                    the_content = template_file_content
                    the_file_path = template_file_path                   
                    return Markaby::Builder.new(ivs).capture { 
                      eval( the_content, nil, the_file_path, 1 ) 
                    }
                else
                  #  =================================================================
                  # Grab & Render the Markaby content for current action.
                  dev_log_it "Rendering Markaby: #{template_file_name}"
                  dev_log_it "... with layout: #{layout_file_name}"
                  
                  the_content = layout_file_content
                  the_file_path = layout_file_path

                  Markaby::Builder.new( ivs ) {
                    eval( the_content ,  nil,  the_file_path , 1  )
                  }.to_s                  
                  
                  # the_content = template_file_content
                  # the_file_path = 
                  
                  # instance_eval the_content, the_file_path, 1 
                 

                  #  =================================================================
                  # Update iv_hash for :the_content.
                  # Grab & Render Markaby content for layout.

                  #partial_vars_hash = mab.instance_variables.inject({}) { |m, iv|
                  #                       key = iv.gsub('@', '').to_sym
                   #                      unless mab_orig_vars.include?( "@#{iv}" )
                  #                        m[key] = mab.instance_variable_get(iv) 
                  #                       end
                  #                       m
                  #                    }                   
                  

                end


                
            end # === render_mab   
            
            def instance_variables_to_hash( target ) 
                target.instance_variables.inject({}) { |m, iv|
                   key = iv.gsub('@', '').to_sym
                   m[key] = target.instance_variable_get(iv)
                   m
                }              
            end        
        end # === module: Helpers
    end # === module: RenderMab
    
    register RenderMab

end # === module: Sinatra
