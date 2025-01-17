# frozen_string_literal: true

module Mongoid
  module Association

    # Superclass for all objects that bind associations together.
    module Bindable
      include Threaded::Lifecycle

      attr_reader :_base, :_target, :_association

      # Create the new binding.
      #
      # @example Initialize a binding.
      #   Binding.new(base, target, association)
      #
      # @param [ Mongoid::Document ] base The base of the binding.
      # @param [ Mongoid::Document | Array<Mongoid::Document> ] target The target of the binding.
      # @param [ Mongoid::Association::Relatable ] association The association metadata.
      def initialize(base, target, association)
        @_base = base
        @_target = target
        @_association = association
      end

      # Execute the provided block inside a binding.
      #
      # @example Execute the binding block.
      #   binding.binding do
      #     base.foreign_key = 1
      #   end
      #
      # @return [ Object ] The result of the yield.
      def binding
        return if _binding?

        _binding do
          yield(self) if block_given?
        end
      end

      private

      # Check if the inverse is properly defined.
      #
      # @api private
      #
      # @example Check the inverse definition.
      #   binding.check_inverse!(doc)
      #
      # @param [ Mongoid::Document ] doc The document getting bound.
      #
      # @raise [ Errors::InverseNotFound ] If no inverse found.
      def check_inverse!(doc)
        return if _association.bindable?(doc)

        raise Errors::InverseNotFound.new(
          _base.class,
          _association.name,
          doc.class,
          _association.foreign_key
        )
      end

      # Remove the associated document from the inverse's association.
      #
      # @param [ Mongoid::Document ] doc The document to remove.
      def remove_associated(doc)
        return unless (inverse = _association.inverse(doc))

        if _association.many?
          remove_associated_many(doc, inverse)
        elsif _association.in_to?
          remove_associated_in_to(doc, inverse)
        end
      end

      # Remove the associated document from the inverse's association.
      #
      # This method removes the associated on *_many relationships.
      #
      # @param [ Mongoid::Document ] doc The document to remove.
      # @param [ Symbol ] inverse The name of the inverse.
      def remove_associated_many(doc, inverse)
        # We only want to remove the inverse association when the inverse
        # document is in memory.
        # This first condition is needed because when assigning the
        # embeds_many association using the same embeds_many
        # association, we delete from the array we are about to assign.
        return unless (inv = doc.ivar(inverse)) &&
                      (_base != inv && (associated = inv.ivar(_association.name)))

        associated.delete(doc)
      end

      # Remove the associated document from the inverse's association.
      #
      # This method removes associated on belongs_to and embedded_in
      # associations.
      #
      # @param [ Mongoid::Document ] doc The document to remove.
      # @param [ Symbol ] inverse The name of the inverse.
      def remove_associated_in_to(doc, inverse)
        # We only want to remove the inverse association when the inverse
        # document is in memory.
        return unless (associated = doc.ivar(inverse))

        associated.send(_association.setter, nil)
      end

      # Set the id of the related document in the foreign key field on the
      # keyed document.
      #
      # @api private
      #
      # @example Bind the foreign key.
      #   binding.bind_foreign_key(post, person._id)
      #
      # @param [ Mongoid::Document ] keyed The document that stores the foreign key.
      # @param [ Object ] id The id of the bound document.
      def bind_foreign_key(keyed, id)
        return if keyed.frozen?

        keyed.you_must(_association.foreign_key_setter, id)
      end

      # Set the type of the related document on the foreign type field, used
      # when associations are polymorphic.
      #
      # @api private
      #
      # @example Bind the polymorphic type.
      #   binding.bind_polymorphic_type(post, "Person")
      #
      # @param [ Mongoid::Document ] typed The document that stores the type field.
      # @param [ String ] name The name of the model.
      def bind_polymorphic_type(typed, name)
        return unless _association.type

        typed.you_must(_association.type_setter, name)
      end

      # Set the type of the related document on the foreign type field, used
      # when associations are polymorphic.
      #
      # @api private
      #
      # @example Bind the polymorphic type.
      #   binding.bind_polymorphic_inverse_type(post, "Person")
      #
      # @param [ Mongoid::Document ] typed The document that stores the type field.
      # @param [ String ] name The name of the model.
      def bind_polymorphic_inverse_type(typed, name)
        return unless _association.inverse_type

        typed.you_must(_association.inverse_type_setter, name)
      end

      # Bind the inverse document to the child document so that the in memory
      # instances are the same.
      #
      # @api private
      #
      # @example Bind the inverse.
      #   binding.bind_inverse(post, person)
      #
      # @param [ Mongoid::Document ] doc The base document.
      # @param [ Mongoid::Document ] inverse The inverse document.
      def bind_inverse(doc, inverse)
        return unless doc.respond_to?(_association.inverse_setter)

        doc.you_must(_association.inverse_setter, inverse)
      end

      # Bind the provided document with the base from the parent association.
      #
      # @api private
      #
      # @example Bind the document with the base.
      #   binding.bind_from_relational_parent(doc)
      #
      # @param [ Mongoid::Document ] doc The document to bind.
      def bind_from_relational_parent(doc)
        check_inverse!(doc)
        remove_associated(doc)
        bind_foreign_key(doc, record_id(_base))
        bind_polymorphic_type(doc, _base.class.name)
        bind_inverse(doc, _base)
      end

      def record_id(_base)
        _base.__send__(_association.primary_key)
      end

      # Ensure that the association on the base is correct, for the cases
      # where we have multiple belongs to definitions and were are setting
      # different parents in memory in order.
      #
      # @api private
      #
      # @example Set the base association.
      #   binding.set_base_association
      #
      # @return [ true | false ] If the association changed.
      def set_base_association
        inverse_association = _association.inverse_association(_target)
        return unless inverse_association != _association && !inverse_association.nil?

        _base._association = inverse_association
      end

      # Bind the provided document with the base from the parent association.
      #
      # @api private
      #
      # @example Bind the document with the base.
      #   unbinding.unbind_from_relational_parent(doc)
      #
      # @param [ Mongoid::Document ] doc The document to unbind.
      def unbind_from_relational_parent(doc)
        check_inverse!(doc)
        bind_foreign_key(doc, nil)
        bind_polymorphic_type(doc, nil)
        bind_inverse(doc, nil)
      end
    end
  end
end
