configure do
  Struct.new('Flasher', :notice_msg, :error_msg, :success_msg )
end

before {

  @flasher_cache = Struct::Flasher.new
  @flasher_cache.members.each do |m|
    session_key = "__FLASHER__#{m}__".upcase.to_sym
    @flasher_cache.send("#{m}=", session[session_key] )
    session[session_key] = nil
  end

}


helpers {

  def flash
    @flasher_cache
  end
  
  def flash_keys
    @flasher_cache_keys ||= flash.members.map { |k| k.to_sym}
  end
  
  def flash_msg?
    !!( @any_flasher ||= flash_keys.detect {|k| flash.send(k) } )
  end

  # Mainly used in :redirect and :log_out.
  def keep_flash 
    return nil if !@flasher_cache
    flash_keys.each do |k|
      session_key = "__FLASHER__#{k}__".upcase.to_sym
      session[session_key] = flash.send(k)
    end
  end

} # === helpers
