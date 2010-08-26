
module Views::Base_Club
  def owner?
    @is_owner ||= logged_in? && club.owner?(current_member)
  end
end # === module
