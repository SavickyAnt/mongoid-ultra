# frozen_string_literal: true

module Mongoid
  class Criteria
    module Queryable
      module Extensions

        # Adds query type-casting behavior to Regexp class.
        module Regexp

          # Is the object a regexp?
          #
          # @example Is the object a regex?
          #   /\A[123]/.regexp?
          #
          # @return [ true ] Always true.
          def regexp?
            true
          end

          module ClassMethods

            # Evolve the object into a regex.
            #
            # @example Evolve the object to a regex.
            #   Regexp.evolve("\A[123]")
            #
            # @param [ Regexp | String ] object The object to evolve.
            #
            # @return [ Regexp ] The evolved regex.
            def evolve(object)
              __evolve__(object) do |obj|
                mongoize(obj)
              end
            end
          end

          # Adds query type-casting behavior to BSON::Regexp::Raw class.
          module RawExt

            # Is the object a regexp?
            #
            # @example Is the object a regex?
            #   bson_raw_regexp.regexp?
            #
            # @return [ true ] Always true.
            def regexp?
              true
            end

            module ClassMethods

              # Evolve the object into a raw bson regex.
              #
              # @example Evolve the object to a regex.
              #   BSON::Regexp::Raw.evolve("\\A[123]")
              #
              # @param [ BSON::Regexp::Raw | String ] object The object to evolve.
              #
              # @return [ BSON::Regexp::Raw ] The evolved raw regex.
              def evolve(object)
                __evolve__(object) do |obj|
                  obj.is_a?(String) ? BSON::Regexp::Raw.new(obj) : obj
                end
              end
            end
          end
        end
      end
    end
  end
end

Regexp.include Mongoid::Criteria::Queryable::Extensions::Regexp
Regexp.extend Mongoid::Criteria::Queryable::Extensions::Regexp::ClassMethods
BSON::Regexp::Raw.include Mongoid::Criteria::Queryable::Extensions::Regexp::RawExt
BSON::Regexp::Raw.extend Mongoid::Criteria::Queryable::Extensions::Regexp::RawExt::ClassMethods
