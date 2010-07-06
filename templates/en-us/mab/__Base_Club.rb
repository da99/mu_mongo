
module Base_Club

  def loop_clubs list_name, *opts
    text(capture {
      loop list_name do 
        div.club {
          h4 {
            a('{{title}}', :href=>'{{href}}')
          }
          show_if 'teaser' do
            div.teaser '{{teaser}}'
          end
          
          loop_messages 'messages', *opts
        }
      end
    })
  end

  def club_nav_bar filename
    file     = File.basename(filename).sub('.rb', '')
    li_span  = lambda { |txt| li.selected { span txt } }
    li_ahref = lambda { |txt, href| li { a('txt', :href=>href) } }
    vals = [ 
      [/_filename\Z/   , 'Home'               , '']            ,
      [/_e\Z/          , 'Encyclopedia'       , 'e/']          ,
      [/_news\Z/       , 'News'               , 'news/']       ,
      [/_magazine\Z/       , 'Magazine'               , 'magazine/']       ,
      [/_fights\Z/     , 'Fights', 'fights/']     ,
      [/_qa\Z/         , 'Q & A'              , 'qa/']         ,
      [/_shop\Z/       , 'Shop'               , 'shop/']       ,
      [/_predictions\Z/, 'Predictions'        , 'predictions/'],
      [/_random\Z/     , 'Random'             , 'random/'],
      [/_thanks\Z/     , 'Thanks'             , 'thanks/']
    ]
    text(capture {

      ul.club_nav_bar! {
        vals.each { |trip|
          if file =~ trip[0]
            li.selected  trip[1] 
          else
            li { a(trip[1], :href=>'{{club_href}}' + trip[2] ) }
          end
        }

        mustache 'logged_in?' do
          li { a('Log-out', :href=>'/log-out/') }
        end

        mustache 'not_logged_in?' do
          li { a('Log-in', :href=>'/log-in/') }
        end
        
        li { a('Megauni', :href=>'/') }
      } # ul
      
 
      mustache('logged_in?') {

        mustache 'owner?' do
          p 'You own this universe.'
        end
      
        mustache 'follower_but_not_owner?' do
          p "You are following this club."
        end

        mustache 'potential_follower?' do
          mustache 'single_username?' do
            p {
              a("Follow this club.", :href=>"{{follow_href}}")
            }
          end
          mustache 'multiple_usernames?' do
            form.form_follow_create!(:action=>"/clubs/follow/", :method=>'post') do
              fieldset {
                label 'Follow this club as: ' 
                select(:name=>'username') {
                  mustache('current_member_usernames') {
                  option('{{username}}', :value=>'{{username}}')
                }
                }
              }
              div.buttons { button 'Follow.' }
            end
          end
        end

      }

    })
  end

  

end # === module
