get "/my-work/" do
  require_log_in!
  controller :work
  action :show
  render_mab
end
