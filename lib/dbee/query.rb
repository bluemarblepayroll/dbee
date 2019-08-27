# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'query/field'
require_relative 'query/filters'
require_relative 'query/sorter'

module Dbee
  # This class is an abstration of a simplified SQL expression.  In DB terms:
  # - fields are the SELECT
  # - sorters are the ORDER BY
  # - limit is the TAKE
  # - filters are the WHERE
  class Query
    acts_as_hashable

    class NoFieldsError < StandardError; end

    attr_reader :fields, :filters, :limit, :sorters

    def initialize(fields:, filters: [], limit: nil, sorters: [])
      @fields = Field.array(fields)

      # If no fields were passed into a query then we will have no data to return.
      # Let's raise a hard error here and let the consumer deal with it since this may
      # have implications in downstream SQL generators.
      raise NoFieldsError if @fields.empty?

      @filters  = Filters.array(filters)
      @limit    = limit.to_s.empty? ? nil : limit.to_i
      @sorters  = Sorter.array(sorters)

      freeze
    end

    def ==(other)
      other.fields.sort == fields.sort &&
        other.filters.sort == filters.sort &&
        other.limit == limit &&
        other.sorters.sort == sorters.sort
    end
    alias eql? ==

    def key_chain
      KeyChain.new(key_paths)
    end

    private

    def key_paths
      (fields.map(&:key_path) + filters.map(&:key_path) + sorters.map(&:key_path))
    end
  end
end
