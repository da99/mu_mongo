# /home/da01/megauni/templates/en-us/mab/Account_list.rb
class Account_list < Base_View

  def title 
    'My Account'
  end

  def lives
    @app.current_member.data.lives.map { |life_cat, life|
      { :category => life_cat,
        :username => life[:username]}
    }
  end

end

