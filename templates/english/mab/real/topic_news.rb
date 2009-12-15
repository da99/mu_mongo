save_to('title'){ "To Serve Man." }

save_to('meta_description') { 
  "Do you need help?"
}

save_to('meta_keywords') {
  "cancer vitamins "
}



div.content!  { 
  ul.faq {
  
    li {
      div.question "Not ready."
      div.answer {
        span 'Try this section until this section is finished:'
        a('Bubblegum Pop', :href=>'/bubblegum/')
      }
    }

  } # === ul
} # == div.content!



partial('__nav_bar')

