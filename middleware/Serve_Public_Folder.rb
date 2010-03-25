

class Serve_Public_Folder


    def initialize(app, folders=[])
      @app = app
      @folders = folders
      @exts = %w{
        .css
        .swf
        .html
        .mp3
        .wav
        .js
        .gif
        .jpg
        .png
      }
      @files = %w{
        favicon.ico
        robots.txt
      }
      @file_server = Rack::File.new('public')
    end

    def call(env)
      path           = env["PATH_INFO"]
      valid_ext      = @exts.include?( File.extname(path) )
      valid_dir      = @folders.detect { |folder| path.index(folder) === 0 }
      valid_file     = @files.include?(File.basename(path))
      try_to_serve   = valid_ext || valid_dir || valid_file
      
      if try_to_serve
        results = @file_server.call(env)
        return results if results.first === 200
        
        index_path = File.join('public', path, 'index.html')
        new_env = env.dup
        new_env['PATH_INFO'] = File.join(new_env['PATH_INFO'], 'index.html')
        results =  @file_server.call(new_env)
        return results if results.first === 200
      end
      
      @app.call(env)
    end

end # ===
