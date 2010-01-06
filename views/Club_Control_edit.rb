# MAB   /home/da01/MyLife/apps/megauni/templates/English/mab/Club_Control_edit.rb
# SASS  /home/da01/MyLife/apps/megauni/templates/English/sass/Club_Control_edit.sass
# NAME  Club_Control_edit

class Club_Control_edit < Club_Control_Base_View

  def title 
    "Editing Club: #{club.data.title}"
  end

  def news
    @news ||= News.by_published_at(:limit=>5)
  end
	
end # === Club_Control_edit 
