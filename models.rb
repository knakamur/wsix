require 'md5'

class Racer
  include DataMapper::Resource

  property :id, Serial

  property :email,         String, :length => 255
  property :name,          String, :length => 255
  property :password_hash, String, :length => 255
  property :password_salt, String, :length => 255

  property :address, String, :length => 255
  property :city,    String
  property :state,   String
  property :postal,  String
  property :phone,   String
  property :nextel,  String

  property :years_worked, Integer
  property :companies,    Text

  property :number_requested, Integer
  property :paid,             Boolean

  property :shirt_requested,  Boolean
  property :shirt_size,       String, :length => 2

  def session_id
    MD5.hexdigest(id + email + password_salt)
  end

  def self.find_by_session_id(sid)
    all.detect {|r| r.session_id.eql? sid}
  end

end

class Session
  include DataMapper::Resource

  property :id, Serial
  property :_session_id, String, :length => 255
  property :session_data, Text
end

DataMapper.auto_migrate!
