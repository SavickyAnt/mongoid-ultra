# frozen_string_literal: true

module Mongoid
  class Criteria

    # Mixin module for Mongoid::Criteria which adds custom
    # Marshal.dump functionality.
    module Marshalable

      # Provides the data needed to Marshal.dump a criteria.
      #
      # @example Dump the criteria.
      #   Marshal.dump(criteria)
      #
      # Note :mongo is written here for backwards compatibility with Mongoid 7
      # and earlier.
      #
      # @return [ Array<Object> ] The dumped data.
      def marshal_dump
        data = [klass, :mongo, inclusions, documents, strategy, negating]
        data.push(scoping_options).push(dump_hash(:selector)).push(dump_hash(:options))
      end

      # Resets the criteria object after a Marshal.load
      #
      # @example Load the criteria.
      #   Marshal.load(criteria)
      #
      # @param [ Array ] data The raw data.
      def marshal_load(data)
        @scoping_options, raw_selector, raw_options = data.pop(3)
        @klass, driver, @inclusions, @documents, @strategy, @negating = data
        @selector = load_hash(Queryable::Selector, raw_selector)
        @options = load_hash(Queryable::Options, raw_options)
      end

      private

      def dump_hash(name)
        send(name).each_with_object({}) do |(key, value), raw|
          raw[key] = value
        end
      end

      def load_hash(hash_class, raw)
        hash = hash_class.new(klass.aliased_fields, klass.fields)
        hash.merge!(raw)
        hash
      end
    end
  end
end
