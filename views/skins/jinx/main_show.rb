save_to('title'){ "Coming Soon..." }

save_to('meta_description') { 
  the_app.options.site_tag_line
}

save_to('meta_keywords') {
  the_app.options.site_keywords
}


partial('__nav_bar')


div.content!  "Coming Soon..." , :style=>"font-family: courier; font-size: 25px; font-weight: bold;"

