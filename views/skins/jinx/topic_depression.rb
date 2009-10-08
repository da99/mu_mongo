save_to('title'){ "Safe Supplements for Severe Depression." }

save_to('meta_description') { 
  "Avoid drugs. Take supplements for your depression."
}

save_to('meta_keywords') {
  "methylcobalamin methyl-b-12 folic acid "
}



div.content!  { 
  ul.faq {
  
    li {
      div.question "Methyl B-12 (Methylcobalamin) - 1,000 mcg or more"
      div.answer {
        p 'Most walk-in pharmacies sell the cheap/useless version of B-12. Buy the best form online.'
        p "It has to say 'methyl' on the 'Nutrition Facts' label on the back of the bottle."
        p  {
          span "$13 at "
          a("http://www.luckyvitamin.com/item/itemKey/49044", :href=>"http://www.luckyvitamin.com/item/itemKey/49044")
        }
      }
    }

    li {
      div.question "Folic Acid - 1,600 mcg"
      div.answer {
        p {
          span "$6 at "
          a("http://www.luckyvitamin.com/item/itemKey/67601", :href=>"http://www.luckyvitamin.com/item/itemKey/67601")
        }
      }
    }

    li {
      div.question "Purity Products Perfect Multi Super Greens"
      div.answer {
        p "The best multivitamin I could find. "
        p {
          span '$30 at '
          a('http://www.lifespannutrition.com/products.asp?itemnumber=67', :href=>'http://www.lifespannutrition.com/products.asp?itemnumber=67')
        }
      }
    }

  } # === ul
} # == div.content!



partial('__nav_bar')

