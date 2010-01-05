

mustache 'flash_msg?' do

  div.flash_msg! do
    mustache 'flash_success' do
      div.success do
        h4 'Success'
        div.msg '{{msg}}'
      end
    end

    mustache 'flash_errors' do
      div.errors do
        h4 '{{title}}'
        div.msg { 
          ul {
            mustache 'errors' do 
              li '{{err}}'
            end
          }
        }
      end
    end
  end

end



