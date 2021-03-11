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

      ATTRIBUTES = %i[name relationships relationships_from].freeze
      attr_reader(*ATTRIBUTES)

      def initialize(attrs)
        populate_and_validate_subquery_attrs(attrs)

        super attrs.reject { |key, _| ATTRIBUTES.include?(key) }

        freeze
      end

      def ==(other)
        super &&
          other.relationships == relationships &&
          other.relationships_from == relationships_from
      end
      alias eql? ==

      def subquery?
        true
      end

      private

      def populate_and_validate_subquery_attrs(attrs)
        @name = attrs[:name].to_s

        # This should be generated from the derived model name:
        raise ArgumentError, 'a name is required for subqueries' if name.empty?

        @relationships      = make_relationships(attrs[:relationships])
        @relationships_from = make_relationships(attrs[:relationships_from])
      end

      def make_relationships(relationship_hash)
        Dbee::Model::Relationships.make_keyed_by(:name, relationship_hash || {})
      end
    end
  end
end
