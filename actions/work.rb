controller(:Work) do

    get( :show, "/my-work", Member::MEMBER ) do
        render_mab
    end # === show

end  # === Admin_Roadie
