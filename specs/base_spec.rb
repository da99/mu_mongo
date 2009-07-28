# ======================================================================
require 'ramaze'
require 'ramaze/spec/helper'
require __DIR__('../start')
# ======================================================================

require __DIR__('../lib/busy_fixture')


shared 'member_fixture' do

  before {

      data = [
      
             ["@stan",  # ====== First User.
              {
                :username=>"stan_smith",
                :password=>"my_account_with_check_list",
                :confirm_password => "my_account_with_check_list",
                :meta => {
                            :class=>"Member",
                            :search_by=>:username,
                            :alias => '@user_1'
                         },
             }],
               
             # ========== Start data for Second User.
             [ "@roger",
              {
                :username=>"roger_the_alien",
                :password=>"i_want_booze_now",
                :confirm_password => "i_want_booze_now",
                :meta => { :class=>"Member",
                          :search_by=>:username,
                          :alias => '@user_2'},
              }]
            ] # === end data
            
      BusyFixture.eval_this( data , binding)
      
  } # === end before

end # === shared 'member_fixture'


__END__

===============================       SCRAP      ===================



shared 'bundle_fixture'  do

  behaves_like 'member_fixture'

  before {
    test_data = []
    test_data << [
      "@bundle_reading", # === Bundle for First User.
      {
        :title=>"Reading Material for All Occassions",
        :meta=> { :class=>"Bundle",
          :search_by=>"@stan.bundles.first",
          :add_to=>"@stan",
          :alias => '@user_1_bundle_1'
        }
      }
     ]
     test_data << [
      "@bundle_drinks", # === 2nd Member's Bundle
        { :title => 'Roger\'s Bundle of Drinks for all Occassions',
          :meta  =>
            {:class=>"Bundle",
            :search_by=>"@roger.bundles.first",
            :add_to=>"@roger",
            :alias => "@user_2_bundle_1"
            },
        }]


    BusyFixture.eval_this(test_data, binding)
  }

end # === shared




shared 'check_list_fixture' do

  behaves_like 'bundle_fixture'

  before {
  
      data = [
       
       ["@check_list_mags",  # === This CheckList is part of a Bundle
        {
          :title=> "Books To Read While Flying",
          :body => "...or falling from an airplane.",
          :meta=>
          {:class=>"CheckList",
           :search_by=>"@bundle_reading.check_lists.first",
           :add_to=>"@bundle_reading",
           :alias => "@user_1_check_list_1"
          }
         }
       ],

       # ===== Add Items to previous CheckList.
       [ '@item_mag_neo_con',
          { :title => 'Neoconned - The Book',
            :meta  => {
              :class => 'CheckListItem',
              :add_to => '@check_list_mags.add_item',
              :create_if => '@check_list_mags.items.size < 1'
            }
          }
       ],
       
       [ '@item_mag_lrc',
          { :title => 'Darth Cheney - The Fun Side',
            :meta  => {
              :class => 'CheckListItem',
              :add_to => '@check_list_mags.add_item',
              :create_if => '@check_list_mags.items.size < 2'
            }
          }
       ],
         

         
       ["@check_list_night_drinks",  # === This CheckList is not part of any Bundle.
        { :title=>"Drinks for the night lounging.",
          :meta=> {:class=>"CheckList",
                   :search_by=>"@roger.check_lists.first",
                   :add_to=>"@roger",
                   :alias => "@user_2_check_list_1"
                   },
        }],
         
       ["@item_drink_1",
        {:meta=>
          {:create_if=>"@check_list_night_drinks.items.size < 1",
           :class=>"CheckListItem",
           :add_to=>"@check_list_night_drinks.add_item"},
         :title=>"Boba Fett"}],
         
       ["@item_drink_2",
        {:meta=>
          {:create_if=>"@check_list_night_drinks.items.size < 2",
           :class=>"CheckListItem",
           :add_to=>"@check_list_night_drinks.add_item"},
         :title=>"Snake"}],
         
       ["@item_drink_3",
        {:meta=>
          {:create_if=>"@check_list_night_drinks.trashed_items.size < 1",
           :after_add=>"trash_it!",
           :class=>"CheckListItem",
           :add_to=>"@check_list_night_drinks.add_item"},
         :title=>"Archer"}],
         
       ["@item_drink_4",
        {
          :title => "Crossbox",
          :meta  => {:create_if   => "@check_list_night_drinks.trashed_items.size < 2",
                     :after_add   => "trash_it!",
                     :class       => "CheckListItem",
                     :add_to      => "@check_list_night_drinks.add_item"
                    }
                  
        }]
        
      ]  # === end data
      
    BusyFixture.eval_this( data , binding)
    
  }

end # === shared


shared 'survey_fixture' do

  behaves_like 'member_fixture'

  before {
    test_data = []
    test_data << [
      "@what_books_to_read", # === Bundle for First User.
      {
        :title=>"Which book should I read?",
        :body=>"For the beach.",
        :status=>Survey::LIVE,
        :meta=> { :class=>"Survey",
          :search_by=>"@stan.surveys.first",
          :add_to=>"@stan",
          :alias => '@user_1_survey_1'
        }
      }
     ]

     BusyFixture.eval_this(test_data, binding)
  } # === before

end # === shared 'survey_fixture'


