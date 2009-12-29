
class Topic
  include Base_Control

  List = %w{
    arthritis
    back_pain
    bubblegum
    cancer
    child_care
    computer
    dementia
    depression
    economy
    flu
    hair
    health
    heart
    hiv
    housing
    meno_osteo
    news
    preggers
  }

  List.each { |topic|
    eval %~
      def GET_#{topic}
        render_html_template
      end
    ~
  }
end # === Topic
