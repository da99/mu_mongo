
require 'json' # Mainly used by CouchDB.


def json_parse(str)
  results = JSON.parse(str)
  begin
    results.symbolize_hash_keys
  rescue NoMethodError
    begin
      results.symbolize_keys
    rescue NoMethodError
      results
    end
  end
end


