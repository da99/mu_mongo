
configure do
  resty :news do 
    viewer :STRANGER, [ :list, :show ]
    c_u_d :ADMIN, [:title, :body, :teaser, :published_at, :tags]
  end
end

