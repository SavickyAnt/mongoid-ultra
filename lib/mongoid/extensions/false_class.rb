# frozen_string_literal: true

module Mongoid
  module Extensions

    # Adds type-casting behavior to FalseClass.
    module FalseClass

      # Get the value of the object as a mongo friendly sort value.
      #
      # @example Get the object as sort criteria.
      #   object.__sortable__
      #
      # @return [ Integer ] 0.
      def __sortable__
        0
      end

      # Is the passed value a boolean?
      #
      # @example Is the value a boolean type?
      #   false.is_a?(Boolean)
      #
      # @param [ Class ] other The class to check.
      #
      # @return [ true | false ] If the other is a boolean.
      def is_a?(other)
        return true if other == Mongoid::Boolean || other.instance_of?(Mongoid::Boolean)

        super(other)
      end
    end
  end
end

FalseClass.include Mongoid::Extensions::FalseClass
