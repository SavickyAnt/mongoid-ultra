# frozen_string_literal: true

module Mongoid
  module Matcher

    # In-memory matcher for $regex expression.
    #
    # @see https://www.mongodb.com/docs/manual/reference/operator/query/regex/
    #
    # @api private
    module Regex

      extend self

      # Returns whether a value satisfies a $regex expression.
      #
      # @param [ true | false ] exists Not used.
      # @param [ String | Array<String> ] value The value to check.
      # @param [ Regexp | BSON::Regexp::Raw ] condition The $regex condition.
      #
      # @return [ true | false ] Whether the value matches.
      #
      # @api private
      def matches?(exists, value, condition)
        condition = case condition
                    when Regexp
                      condition
                    when BSON::Regexp::Raw
                      condition.compile
                    else
                      # Note that strings must have been converted to a regular expression
                      # instance already (with $options taken into account, if provided).
                      raise Errors::InvalidQuery.new("$regex requires a regular expression argument: #{Errors::InvalidQuery.truncate_expr(condition)}")
                    end

        case value
        when Array
          value.any? do |v|
            v =~ condition
          end
        when String
          value =~ condition
        else
          false
        end
      end

      # Returns whether an scalar or array value matches a Regexp.
      #
      # @param [ true | false ] exists Not used.
      # @param [ String | Array<String> ] value The value to check.
      # @param [ Regexp ] condition The Regexp condition.
      #
      # @return [ true | false ] Whether the value matches.
      #
      # @api private
      def matches_array_or_scalar?(value, condition)
        if value.is_a?(Array)
          value.any? do |v|
            matches?(true, v, condition)
          end
        else
          matches?(true, value, condition)
        end
      end
    end
  end
end
