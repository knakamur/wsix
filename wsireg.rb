#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'dm-core'
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://wsix@localhost/wsix_dev')
require 'models'

require 'md5'

require 'net/http'
require 'uri'
require 'base64'

enable :sessions


before do
  @bg = (rand * 7).round
  puts "\nparams => { #{params.inspect} }\n"
end


helpers do
  include Rack::Utils

  def session_rsid(user)
    @user = user
    session[:rsid] = @user.session_id
  end

  def user_from_rsid
    if session[:rsid]
      @user = Racer.find_by_session_id session[:rsid]
    end
  end
end


get '/' do
  @racers = Racer.all(:order => [:id.desc], :name.not => nil) || []
  erb :main
end


get '/register/start' do
  session.clear
  @password_salt = MD5.hexdigest [Array.new(255){rand(256).chr}.join].pack("m").chomp
  erb :'register/start'
end

post '/register/start' do
  @racer = Racer.first(:email => params[:email])
  if @racer
    @errors = "uh, we found your email in here already... remember your password?"
    erb :'register/login'
  else
    @racer = Racer.new :email => params[:email],
                       :password_hash => params[:password_hash],
                       :password_salt => params[:password_salt]

    @racer.payment_status = PaymentStatus.new(
      :type => (PaymentStatus::EARLY_PAYMENT_END > Date.today) ? "WSIXE" : "WSIX");

    if @racer.save
      session_rsid @racer
      erb :'register/moreinfo'
    else
      @errors = "whoa there tiger!"
      erb :'register/start'
    end
  end
end


get '/register/moreinfo' do
  user_from_rsid
  erb :'register/moreinfo'
end

put '/register/moreinfo' do
  user_from_rsid
  params[:user].delete_if {|k,v| v.blank?}

  unless @user.payment_status.paid_or_pending?
    params[:user][:shirt_requested] ||= 'false' # checkbox

    if params[:user][:shirt_requested] != @user.shirt_requested.to_s
      @user.payment_status.update :type => "WSIX" + 
        ((PaymentStatus::EARLY_PAYMENT_END > Date.today) ? "E" : "") +
        (params[:user][:shirt_requested].eql?(true.to_s) ? "S" : "")
    end
  end

  if @user.update(params[:user])
    redirect '/register/status'
  else
    @errors = "something went awry...<br/>"
    erb :'register/moreinfo'
  end
end


get '/register/done' do
  user_from_rsid
  erb :'register/done'
end

get '/register/status' do
  user_from_rsid
  redirect '/' unless @user
  erb :'register/status'
end


get '/register/login' do
  session.clear
  @racer = Racer.first(:email => params[:email])
  if @racer
    erb :'register/login'
  else
    @errors = "nope, don't know you. try again."
    erb :'register/start'
  end
end

post '/register/login' do
  @racer = Racer.first(:email => params[:email])
  if params[:password_hash].eql? @racer.password_hash
    session_rsid @racer

    if Racer.fieldmap.values.detect {|prop| @user.send(prop).nil?}
      erb :'register/moreinfo'
    else
      erb :'register/status'
    end

  else
    @errors = "nope, wrong password..."
    erb :'register/login'
  end
end

get '/register/logout' do
  session.clear
  redirect '/'
end

post '/paypal/ipn' do

  # ask paypal to verify the things they just sent
  res = Net::HTTP.post_form(
    URI.parse("http://www.sandbox.paypal.com/cgi-bin/webscr"),
    { "cmd" => "_notify-validate" }.merge(params))

  # if they say it's cool...
  if res.body.strip.eql? "VERIFIED"
    
    # check the txn_id to see if it's happened before...
    if PaymentStatus.first(:txn_id => params['txn_id'])
      # TODO batsignal!
    end
    
    user = Racer.find_by_session_id(params['custom'])

    # check the payment_status of the user in question...
    if user && user.payment_status.paid?
        return ""
        # TODO wha huh?
    end

    # check status 
    user.payment_status.from_paypal(params)

  else
    # TODO batsignal!
  end

end

post '/register/status' do
  user_from_rsid
  if params.has_key? 'custom' and params.has_key? 'payment_status' and @user.session_id.eql?(params['custom'])
    @user.payment_status.from_paypal(params)
    redirect '/register/status'
  else
    redirect '/'
  end
end
