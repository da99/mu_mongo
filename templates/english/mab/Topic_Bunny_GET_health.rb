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
        'More info. coming soon about back pain.'
      }
    }

    li { a 'Arthritis (osteo & rhumatoid)', :href=>'/arthritis/' } # ,   :topic, :arthritis
    li { a 'Back Pain' ,  :href=>'/back-pain/'  } # ,   ,           :topic, :back_pain
    li { a 'Cancer',  :href=>'/cancer/'    } # ,   ,              :topic, :cancer
    li { a 'Dementia/Alzheirmer',  :href=>'/dementia/'    } # ,   , :topic, :dementia
    li { a 'Depression',  :href=>'/depression/' } # ,   ,          :topic, :depresssion
    li { a 'Flu/Cold',  :href=>'/flu/'        } # ,   ,            :topic, :flu
    li { a 'Heart & Diabetes',  :href=>'/heart/'    } # ,   ,   :topic, :heart
    li { a 'HIV/AIDS/STDs',  :href=>'/hiv/'    } # ,   ,       :topic, :hiv
    li { a 'Osteoporosis & Menopause', :href=>'/meno-osteo/' } # ,   ,      :topic, :meno_osteo
    li { a 'Other Health', :href=>'/health/'     } # ,   ,        :topic, :health



  } # === ul
} # == div.content!



partial('__nav_bar')

