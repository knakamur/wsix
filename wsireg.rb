#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'dm-core'
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://wsix@localhost/wsix_dev')
require 'models'

require 'lib/rfc822'
require 'md5'

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
  params[:user][:shirt_requested] ||= 'false' # checkbox

  if params[:user][:shirt_requested] != @user.shirt_requested.to_s
    @user.payment_status.update :type => "WSIX" + 
      ((PaymentStatus::EARLY_PAYMENT_END > Date.today) ? "E" : "") +
      (params[:user][:shirt_requested].eql?(true.to_s) ? "S" : "")
  end

  if @user.update(params[:user])
    erb :'register/status'
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
