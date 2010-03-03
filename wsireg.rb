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
  @racers = Racer.all(:order => [:id.desc]) || []
  erb :main
end


get '/register/start' do
  session.clear
  @password_salt = MD5.hexdigest [Array.new(255){rand(256).chr}.join].pack("m").chomp
  erb :'register/start'
end


post 'register/start' do
  @racer = Racer.new :email => params[:email],
                     :password_hash => params[:password_hash],
                     :password_salt => params[:password_salt]
  @racer.save
  session[:racer_id] = @racer.session_id
  erb :'register/moreinfo'
end


post 'register/moreinfo' do
  # eat some more stuff and poop it out.
  # redirect to paypal for moneys
  erb :thing
end


get 'register/done' do
  erb :'register/done'
end
