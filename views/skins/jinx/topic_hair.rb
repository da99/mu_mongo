save_to('title'){ "Skin & Hair." }

save_to('meta_description') { 
  "Slow down Loss of Hair"
}

save_to('meta_keywords') {
  "hair skin vitamins alternatives shampoo"
}



div.content!  { 

  p 'More info. coming on SLS.'
  
  ul.faq {
  
    li {
      div.question "Body/Hands/Face"
      div.answer {
        a('Dr. Woods Black Soap', :href=>"http://www.luckyvitamin.com/item/keyword/black+soap/itemKey/61865")
      }
    }

    li {
      div.question 'Shampoo'
      div.answer { 
        a('Kirk\'s Natural - Original Coco Castile', :href=>"http://www.luckyvitamin.com/item/itemKey/75203")
      }
    }

    li {
      div.question 'Bar Soap'
      div.answer {
        a('Kirk\'s Natural - Bar', :href=>"http://www.luckyvitamin.com/item/itemKey/75211")
      }
    }


  } # === ul
} # == div.content!



partial('__nav_bar')

