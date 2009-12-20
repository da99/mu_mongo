# /home/da01/megauni/templates/english/mab/Account_list.rb
class Account_list < Bunny_Mustache

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

