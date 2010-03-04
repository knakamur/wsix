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


helpers do
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
    @racer.save
    session_rsid @racer
    erb :'register/moreinfo'
  end
end


get '/register/moreinfo' do
  erb :'register/moreinfo'
end

put '/register/moreinfo' do
  user_from_rsid
  @user.update(params[:user])
  erb :'register/status'
end


get '/register/done' do
  user_from_rsid unless @user
  erb :'register/done'
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
    erb :'register/moreinfo'
  else
    @errors = "nope, wrong password..."
    erb :'register/login'
  end
end

get '/register/logout' do
  session.clear
  redirect '/'
end
