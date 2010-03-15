
class Test_Couch_Doc_Read < Test::Unit::TestCase

	must 'retrieve a UUID' do
		uuid = CouchDB_CONN.GET_uuid
		assert_match( /\A[a-z0-9]{10,}\Z/i, uuid )
	end

end # === class _read
