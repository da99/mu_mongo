
class Test_Couch_Plastic_Create < Test::Unit::TestCase

	must 'raise Raw_Data_Required if missing required field' do
		assert_raise Cafe_Le_Roger::Raw_Data_Field_Required do
			Cafe_Le_Roger.create nil, {}
		end
	end

  must 'set new field value using :must_be' do
    teaser = "My Teaser: #{rand(1000)}"
    doc = Cafe_Le_Roger.create(nil, {:title=>'My Title', :teaser=>teaser, :body=>'My Body'})
    assert_equal teaser, doc.data.teaser
  end

  must 'set new field value using :must_be!' do
    body = "My body #{rand(1000)}"
    doc = Cafe_Le_Roger.create(nil, {:title=>'My Title', :teaser=>'My Teaser', :body => body})
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

  must 'not set fields to proto_fields' do
    assert_not_equal Cafe_Le_Roger.fields, Cafe_Le_Roger.proto_fields
  end

  must 'not set proto field value' do
    big_body = "   My body #{rand(1000)}   "
    doc      = Cafe_Le_Roger.create( nil, 
                { :title =>'My Title', 
                  :teaser =>'My Teaser', 
                  :body =>"Test body.", 
                  :big_body =>big_body
                })
    new_doc  = Cafe_Le_Roger.by_id(doc.data._id)
    assert_equal nil, new_doc.data.as_hash[:big_body]
  end

  must 'not save proto field value' do
    big_body = "My body #{rand(1000)}"
    values   = {:title=>'My Title', :teaser=>'My Teaser', :body => "The Body", :big_body => big_body}
    doc      = Cafe_Le_Roger.create nil, values
    new_doc  = Cafe_Le_Roger.db_collection.find_one(:_id=>doc.data._id)
    
    orig_keys = values.keys
    orig_keys.delete(:big_body)
    orig_keys = orig_keys + [:_id, :_rev, :data_model] 
    
    assert_equal orig_doc.keys.sort, new_doc.keys.sort
  end
  
end # === class _create



# === Custom Classes for Testing ===

class Cafe_Le_Roger
	include Couch_Plastic

  allow_fields :title, :teaser, :body

  allow_proto_fields :big_body

  def self.create editor, raw_data
    new(nil, editor,raw_data) do
      demand :title, :teaser, :body
      ask_for :big_body
      save_create
    end
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

  def big_body_validator
    must_be { not_empty }
  end

end # === Cafe_Le_Roger

