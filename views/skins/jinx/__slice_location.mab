div(:class=>@slice_location.css_classes) {
      
      div.intro {
        div.title @slice_location.title
        # div.description( @slice_location.description || '' )

        ul.actions {
          li { a('Add Item', :href=>a_href(@slice_location, :new_item)) }
          
          if slice_location.items > 2
            li { a('Add Holiday', :href=>a_href(@slice_location, :add_holiday) ) }
          end
          
          li { a('Edit Settings', :href=>a_href(@slice_location, :edit)) }
        }
      }

      div.summary {

        div.public_or_private.field {
          span.title 'Privacy:'
          span.field_value( @slice_location.private ? 'Private' : 'Public') 
        }

        # div.last_article_at {
        #    span.title 'Last article posted: '
        #    span.datetime(
        #        @slice_location.last_article_at ?
        #         @slice_location.last_article_at.to_s :
        #         'None.'            
        #    )
        # }
        
        # div.next_article_at {
        #  span.title 'Next article at:'
        #  span.datetime(
        #    @slice_location.next_article_at ? 
        #    @slice_location.next_article_at.to_s :
        #    'None'
        #  )
        # }

        #div.last_comment_at {
        #  span.title 'Last comment at:'
        #  span.datetime(
        #    @slice_location.last_comment_at ? 
        #    @slice_location.last_comment_at.to_s :
        #    'None'
        #  )
        # }
      } # div.summary

}  # div.slice_location

