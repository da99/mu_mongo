require 'mustache'

class Bunny_Mustache < Mustache
	
	def initialize new_app
		@app = new_app
	end

  def development?
    The_Bunny.development?
  end

	def url
		@app.request.fullpath
	end

	def mobile_request?
		false
	end

	def css_file
		"/stylesheets/english/#{@app.controller_name}_#{@app.action_name}.css"
	end

	def not_mobile_request?
		!mobile_request?
	end

	def head_content
		''
	end

	def loading
		nil
	end

  def site_title
    The_Bunny::Options::SITE_TITLE
  end

	def site_domain
		The_Bunny::Options::SITE_DOMAIN
	end
	
	def js_epoch_time raw_i = nil
		i = raw_i ? raw_i.to_i : Time.now.utc.to_i
    i * 1000
	end

	def copyright_year
		[2009,Time.now.utc.year].uniq.join('-')
	end

	def meta_description
	end

	def meta_keywords
	end

	def javascripts
	end

  def logged_in?
    nil #@app.logged_in?
  end

  def not_logged_in?
    !logged_in?
  end

  # === FLASH MESSAGES ===

  def flash_msg?
    nil # !!(@app.flash.success_msg || @app.flash.error_msg)
  end

  def flash_msg
    return nil if not flash_msg?

    if @app.flash.success_msg
      {:class_name=>'success_msg', :title=>'Success', :msg=>@app.flass.success_msg}
    else
      title = @app.flash.error_msg.to_s["\n"] ?
      'Errors' :
      'Error'
      {:class_name=>'error_msg', :title=>title, :msg=>@app.flass.error_msg}
    end
  end

  # === NAV BAR ===
   
  def opening_msg
  end

  def no_opening_msg
    !!opening_msg
  end



  def opening_msg_site_title
    if @app.request.path == '/'
      The_Bunny::Options::SITE_TITLE
    else
      %~<a href="/">#{The_Bunny::Options::SITE_TITLE}</a>~
    end
  end
   
  def nav_bar_li shortcut, text, c_name, a_name
    
    # if shortcut === 'home'
    #   path = '/'
    # else
    #   path = "/#{shortcut}/"
    # end

    # selected = lambda { |t|
    #   %~
    #   <li class="selected">
    #     <span>#{t}</span>
    #   </li>
    #   ~
    # }

    # unselected = lambda { |t, u|
    #   %~
    #   <li>
    #     <a href="#{u}">#{t}</a>
    #   </li>
    #   ~
    # }

    @app.controller_name == c_name && @app.action_name == a_name
  end

  def nav_bar
    @nav_bar ||= begin
      
      new_hash = {}

        #['/add-to-do/', '+ Add Stuff', :to_dos, :add ],
      
      [ [ 'home',         :main,    :show ],
        [ 'help',         :main,    :help],
        [ 'my-egg-timer', :egg,     :my],
        [ 'busy-noise',   :egg,     :busy],
        [ 'sign-up',      :member,  :new],
        [ 'account',      :account, :show       ],
        [ 'log-out',      :session, :destroy   ],
        [ 'log-in',       :session, :new       ],
        [ 'today',        :to_dos,  :today     ],
        [ 'tomorrow',     :to_dos,  :tomorrow  ],
        [ 'this-month',   :to_dos,  :this_month ],
        [ 'friend',       :lives,   :friend     ],
        [ 'family',       :lives,   :family    ],
        [ 'work',         :lives,   :worker    ],
        [ 'pet-owner',    :lives,   :pet_owner  ],
        [ 'celebrity',    :lives,   :celebrity ],
        [ 'bubblegum',    :topic,   :bubblegum],
        [ 'child-care',   :topic,   :child_care],
        [ 'computer',     :topic,   :computer],
        [ 'economy',      :topic,   :economy],
        [ 'hair',         :topic,   :skin],
        [ 'housing',      :topic,   :housing],
        [ 'health',       :topic,   :health],
        [ 'preggers',     :topic,   :preggers],
        [ 'salud',        :main,    :salud],
        [ 'news',         :topic,   :news],
				[ 'add-to-do',    :something, :add_to_do]
      ].each { |raw_shortcut, c_name, a_name|
				shortcut = raw_shortcut.gsub(/[^a-zA-Z0-9\_]/, '_')
        new_hash["selected_#{shortcut}"]   = @app.controller_name == c_name && @app.action_name == a_name
        new_hash["unselected_#{shortcut}"] = !new_hash["selected_#{shortcut}"]
      }

      new_hash
    end
  end

end # === Bunny_Mustache
