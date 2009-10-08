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
      div.question "For Babies and up."
      div.answer {
        p 'The most important are: a multi-vitamin, Vitamin D3, and Vitamin C.'
        p {
          span "Go to: "
          a('LifeSpanNutrition.com', :href=>"http://www.lifespannutrition.com/")
          span ".  Under 'Product Search', there are menus. Use the one for 'Select Age Category'."
        }
      }
    }

  } # === ul
} # == div.content!



partial('__nav_bar')

