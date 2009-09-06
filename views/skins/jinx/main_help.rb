save_to('title'){ "To Serve Man." }

save_to('meta_description') { 
  "Do you need help?"
}

save_to('meta_keywords') {
  "cancer gold vitamins depression"
}


partial('__nav_bar')


div.content!  { 
  ul.faq {
  
     li {
      div.question "What is MegaUNi.com?"
      div.answer {
        span "A unification of past ideas/websites I've worked on."
      }
    }

    li {
      div.question "I'm worried about the economy."
      div.answer {
        span "You should be. It's a Depression, not a Recession."
      }
    } 
  
    li {
      div.question "I'm old. What should I do?"
      div.answer {
        span "Buy: "
        a('Longevinex Advantage.', :href=>'http://www.LongevinexAdvantage.com/')
        br 
        span "For: Sleep, memory loss, rheumatoid arthritis, osteo-arthritis, cancer, energy, diabetes.
        Yes. I'm serious. Everyone I know who has tried it has shown improvement in those conditions 
        and 90%-100% pain loss."
        
      }
    } 


    li {
      div.question "Are there better alternatives to anti-depressants?"
      div.answer {
        span "First, stop seeing the idiot doctor who prescribes useless, harmful anti-depressants."
        span "Second, take "
        a("Methyl-B12 and Folic acid.", :href=>'http://www.google.com/search?q=methyl-b12+folic+acid+depression')
        span '(via '
        a('The Natural Health Librarian.', :href=>'http://www.naturalhealthlibrarian.com/')
        span ' Buy their e-books. Great stuff.)'
      }
    }      
     
  } # === ul
} # == div.content!

