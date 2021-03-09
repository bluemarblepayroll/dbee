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

      ATTRIBUTES = %i[name relationships].freeze
      attr_reader(*ATTRIBUTES)

      def initialize(attrs)
        populate_and_validate_subquery_attrs(attrs)

        # TODO: handle these params like is done in the "Model::Derived" subclass.
        super(
          from: attrs[:from],
          fields: attrs[:fields],
          filters: attrs[:filters],
          limit: attrs[:limit],
          sorters: attrs[:sorters],
          given: attrs[:given]
        )

        freeze
      end

      def ==(other)
        super && other.relationships == relationships
      end
      alias eql? ==

      def subquery?
        true
      end

      private

      attr_reader :parent

      def populate_and_validate_subquery_attrs(attrs)
        @name = attrs[:name].to_s

        # This should be generated from the derived model name:
        raise ArgumentError, 'a name is required for subqueries' if name.empty?

        @relationships = Dbee::Model::Relationships.make_keyed_by(
          :name, attrs[:relationships] || {}
        )
      end
    end
  end
end
