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

# ROUTES !!!

get '/' do
  @racers = Racer.all(:order => [:id.desc], :name) || []
  erb :main
end


get '/register/start' do
  session.clear
  @password_salt = MD5.hexdigest [Array.new(255){rand(256).chr}.join].pack("m").chomp
  erb :'register/start'
end

post '/register/start' do

  if Racer.first(:email => params[:email])
    redirect "/register/login?email=#{params[:email]}"
  end

  @racer = Racer.new :email => params[:email],
                     :password_hash => params[:password_hash],
                     :password_salt => params[:password_salt]
  @racer.save

  session[:rsid] = @racer.session_id

  erb :'register/moreinfo'

end


get '/register/moreinfo' do
  @racer = Racer.find_by_session_id session[:rsid]
  erb :'register/moreinfo'
end

put '/register/moreinfo' do
  @racer = Racer.find_by_session_id session[:rsid]
  erb :thing
end


get '/register/done' do
  erb :'register/done'
end


get '/register/login' do
  session.clear
  @racer = Racer.first(:email => params[:email])
  erb :'register/login'
end

post '/register/login' do
  @racer = Racer.first(:email => params[:email])
  if params[:password_hash].eql? @racer.password_hash
    session[:rsid] = @racer.session_id
    redirect '/register/moreinfo'
  else
    @errors = "nope, wrong password..."
    erb :'register/login'
  end
end

get '/register/logout' do
  session.clear
  redirect '/'
end
