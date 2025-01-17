# frozen_string_literal: true

require 'mongoid/contextual/aggregable/none'

module Mongoid
  module Contextual

    # Context object used for performing bulk query and persistence
    # operations on a null set. The method interface of this class
    # is consistent with Mongoid::Contextual::Mongo.
    class None
      include Enumerable
      include Aggregable::None
      include Queryable

      attr_reader :criteria, :klass

      # Check if the context is equal to the other object.
      #
      # @example Check equality.
      #   context == []
      #
      # @param [ Array ] other The other array.
      #
      # @return [ true | false ] If the objects are equal.
      def ==(other)
        other.is_a?(None)
      end

      # Get the distinct field values in null context.
      #
      # @example Get the distinct values in null context.
      #   context.distinct(:name)
      #
      # @param [ String | Symbol ] _field The name of the field.
      #
      # @return [ Array ] An empty Array.
      def distinct(_field)
        []
      end

      # Iterate over the null context. There are no documents to iterate over
      # in this case.
      #
      # @example Iterate over the null context.
      #   context.each do |doc|
      #     puts doc.name
      #   end
      #
      # @return [ Enumerator ] The enumerator.
      def each(&block)
        if block_given?
          [].each(&block)
          self
        else
          to_enum
        end
      end

      # Do any documents exist for the context.
      #
      # @example Do any documents exist in the null context.
      #   context.exists?
      #
      # @example Do any documents exist for given _id.
      #   context.exists?(BSON::ObjectId(...))
      #
      # @example Do any documents exist for given conditions.
      #   context.exists?(name: "...")
      #
      # @param [ Hash | Object | false ] _id_or_conditions An _id to
      #   search for, a hash of conditions, nil or false.
      #
      # @return [ false ] Always false.
      def exists?(_id_or_conditions = :none)
        false
      end

      # Pluck the field values in null context.
      #
      # @example Get the values for null context.
      #   context.pluck(:name)
      #
      # @param [ [ String | Symbol ]... ] *_fields Field(s) to pluck.
      #
      # @return [ Array ] An empty Array.
      def pluck(*_fields)
        []
      end

      # Iterate through plucked field values in null context.
      #
      # @example Iterate through the values for null context.
      #   context.pluck_each(:name) { |name| puts name }
      #
      # @param [ [ String | Symbol ]... ] *_fields Field(s) to pluck.
      # @param [ Proc ] &block The block which will not be called
      #   due to null context.
      #
      # @return [ Enumerator | None ] An enumerator, or the context
      #   if a block was given.
      def pluck_each(*_fields, &block)
        enum = pluck(*_fields).each(&block)
        block_given? ? self : enum
      end

      # Pick the field values in null context.
      #
      # @example Get the value for null context.
      #   context.pick(:name)
      #
      # @param [ [ String | Symbol ]... ] *_fields Field(s) to pick.
      #
      # @return [ nil ] Always return nil.
      def pick(*_fields)
        nil
      end

      # Tally the field values in null context.
      #
      # @example Get the values for null context.
      #   context.tally(:name)
      #
      # @param [ String | Symbol ] _field Field to tally.
      # @param [ Boolean ] :unwind Whether to tally array
      #   member values individually. Default false.
      # @param [ String | Symbol ] _field Field to tally.
      #
      # @return [ Hash ] An empty Hash.
      def tally(_field, unwind: false)
        {}
      end

      # Create the new null context.
      #
      # @example Create the new context.
      #   Null.new(criteria)
      #
      # @param [ Mongoid::Criteria ] criteria The criteria.
      def initialize(criteria)
        @criteria = criteria
        @klass = criteria.klass
      end

      # Always returns nil.
      #
      # @example Get the first document in null context.
      #   context.first
      #
      # @param [ Integer ] limit The number of documents to return.
      #
      # @return [ [] | nil ] Empty array or nil.
      def first(limit = nil)
        [] unless limit.nil?
      end

      # Always raises an error.
      #
      # @example Get the first document in null context.
      #   context.first!
      #
      # @raises [ Mongoid::Errors::DocumentNotFound ] always raises.
      def first!
        raise_document_not_found_error
      end

      # Always returns nil.
      #
      # @example Get the last document in null context.
      #   context.last
      #
      # @param [ Integer ] limit The number of documents to return.
      #
      # @return [ [] | nil ] Empty array or nil.
      def last(limit = nil)
        [] unless limit.nil?
      end

      # Always raises an error.
      #
      # @example Get the last document in null context.
      #   context.last!
      #
      # @raises [ Mongoid::Errors::DocumentNotFound ] always raises.
      def last!
        raise_document_not_found_error
      end

      # Returns nil or empty array.
      #
      # @example Take a document in null context.
      #   context.take
      #
      # @param [ Integer | nil ] limit The number of documents to take or nil.
      #
      # @return [ [] | nil ] Empty array or nil.
      def take(limit = nil)
        limit ? [] : nil
      end

      # Always raises an error.
      #
      # @example Take a document in null context.
      #   context.take!
      #
      # @raises [ Mongoid::Errors::DocumentNotFound ] always raises.
      def take!
        raise_document_not_found_error
      end

      # Always returns nil.
      #
      # @example Get the second document in null context.
      #   context.second
      #
      # @return [ nil ] Always nil.
      def second
        nil
      end

      # Always raises an error.
      #
      # @example Get the second document in null context.
      #   context.second!
      #
      # @raises [ Mongoid::Errors::DocumentNotFound ] always raises.
      def second!
        raise_document_not_found_error
      end

      # Always returns nil.
      #
      # @example Get the third document in null context.
      #   context.third
      #
      # @return [ nil ] Always nil.
      def third
        nil
      end

      # Always raises an error.
      #
      # @example Get the third document in null context.
      #   context.third!
      #
      # @raises [ Mongoid::Errors::DocumentNotFound ] always raises.
      def third!
        raise_document_not_found_error
      end

      # Always returns nil.
      #
      # @example Get the fourth document in null context.
      #   context.fourth
      #
      # @return [ nil ] Always nil.
      def fourth
        nil
      end

      # Always raises an error.
      #
      # @example Get the fourth document in null context.
      #   context.fourth!
      #
      # @raises [ Mongoid::Errors::DocumentNotFound ] always raises.
      def fourth!
        raise_document_not_found_error
      end

      # Always returns nil.
      #
      # @example Get the fifth document in null context.
      #   context.fifth
      #
      # @return [ nil ] Always nil.
      def fifth
        nil
      end

      # Always raises an error.
      #
      # @example Get the fifth document in null context.
      #   context.fifth!
      #
      # @raises [ Mongoid::Errors::DocumentNotFound ] always raises.
      def fifth!
        raise_document_not_found_error
      end

      # Always returns nil.
      #
      # @example Get the second to last document in null context.
      #   context.second_to_last
      #
      # @return [ nil ] Always nil.
      def second_to_last
        nil
      end

      # Always raises an error.
      #
      # @example Get the second to last document in null context.
      #   context.second_to_last!
      #
      # @raises [ Mongoid::Errors::DocumentNotFound ] always raises.
      def second_to_last!
        raise_document_not_found_error
      end

      # Always returns nil.
      #
      # @example Get the third to last document in null context.
      #   context.third_to_last
      #
      # @return [ nil ] Always nil.
      def third_to_last
        nil
      end

      # Always raises an error.
      #
      # @example Get the third to last document in null context.
      #   context.third_to_last!
      #
      # @raises [ Mongoid::Errors::DocumentNotFound ] always raises.
      def third_to_last!
        raise_document_not_found_error
      end

      # Always returns zero.
      #
      # @example Get the length of null context.
      #   context.length
      #
      # @return [ Integer ] Always zero.
      def length
        entries.length
      end
      alias_method :size, :length
      alias_method :find_first, :first
      alias_method :one, :first

      private

      def raise_document_not_found_error
        raise Errors::DocumentNotFound.new(klass, nil, nil)
      end
    end
  end
end
