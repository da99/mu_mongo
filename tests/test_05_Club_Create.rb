
require 'tests/__helper__'


class Club_Create < Test::Unit::TestCase

  def self.admin_user
    @admin ||= begin
                 mem_id = CouchDB_CONN.GET_by_view(:member_usernames, {:limit=>1})[:rows].first[:value]
                 Member.by_id(mem_id)
               end
  end
  
  def self.regular_user
    @regular_user ||= begin
                        mem_id = CouchDB_CONN.GET_by_view(:member_usernames, {:limit=>2})[:rows].last[:value]
                        Member.by_id(mem_id)
                      end
  end

  def admin_user
    self.class.admin_user
  end

  def regular_user
    self.class.regular_user
  end

  def random_filename
    "movie_#{rand(10000)}"
  end

  must 'only allow ADMIN' do
    assert_raise( Club::Unauthorized_Creator ) do
      Club.create(regular_user,  { 
        :filename => random_filename,
        :title=>'Gaijin', 
        :teaser=>'Gaijin'
      })
    end
  end

  must 'set :_id to filename with "club-" prefixed' do
    fn = random_filename
    club = Club.create(
      admin_user, 
      { :filename => fn,
        :title=>'Gaijin', 
        :teaser=>'Gaijin'}
    )
    assert_equal "club-#{fn}", club.data._id
  end

  must 'require a unique filename' do
    old      = CouchDB_CONN.GET_by_view(:clubs, {:limit =>1})[:rows].first[:key]
    filename = old.sub('club-', '')
    club = begin
             Club.create( admin_user,
              {:filename=>filename, :title=>old, :teaser=>old} 
             )
           rescue Club::Invalid => e
             e.doc
           end
    assert_equal "Filename already taken: #{filename}", club.errors.first
  end

  must 'require a filename' do
    club = begin
             Club.create(
               admin_user, 
               { :filename=>nil,
                 :title=>'Gaijin', 
                 :teaser=>'Gaijin'}
             )
           rescue Club::Invalid => e
             e.doc
           end
    assert_equal 'Filename is required.', club.errors.first
  end
  
  must 'require a title' do
    club = begin
             Club.create(
               admin_user, 
               { :filename=>random_filename, 
                 :title => nil, 
                 :teaser=>'Gaijin'}
             )
           rescue Club::Invalid => e
             e.doc
           end
    assert_equal 'Title is required.', club.errors.first
  end

  must 'require a teaser' do
    club = begin
             Club.create(
               admin_user, 
               { :filename=>random_filename, 
                 :title=>'Gaijin',
                 :teaser=> nil
                 }
             )
           rescue Club::Invalid => e
             e.doc
           end
    assert_equal 'Teaser is required.', club.errors.first

  end

  must 'set "English" as the language.' do
    club = Club.create(
            admin_user, 
            {:filename=>random_filename, 
             :title=>'Gaijin',
             :teaser=>'Relaxed'}
    )
    assert_equal 'English', club.data.lang
  end


end # === _create
