# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Dbee
  class Query
    # This represents a subquery which is also known as a nested query. Note
    # that this is NOT a Common Table Expression.
    class Sub < Dbee::Query::Base
      extend Forwardable
      acts_as_hashable

      ATTRIBUTES = %i[model name parent_model].freeze
      attr_reader(*ATTRIBUTES)

      def initialize(attrs)
        populate_and_validate_subquery_attrs(attrs)

        super(
          fields: attrs[:fields],
          filters: attrs[:filters],
          limit: attrs[:limit],
          sorters: attrs[:sorters],
          given: attrs[:given]
        )

        freeze
      end

      def ==(other)
        super &&
          other.model == model &&
          other.name == name &&
          other.parent_model == parent_model
      end
      alias eql? ==

      def subquery?
        true
      end

      private

      attr_reader :parent

      def populate_and_validate_subquery_attrs(attrs)
        @name = attrs[:name]
        @model = attrs[:model]
        @parent_model = attrs[:parent_model]

        # This should be generated from the derived model name:
        raise ArgumentError, 'a name is required for subqueries' if name.nil?
        # Required for derived models:
        raise ArgumentError, 'a model is required for subqueries' if model.nil?
        # This can be generated from the derived model:
        raise ArgumentError, 'a parent_model is required for subqueries' if parent_model.nil?

        # This could be passed in from the derived model:
        @constraints = Model::Constraints.array(attrs[:constraints])
      end
    end
  end
end
