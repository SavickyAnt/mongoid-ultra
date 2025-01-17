# frozen_string_literal: true

module Mongoid
  module Indexable
    module Validators

      # Validates the options passed to the index macro.
      module Options
        extend self

        VALID_OPTIONS = %i[
          database
          default_language
          language_override
          name
          sparse
          unique
          max
          min
          bits
          bucket_size
          expire_after_seconds
          weights
          storage_engine
          key
          sphere_version
          text_version
          version
          partial_filter_expression
          collation
          wildcard_projection
        ].freeze

        VALID_TYPES = [
          1,
          -1,
          '2d',
          '2dsphere',
          'geoHaystack',
          'text',
          'hashed'
        ].freeze

        # Validate the index specification.
        #
        # @example Validate the index spec.
        #   Options.validate(Band, name: 1)
        #
        # @param [ Class ] klass The model class.
        # @param [ Hash ] spec The index specification.
        # @param [ Hash ] options The index options.
        #
        # @raise [ Errors::InvalidIndex ] If validation failed.
        def validate(klass, spec, options)
          validate_spec(klass, spec, options)
          validate_options(klass, spec, options)
        end

        private

        # Validates the options of the index spec.
        #
        # @api private
        #
        # @example Validate the options.
        #   Options.validate_options(Band, name: 1)
        #
        # @param [ Class ] klass The model class.
        # @param [ Hash ] spec The index specification.
        # @param [ Hash ] options The index options.
        #
        # @raise [ Errors::InvalidIndex ] If validation failed.
        def validate_options(klass, spec, options)
          options.each_pair do |name, value|
            unless VALID_OPTIONS.include?(name)
              raise Errors::InvalidIndex.new(klass, spec, options)
            end
          end
        end

        # Validates the index spec.
        #
        # @api private
        #
        # @example Validate the spec.
        #   Options.validate_spec(Band, name: 1)
        #
        # @param [ Class ] klass The model class.
        # @param [ Hash ] spec The index specification.
        # @param [ Hash ] options The index options.
        #
        # @raise [ Errors::InvalidIndex ] If validation failed.
        def validate_spec(klass, spec, options)
          raise Errors::InvalidIndex.new(klass, spec, options) unless spec.is_a?(::Hash)

          spec.each_pair do |name, value|
            next if name == :options

            unless VALID_TYPES.include?(value)
              raise Errors::InvalidIndex.new(klass, spec, options)
            end

            Mongoid::Warnings.warn_geo_haystack_deprecated if value == 'geoHaystack'
          end
        end
      end
    end
  end
end
