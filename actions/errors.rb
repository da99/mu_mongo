error {

  if !request.fullpath["(null)"]
    IssueClient.create(env, options.environment, env['sinatra.error'] )
  end

  read_if_file('public/500.html') || "Programmer error found. I will look into it."

} # === error


not_found {

  # Add trailing slash and use a  permanent redirect.
  # Why a trailing slash? Many software programs
  # look for files by appending them to the url: /salud/robots.txt
  # Without adding a slash, they will go to: /saludrobots.txt
  if request.get? && !request.xhr? && request.query_string.to_s.strip.empty?

    if request.path_info != '/' &&  # Request is not for homepage.
        request.path_info !~ /\.[a-z0-9]+$/ &&  # Request is not for a file.
          request.path_info[ request.path_info.size - 1 , 1] != '/'  # Request does not end in /
      redirect( request.url + '/' , 301 )
    end

    uri_downcase = request.fullpath.downcase

    if uri_downcase != request.fullpath
      redirect uri_downcase
    end

    %w{ mobi mobile iphone pda }.each do |ending|
      if request.path_info.split('/').last.downcase == ending
        redirect( request.url.sub(/#{ending}\/?$/, 'm/') , 301 )
      end
    end

  end

  if !robot_agent?
    IssueClient.create(env,  options.environment, "404 - Not Found", "Referer: #{env['HTTP_REFERER']}" )
  end

  if request.xhr?
    '<div class="error">Action not found.</div>'
  else
    read_if_file('public/404.html') || "Page not found. Try checking for any typos in the address."
  end

} # === not_found



