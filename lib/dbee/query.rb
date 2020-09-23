# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'query/field'
require_relative 'query/filters'
require_relative 'query/sorters'

module Dbee
  # This class is an abstration of a simplified SQL expression.  In DB terms:
  # - fields are the SELECT
  # - sorters are the ORDER BY
  # - limit is the TAKE
  # - filters are the WHERE
  class Query
    extend Forwardable
    acts_as_hashable

    attr_reader :fields,
                :filters,
                :given,
                :limit,
                :name,
                :sorters

    def_delegator :fields,   :sort, :sorted_fields
    def_delegator :filters,  :sort, :sorted_filters
    def_delegator :sorters,  :sort, :sorted_sorters

    # rubocop:disable Metrics/ParameterLists
    # TODO: address this before PR
    def initialize(
      fields: [],
      filters: [],
      given: [],
      limit: nil,
      name: nil,
      parent: nil,
      sorters: []
    )
      # rubocop:enable Metrics/ParameterLists
      @fields  = Field.array(fields)
      @filters = Filters.array(filters).uniq
      populate_given(given)
      @name    = name
      @limit   = limit.to_s.empty? ? nil : limit.to_i
      @parent  = parent
      @sorters = Sorters.array(sorters).uniq

      raise ArgumentError, 'a name is required for subqueries' if subquery? && name.nil?

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

    def subquery?
      !parent.nil?
    end

    private

    attr_reader :parent

    def key_paths
      (
        fields.flat_map(&:key_paths) +
        filters.map(&:key_path) +
        sorters.map(&:key_path)
      )
    end

    def populate_given(given)
      @given = Array(given).map { |query_spec| self.class.new(query_spec.merge(parent: self)) }
    end
  end
end
