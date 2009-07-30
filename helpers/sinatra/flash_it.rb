#
# Inspired by: http://github.com/i2av/sinatra-flash
#
module Sinatra

    module FlashIt
        
        def self.registered(app)        
            app.helpers Helpers
            app.before {
                if session[:flash_hash]
                    @flash_cache = session[:flash_hash]
                    session[:flash_hash] = nil
                end
            }
        end  # === def
        
    
        module Helpers
        
            def flash_msg?
              ( flash(:error_msg) || flash(:success_msg) ) ?
                true :
                false
            end

            def flash_msg_as_html
             emails_to_mailtos(
                Wash.html( 
                    flash(:success_msg) || flash(:error_msg)
                ) 
              ).gsub("\n", "<br />")
            end
            
            def flash(*args)
                return __flash_get__(*args) if args.size == 1
                return __flash_set__(*args) if args.size == 2
                raise ArguementError, "Only 1 to 2 arguments allowed."
            end
            
            def flash?(index)
                !!( flash(index) )
            end
            
            def __flash_get__( index )
                __flash_hash__[index] || __flash_cache__[index]
            end
            
            def __flash_set__( index, val )
                __flash_hash__[ index ] = val
            end
            
            def __flash_hash__
                session[:flash_hash] ||= {}
            end
            
            def __flash_cache__
                @flash_cache ||= {}
            end

                        
        end # === module Helpers
    
    end # === module FlashIt

    register FlashIt

end # === Sinatra


