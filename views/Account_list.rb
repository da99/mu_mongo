# /home/da01/megauni/templates/English/mab/Account_list.rb
class Account_list < View_Base

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

