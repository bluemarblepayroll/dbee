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

    class NoFieldsError < StandardError; end

    attr_reader :fields,
                :filters,
                :groupers,
                :limit,
                :sorters

    def_delegator :fields,   :sort, :sorted_fields
    def_delegator :filters,  :sort, :sorted_filters
    def_delegator :sorters,  :sort, :sorted_sorters
    def_delegator :groupers, :sort, :sorted_groupers

    def initialize(
      fields:,
      filters: [],
      groupers: [],
      limit: nil,
      sorters: []
    )
      @fields = Field.array(fields)

      # If no fields were passed into a query then we will have no data to return.
      # Let's raise a hard error here and let the consumer deal with it since this may
      # have implications in downstream SQL generators.
      raise NoFieldsError if @fields.empty?

      @filters  = Filters.array(filters).uniq
      @groupers = Array(groupers).map { |k| KeyPath.get(k) }.uniq
      @limit    = limit.to_s.empty? ? nil : limit.to_i
      @sorters  = Sorters.array(sorters).uniq

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

    private

    def key_paths
      (
        fields.flat_map(&:key_paths) +
        filters.map(&:key_path) +
        sorters.map(&:key_path)
      )
    end
  end
end
