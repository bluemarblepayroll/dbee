# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Dbee
  class Query
    # This class is an abstraction of a simplified SQL expression.  In DB terms:
    # TODO: add to this
    # - fields are the SELECT
    # - sorters are the ORDER BY
    # - limit is the TAKE
    # - filters are the WHERE
    class Base # :nodoc: all
      extend Forwardable
      acts_as_hashable

      attr_reader :constraints,
                  :fields,
                  :filters,
                  :given,
                  :limit,
                  :sorters

      def_delegator :fields,   :sort, :sorted_fields
      def_delegator :filters,  :sort, :sorted_filters
      def_delegator :sorters,  :sort, :sorted_sorters

      def initialize(
        fields: [],
        filters: [],
        limit: nil,
        sorters: [],
        given: []
      )

        @fields  = Field.array(fields)
        @filters = Filters.array(filters).uniq
        @limit   = limit.to_s.empty? ? nil : limit.to_i
        @sorters = Sorters.array(sorters).uniq

        populate_given(given)

        freeze
      end

      def ==(other)
        other.instance_of?(self.class) &&
          other.limit == limit &&
          other.sorted_fields == sorted_fields &&
          other.sorted_filters == sorted_filters &&
          other.sorted_sorters == sorted_sorters
      end
      alias eql? ==

      def key_chain
        KeyChain.new(key_paths)
      end

      # TODO: track down callers...is this needed?
      def subquery?
        false
      end

      def key_paths
        (
          fields.flat_map(&:key_paths) +
          filters.map(&:key_path) +
          sorters.map(&:key_path)
        )
      end

      def populate_given(given)
        @given = Array(given).map { |query_spec| Dbee::Query.make(query_spec.merge(parent: self)) }
      end
    end
  end
end
