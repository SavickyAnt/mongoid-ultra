# frozen_string_literal: true

module Mongoid
  module Association
    module Embedded
      class EmbeddedIn

        # Transparent proxy for embedded_in associations.
        # An instance of this class is returned when calling the
        # association getter method on the child document. This
        # class inherits from Mongoid::Association::Proxy and forwards
        # most of its methods to the target of the association, i.e.
        # the parent document.
        class Proxy < Association::One

          # Instantiate a new embedded_in association.
          #
          # @example Create the new association.
          #   Association::Embedded::EmbeddedIn.new(person, address, association)
          #
          # @param [ Mongoid::Document ] base The document the association hangs off of.
          # @param [ Mongoid::Document ] target The target (parent) of the association.
          # @param [ Mongoid::Association::Relatable ] association The association metadata.
          #
          # @return [ In ] The proxy.
          def initialize(base, target, association)
            init(base, target, association) do
              characterize_one(_target)
              bind_one
            end
          end

          # Substitutes the supplied target documents for the existing document
          # in the association.
          #
          # @example Substitute the new document.
          #   person.name.substitute(new_name)
          #
          # @param [ Mongoid::Document | Hash ] replacement A document to replace the target.
          #
          # @return [ Mongoid::Document | nil ] The association or nil.
          def substitute(replacement)
            unbind_one
            unless replacement
              _base.delete if persistable?
              return nil
            end
            _base.new_record = true
            replacement = Factory.build(klass, replacement) if replacement.is_a?(::Hash)
            self._target = replacement
            bind_one
            self
          end

          private

          # Instantiate the binding associated with this association.
          #
          # @example Get the binding.
          #   binding([ address ])
          #
          # @return [ Binding ] A binding object.
          def binding
            Binding.new(_base, _target, _association)
          end

          # Characterize the document.
          #
          # @example Set the base association.
          #   object.characterize_one(document)
          #
          # @param [ Mongoid::Document ] document The document to set the association metadata on.
          def characterize_one(document)
            return if _base._association

            _base._association = _association.inverse_association(document)
          end

          # Are we able to persist this association?
          #
          # @example Can we persist the association?
          #   relation.persistable?
          #
          # @return [ true | false ] If the association is persistable.
          def persistable?
            _target.persisted? && !_binding? && !_building?
          end

          class << self
            # Returns the eager loader for this association.
            #
            # @param [ Array<Mongoid::Association> ] associations The
            #   associations to be eager loaded
            # @param [ Array<Mongoid::Document> ] docs The parent documents
            #   that possess the given associations, which ought to be
            #   populated by the eager-loaded documents.
            #
            # @return [ Mongoid::Association::Embedded::Eager ]
            def eager_loader(associations, docs)
              Eager.new(associations, docs)
            end

            # Returns true if the association is an embedded one. In this case
            # always true.
            #
            # @example Is this association embedded?
            #   Association::Embedded::EmbeddedIn.embedded?
            #
            # @return [ true ] true.
            def embedded?
              true
            end

            # Get the path calculator for the supplied document.
            #
            # @example Get the path calculator.
            #   Proxy.path(document)
            #
            # @param [ Mongoid::Document ] document The document to calculate on.
            #
            # @return [ Root ] The root atomic path calculator.
            def path(document)
              Mongoid::Atomic::Paths::Root.new(document)
            end
          end
        end
      end
    end
  end
end
