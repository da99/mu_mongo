require 'tests/__helper__'

class Couch_Plastic_Create < Test::Unit::TestCase

	must 'raise Raw_Data_Required if missing required field' do
		assert_raise Cafe_Le_Roger::Raw_Data_Field_Required do
			Cafe_Le_Roger.create nil, {}
		end
	end

end # === class _create



# === Custom Classes for Testing ===

class Cafe_Le_Roger
	include Couch_Plastic

	def before_create
		demand :title
	end

	def creator? editor
		true
	end

	def title_validator
		sanitize { strip }
	end

end # === Cafe_Le_Roger

