# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Dbee
  module Dsl
    # This mixin contains all the reader/writers for model meta-data declared through the DSL.
    module Methods
      def partitioner(name, value)
        partitioners << { name: name, value: value }
      end

      def table(name)
        tap { @table_name = name.to_s }
      end

      def query(spec)
        tap { @query_spec = spec }
      end

      def query_spec
        @query_spec.respond_to?(:call) ? @query_spec.call : @query_spec
      end

      def parent(name, opts = {})
        association = association_builder.parent_association(self.name, name, opts)

        association(name, association)
      end

      def child(name, opts = {})
        association = association_builder.child_association(self.name, name, opts)

        association(name, association)
      end

      def association(name, opts = {})
        value =
          if opts.is_a?(Dsl::Association)
            opts
          else
            Dsl::Association.new(self.name, inflector, name, opts)
          end

        tap { associations_by_name[name.to_s] = value }
      end

      def table_name
        @table_name || ''
      end

      def associations_by_name
        @associations_by_name ||= {}
      end

      def partitioners
        @partitioners ||= []
      end

      def table_name?
        !table_name.empty?
      end

      private

      def inflector
        Dbee.inflector
      end

      def association_builder
        @association_builder ||= Dsl::AssociationBuilder.new(inflector)
      end
    end
  end
end
