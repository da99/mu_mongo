save_to('title'){ "Back pain vitamins and supplements." }

save_to('meta_description') { 
  "vitamins and supplements for back pain."
}

save_to('meta_keywords') {
  "back pain vitamins supplements"
}



div.content!  { 

  ul.faq {
  
    li {
      div.question "Methyl B-12."
      div.answer {
        span 'Buy: '
        a 'Methyl B-12 Now Foods Brain B-12, 100 Lozenges / 1000mcg (Pack of 2)', :href=>'http://www.amazon.com/gp/product/B001F0R7VE/ref=cm_cr_asin_lnk'
      }
    }

    li {
      div.question "Magnesium Citrate or Magnesium Malate"
      div.answer {
        span 'Buy: '
        a 'Source Naturals Magnesium Malate, 1250 mg, Tablets, 360 tablets', :href=>'http://www.amazon.com/gp/product/B000GFJJKQ/ref=cm_cr_asin_lnk'
      }
    }

    li {
      div.question 'Vitamin D3'
      div.answer {
        span 'Buy: '
        a('30 Minutes of Sunshine', :href=>'http://www.lifespannutrition.com/products.asp?itemnumber=393')
      }
    }

    li {
      div.question 'Comfrey Ointment'
      div.answer {
        span 'Buy: '
        a('Res-Q Ointment (Comfrey Ointment)', :href=>'http://www.amazon.com/gp/product/B00014DKU2/ref=cm_cr_asin_lnk')
      }
    }

  } # === ul
} # == div.content!



partial('__nav_bar')

