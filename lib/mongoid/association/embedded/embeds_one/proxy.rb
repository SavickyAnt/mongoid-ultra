# frozen_string_literal: true

module Mongoid
  module Association
    module Embedded
      class EmbedsOne

        # Transparent proxy for embeds_one associations.
        # An instance of this class is returned when calling the
        # association getter method on the parent document. This
        # class inherits from Mongoid::Association::Proxy and forwards
        # most of its methods to the target of the association, i.e.
        # the child document.
        class Proxy < Association::One

          # The valid options when defining this association.
          #
          # @return [ Array<Symbol> ] The allowed options when defining this association.
          VALID_OPTIONS = %i[
            autobuild
            as
            cascade_callbacks
            cyclic
            store_as
          ].freeze

          # Instantiate a new embeds_one association.
          #
          # @example Create the new proxy.
          #   One.new(person, name, association)
          #
          # @param [ Mongoid::Document ] base The document this association hangs off of.
          # @param [ Mongoid::Document ] target The child document in the association.
          # @param [ Mongoid::Association::Relatable ] association The association metadata.
          def initialize(base, target, association)
            init(base, target, association) do
              characterize_one(_target)
              bind_one
              characterize_one(_target)
              update_attributes_hash(_target)
              _base._reset_memoized_descendants!
              _target.save if persistable?
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
            if replacement != self
              if _assigning?
                _base.add_atomic_unset(_target) unless replacement
              else
                # The associated object will be replaced by the below update if non-nil, so only
                # run the callbacks and state-changing code by passing persist: false in that case.
                _target.destroy(persist: !replacement) if persistable?

                # A little explanation on why this is needed... Say we have three assignments:
                #
                # canvas.palette = palette
                # canvas.palette = nil
                # canvas.palette = palette
                # Where canvas embeds_one palette.
                #
                # Previously, what was happening was, on the first assignment,
                # palette was considered a "new record" (new_record?=true) and
                # thus palette was being inserted into the database. However,
                # on the third assignment, we're trying to reassign the palette,
                # palette is no longer considered a new record, because it had
                # been inserted previously. This is not exactly accurate,
                # because the second assignment ultimately removed the palette
                # from the database, so it needs to be reinserted. Since the
                # palette's new_record is false, Mongoid ends up "updating" the
                # document, which doesn't reinsert it into the database.
                #
                # The change I introduce here, respecifies palette as a "new
                # record" when it gets removed from the database, so if it is
                # reassigned, it will be reinserted into the database.
                _target.new_record = true
              end
              unbind_one
              unless replacement
                update_attributes_hash(replacement)

                # when `touch: true` is the default (see MONGOID-5016), creating
                # an embedded document will touch the parent, and will cause the
                # _descendants list to be initialized and memoized. If the object
                # is then deleted, we need to make sure and un-memoize that list,
                # otherwise when the update happens, the memoized _descendants list
                # gets used and the "deleted" subdocument gets added again.
                _reset_memoized_descendants!

                return nil
              end
              replacement = Factory.build(klass, replacement) if replacement.is_a?(::Hash)
              self._target = replacement
              characterize_one(_target)
              bind_one
              update_attributes_hash(_target)
              _target.save if persistable?
            end
            self
          end

          private

          # Instantiate the binding associated with this association.
          #
          # @example Get the binding.
          #   relation.binding([ address ])
          #
          # @return [ Binding ] The association's binding.
          def binding
            Binding.new(_base, _target, _association)
          end

          # Are we able to persist this association?
          #
          # @example Can we persist the association?
          #   relation.persistable?
          #
          # @return [ true | false ] If the association is persistable.
          def persistable?
            _base.persisted? && !_binding? && !_building? && !_assigning?
          end

          # Update the _base's attributes hash with the _target's attributes
          #
          # @param replacement [ Mongoid::Document | nil ] The doc to use to update the
          #   attributes hash.
          #
          # @api private
          def update_attributes_hash(replacement)
            if replacement
              _base.attributes.merge!(_association.store_as => replacement.attributes)
            else
              _base.attributes.delete(_association.store_as)
            end
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
            #   Association::Embedded::EmbedsOne.embedded?
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
            # @return [ Mongoid::Atomic::Paths::Embedded::One ]
            #   The embedded one atomic path calculator.
            def path(document)
              Mongoid::Atomic::Paths::Embedded::One.new(document)
            end
          end
        end
      end
    end
  end
end
