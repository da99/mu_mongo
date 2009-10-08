save_to('title'){ "Avoid Dementia or Alzheimer's" }

save_to('meta_description') { 
  "Supplements to avoid age-related memory problems and Alzheimer's."
}

save_to('meta_keywords') {
  "dementia longevinex ip-6 Alzheimer's"
}



div.content!  { 
  ul.faq {
  
    li {
      div.question "Longevinex"
      div.answer {
        p "Avoid all medications and drugs. Including: aspirin, Advil, Tylenol, etc."
        p "Drugs to treat Alzheimer's do not work. Avoid them all."
        p "For best results, take at a later time than Vitamin C."
        p {
          a("Longevinex.com", :href=>"http://www.longevinex.com/")
          span " - (866) – 405-4000 – $37 (1 box),  $120 (4 boxes) "
        }
      }
    }

  } # === ul
} # == div.content!



partial('__nav_bar')

