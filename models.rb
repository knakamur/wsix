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

  property :veggie,           Boolean
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
  property :txn_id,  String, :length => 255

  property :_paypal_params, Text

  before :save do 
    self.updated = Time.now
  end

  @@types = {
    "WSIXE" => {  :description => "WSI X - early registration - no shirt",
                  #:hosted_button_id => "QJAKQZ7NEXQAY",
                  :amount =>      30 },
    "WSIXES" => { :description => "WSI X - early registration - shirt included",
                  #:hosted_button_id => "ELSVY6GSZNCY2",
                  :amount =>      35 },
    "WSIX" => {   :description => "WSI X - no shirt",
                  #:hosted_button_id => "T6ADCRQVLR6KU",
                  :amount =>      40 },
    "WSIXS" => {  :description => "WSI X - shirt included",
                  #:hosted_button_id => "23G8356YVBSUN",
                  :amount =>      45 }
  }
  def self.types
    @@types
  end
  
  def pending?
    paypal_status.eql?("Pending")
  end

  def paid_or_pending?
    paid? or pending?
  end

  def from_paypal(params = {})
    if params['payment_status'].eql? "Completed"
      update :paid => true,
             :when => Time.now,
             :txn_id => params['txn_id'],
             :amount => params['payment_gross'],
             :_paypal_params => p(params)
    else
      update :_paypal_params => p(params)
    end
  end

  def paypal_status
    paypal_params.nil? ? nil : paypal_params['payment_status']
  end

  def paypal_params
    _paypal_params.nil? ? nil : Marshal.load(Base64.decode64(_paypal_params))
  end

  def paypal_params=(params = nil)
    _paypal_params = params.nil? ? nil : p(params)
  end

  private

    def p(h={}) # see PaymentStatus#paypal_params=
      Base64.encode64(Marshal.dump(hc(h)))
    end

    def hc(h={}) # Marshal.dump doesn't like Hashes with default Procs
      r = Hash.new; h.each {|k,v| r[k]=v}; r
    end

end

class Object
  def dm
    DataMapper.setup :default, "mysql://wsix@localhost/wsix_dev"
  end
end
