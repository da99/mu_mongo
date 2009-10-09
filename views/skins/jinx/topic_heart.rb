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
      div.question 'Cholesterol Fear'
      div.answer {
        span 'Buy e-book: '
        a('How to Lower Your Cholesterol Phobia', :href=>'http://www.naturalhealthlibrarian.com/ebook.asp?page=Cholesterol')
      }
    }

    li {
      div.question "Vitamin D3 + Magnesium Citrate"
      div.answer {
        p "Vitamin D3 with Magnesium Citrate is the most important for avoiding heart attacks."
        p 'LifeSpanNutrition.com – (800) 247-5731 (correo postal)'
        p '$15 - "30 Minutes of Sunshine"'
      }
    }


    li {
      div.question "Omega-3  fish oil - 1000 mg 3-6 times a day"
      div.answer {
        
        p "This is an oil, so take it with food or else you might get very nauseous."
        p "Buy a decent brand in your local big-chain pharmacy like Eckerd's, CVS, etc." 
        p "They are all basically the same. Don't spend too much. Buy the pharmacy brand if you can. "
        p "Take it 3-6 times a day, 2 or more gelcaps a day. "
        p "No adverse effects have been observed from high-dose Omege-3 fish oils."
        p "Unlike drugs, the more Omega-3 you take, the healthier you get."

      }
    }

    li {
      div.question "Vitamin C – 1000 mg, 3 times a day."
      div.answer {
        p "Buy the pharmacy brand."
        p "They are all the same. Buy it either as 500 mg or 1000 mg." 
        p "The important thing is to take it 3 times a day and develop the habit of taking it each day."
      }
    }

    li {
      div.question "Longevinex"
      div.answer {
        p 'Improves arteries and prevents calcifications (which clog arteries).'
        p {
          a('Longevinex.com', :href=>'http://www.longevinex.com/')
        }
      }
    }

  } # === ul
} # == div.content!



partial('__nav_bar')

