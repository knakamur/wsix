#!/usr/bin/env ruby

require 'rubygems'
require 'dm-core'
require 'dm-aggregates'
require 'models'
require 'pp'

class FixPS

  LOG = 'log/wsix.log'

  def self.main(*argv)
    DataMapper.setup :default, "mysql://wsix:k1ckb4ll@localhost/wsix"
    File.open(LOG).each do |line|
      if line =~ /^params \=\> \{ (\{.+\}) \}$/
        h = eval($1)
        if h['txn_id'] && h['payment_status'] == 'Completed'
          r = Racer.find_by_session_id h['custom']
          unless r.payment_status.paid? and r.payment_status._paypal_params
            puts "FOUND payment for #{r.name} #{r.email}"
            puts "calling #from_paypal..."
            r.payment_status.from_paypal(h)
            puts "and now, #{r.name} has #{r.payment_status.paid? ? '' : "STILL NOT "}paid.\n\n"
          end
        end
      end
    end
  end

end

FixPS.main ARGV
