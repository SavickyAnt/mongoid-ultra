# frozen_string_literal: true

module Mongoid
  module Config

    # Encapsulates logic for getting environment information.
    module Environment
      extend self

      # Get the name of the environment that Mongoid is running under.
      #
      # Uses the following sources in order:
      # - If +::Rails+ is defined, +Rails.env+.
      # - If +::Sinatra+ is defined, +Sinatra::Base.environment+.
      # - +RACK_ENV+
      # - +MONGOID_ENV*
      #
      # @example Get the env name.
      #   Environment.env_name
      #
      # @raise [ Errors::NoEnvironment ] If environment name cannot be
      #   determined because none of the sources was set.
      #
      # @return [ String ] The name of the current environment.
      # @api public
      def env_name
        return ::Rails.env if defined?(::Rails)
        return ::Sinatra::Base.environment.to_s if defined?(::Sinatra)

        ENV['RACK_ENV'] || ENV['MONGOID_ENV'] || (raise Errors::NoEnvironment)
      end

      # Load the yaml from the provided path and return the settings for the
      # specified environment, or for the current Mongoid environment.
      #
      # @example Load the yaml.
      #   Environment.load_yaml("/work/mongoid.yml")
      #
      # @param [ String ] path The location of the file.
      # @param [ String | Symbol ] environment Optional environment name to
      #   override the current Mongoid environment.
      #
      # @return [ Hash ] The settings.
      #
      # @api private
      def load_yaml(path, environment = nil)
        env = environment ? environment.to_s : env_name

        contents = File.read(path)
        raise Mongoid::Errors::EmptyConfigFile.new(path) if contents.empty?

        # These are the classes that can be used in a Mongoid
        # configuration file in addition to standard YAML types.
        permitted_classes = [
          # Symbols occur as values for read preference, for example.
          Symbol,
          # BSON::Binary occur as keyId values for FLE (more precisely,
          # the keyIds are UUIDs).
          BSON::Binary
        ]

        result = ERB.new(contents).result
        data = if RUBY_VERSION < '2.6'
                 YAML.safe_load(result, permitted_classes, [], true)
               else
                 YAML.safe_load(result, permitted_classes: permitted_classes, aliases: true)
               end

        raise Mongoid::Errors::InvalidConfigFile.new(path) unless data.is_a?(Hash)

        data[env]
      end
    end
  end
end
