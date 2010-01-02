require 'tests/__helper__'

class Couch_Plastic_Create < Test::Unit::TestCase

	must 'raise Raw_Data_Required if missing required field' do
		assert_raise Cafe_Le_Roger::Raw_Data_Field_Required do
			Cafe_Le_Roger.create nil, {}
		end
	end

  must 'set new field value using :must_be' do
    teaser = "My Teaser: #{rand(1000)}"
    doc = Cafe_Le_Roger.create nil, {:title=>'My Title', :teaser=>teaser, :body=>'My Body'}
    assert_equal teaser, doc.data.teaser
  end

  must 'set new field value using :must_be!' do
    body = "My body #{rand(1000)}"
    doc = Cafe_Le_Roger.create nil, {:title=>'My Title', :teaser=>'My Teaser', :body => body}
    assert_equal body, doc.data.body
  end

  must 'save field value to db using :must_be' do
    teaser = "My Teaser: #{rand(1000)}"
    doc = Cafe_Le_Roger.create nil, {:title=>'My Title', :teaser=>teaser, :body=>'My Body'}
    new_doc = Cafe_Le_Roger.by_id(doc.data._id)
    assert_equal teaser, new_doc.data.teaser
  end

  must 'save field value to db using :must_be!' do
    body = "My body #{rand(1000)}"
    doc = Cafe_Le_Roger.create nil, {:title=>'My Title', :teaser=>'My Teaser', :body => body}
    new_doc = Cafe_Le_Roger.by_id(doc.data._id)
    assert_equal body, new_doc.data.body
  end
  
end # === class _create



# === Custom Classes for Testing ===

class Cafe_Le_Roger
	include Couch_Plastic

  allow_fields :title, :teaser, :body

	def before_create
		demand :title, :teaser, :body
	end

	def creator? editor
		true
	end

	def title_validator
		sanitize { strip }
	end

  def teaser_validator
    must_be { not_empty }
  end

  def body_validator
    must_be! { not_empty }
  end

end # === Cafe_Le_Roger

