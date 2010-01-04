
class The_Flash_Msg

  attr_reader :success, :error

  def initialize hash = {}
    @success = hash[:success]
    @error   = hash[:error]
    @keep    = {}
  end

  def hash_for_next_session
    @keep
  end

  %{success error}.each { |meth|
    eval %~
      def #{meth}= msg
        @keep[:#{meth}] = msg
        @#{meth} = msg
      end
    ~
  }

end # === class The_Flash_Msg


class Flash_Msg

  def initialize new_app
    @app = new_app
  end

  def call env
    session                  = env['rack.session'] || {}
    env['flash.msg']         = The_Flash_Msg.new(session.delete('old.flash.msg'))
    results                  = @app.call(env)
    session['old.flash.msg'] = env['flash.msg'].hash_for_next_session
    results
  end

end # === class Flash_Msg
