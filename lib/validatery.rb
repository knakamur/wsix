module Validatery

  class ParameterValidationError < StandardError; end

  class Parameter
    def self.validate!(params = {}, conditions = {})
      conditions.each do |param_key, condition_array|
        condition_array.each do |cond|
          case cond.class
          when Regexp
            unless cond.match(params[param_key])
              raise ParameterValidationError.new "is not a valid email address. ex: someone@somewhere.tld"
            end
          when Integer
            unless params[param_key].length >= cond
              raise ParameterValidationError.new "is not a long enough password, i needs 6 or more glyphs."
            end
          when Symbol
            if params.has_key? cond
              unless params[cond].eql? params[param_key]
                raise ParameterValidationError.new "#{cond.to_s} does not match #{param_key.to_s}."
              end
            else
              raise ParameterValidationError.new "no parameter '#{cond.to_s}' supplied."
            end
          end
        end
      end
      nil
    end
  end

end
