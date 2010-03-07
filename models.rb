require 'md5'
require 'base64'
require 'dictionary'

class Racer
  include DataMapper::Resource

  has 1, :payment_status

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

  @@fieldmap = Dictionary[
    "name",              "name",
    "street address",    "address",
    "city",              "city",
    "state/province",    "state",
    "postal/zip code",   "postal",
    "phone",             "phone",
    "nextel",            "nextel"
  ]
  def self.fieldmap
    @@fieldmap
  end

  def session_id
    MD5.hexdigest(id.to_s + email + password_salt)
  end

  def self.find_by_session_id(sid)
    all.detect {|r| r.session_id.eql? sid}
  end

  def payment_type
    PaymentStatus.types[self.payment_status.type]
  end

end

class PaymentStatus
  include DataMapper::Resource

  EARLY_PAYMENT_END = Date.civil(2010, 5, 1)

  belongs_to :racer

  property :id, Serial

  property :type,    String
  property :amount,  Float
  property :updated, DateTime

  property :paid,    Boolean, :default => false
  property :when,    DateTime
  property :confirmation_code, String
  property :transaction_id,    String

  before :save do 
    self.updated = Time.now
  end

  @@types = {
    "WSIXE" => {  :description => "WSI X - early registration - no shirt",
                  :hosted_button_id => "QJAKQZ7NEXQAY",
                  :amount =>      30 },
    "WSIXES" => { :description => "WSI X - early registration - shirt included",
                  :hosted_button_id => "ELSVY6GSZNCY2",
                  :amount =>      35 },
    "WSIX" => {   :description => "WSI X - no shirt",
                  :hosted_button_id => "T6ADCRQVLR6KU",
                  :amount =>      40 },
    "WSIXS" => {  :description => "WSI X - shirt included",
                  :hosted_button_id => "23G8356YVBSUN",
                  :amount =>      45 }
  }
  def self.types
    @@types
  end
  
  alias_method :paid, :paid?

end

#class DbSession
#  include DataMapper::Resource
#
#  property :_session_id, String, :length => 255, :key => true
#  property :session_data, Text
#
#  alias_method :original_session_data=, :session_data=
#  alias_method :original_session_data,  :session_data
#  def session_data=(data)
#    self.original_session_data = Base64.encode64(Marshal.dump(data))
#  end
#  def session_data
#    Marshal.load(Base64.decode64(self.original_session_data))
#  end
#
#end
