require 'rubygems'
require 'dm-core'
require 'models'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://wsix@localhost/wsix_dev')

desc "auto migrates datamapper tables."
task :dmau do
  DataMapper.auto_migrate!
end

desc "resets db with one racer email foo@bar, passwd 'testyy'."
task :redb => [:dmau] do
  Racer.new(:email => "foo@bar",
            :password_hash => "930945ae5ff0286b808b8e362a2c7e6b",
            :password_salt => "d901485c481d7882d7f75135c73fba4f").save
end
