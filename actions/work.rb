get "/my-work/" do
  require_log_in!
  describe :work, :show
  render_mab
end
