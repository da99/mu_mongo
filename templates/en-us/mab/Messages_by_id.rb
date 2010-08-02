# VIEW views/Messages_by_id.rb
# SASS ~/megauni/templates/en-us/sass/Messages_by_id.sass
# NAME Messages_by_id

show_if 'show_moving_message?' do
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
end

h3.club_title! '{{club_title}}' 

club_nav_bar __FILE__, :follow_href=>false

div.outer_shell! {
  div.inner_shell! {
  
div.message!{

  mustache 'message_data' do
    h3 '{{message_title}}'
    div.body { '{{{compiled_body}}}' }
  end

  div.about! {

    h4 'About this content:'
    
    div {
      strong "Published on:"
      br
      span '{{published_at}}'
    }
    div {
      strong "Category:"
      br
      span "{{message_model_in_english}}."
    }
    div {
      strong 'Publication:'
      br
      a('{{club_title}}', :href=>'{{club_href}}')
    }
    div {
      strong 'Section: '
      br
      a('{{message_section}}', :href=>'{{message_section_href}}')
    }

    show_if 'message_updator?' do
      div {
        a('Edit.', :href=>'{{message_href_edit}}')
      }
      show_if 'message_updated?' do
        a('History of changes.', :href=>'{{message_href_log}}')
      end
    end

  } # div.about!

  div.replies! {

    show_if 'comments?' do
      div.comments! {
        h4 'YAYs & BOOs:'
        loop_messages 'comments', :include_meta=>true, :include_permalink=>false
      } 
    end

    show_if 'questions?' do
      div.questions! {
        h4 'Questions:'
        loop_messages 'questions', :include_meta=>true, :include_permalink=>false
      }
    end

    show_if 'logged_in?' do
      
      div.reply! {
        div.guide! {
          h4 'Stuff you can do:'
          p %~
            Express negative feelings. Try to use
          polite profanity, like meathead instead of 
          doo-doo head.
          ~
        }
        
        form_message_create(
          :title => 'Publish a new:',
          :models => %w{cheer jeer question},
          :hidden_input => {
                            :parent_message_id => '{{message_id}}',
                            :privacy       => 'public'
                           }
        )
      } # === div.reply!
      
    end # logged_in?
    
  } # === div.reply!
  
} # div.message!

} }
# ==================== REPLIES =========================================

# partial('__nav_bar')

