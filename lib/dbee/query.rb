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
  # This class is an abstraction of a simplified SQL expression.  In DB terms:
  # TODO: add to this
  # - fields are the SELECT
  # - sorters are the ORDER BY
  # - limit is the TAKE
  # - filters are the WHERE
  class Query
    extend Forwardable
    acts_as_hashable

    attr_reader :constraints,
                :fields,
                :filters,
                :given,
                :limit,
                :model,
                :name,
                :parent_model,
                :sorters

    def_delegator :fields,   :sort, :sorted_fields
    def_delegator :filters,  :sort, :sorted_filters
    def_delegator :sorters,  :sort, :sorted_sorters

    # rubocop:disable Metrics/AbcSize
    # TODO:  extract a sub-class for subqueries.
    def initialize(attrs)
      attrs = CONSTRUCTOR_DEFAULTS.merge(attrs)

      @fields  = Field.array(attrs[:fields])
      @filters = Filters.array(attrs[:filters]).uniq
      populate_given(attrs[:given])
      @limit   = attrs[:limit].to_s.empty? ? nil : attrs[:limit].to_i
      @parent  = attrs[:parent]
      @sorters = Sorters.array(attrs[:sorters]).uniq

      populate_and_validate_subquery_attrs(attrs) if subquery?

      freeze
    end
    # rubocop:enable Metrics/AbcSize

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

    CONSTRUCTOR_DEFAULTS = {
      fields: [],
      filters: [],
      given: [],
      limit: nil,
      name: nil,
      parent: nil,
      sorters: []
    }.freeze
    private_constant :CONSTRUCTOR_DEFAULTS

    attr_reader :parent

    def key_paths
      (
        fields.flat_map(&:key_paths) +
        filters.map(&:key_path) +
        sorters.map(&:key_path)
      )
    end

    def populate_given(given)
      @given = Array(given).map { |query_spec| self.class.make(query_spec.merge(parent: self)) }
    end

    def populate_and_validate_subquery_attrs(attrs)
      @name = attrs[:name]
      @model = attrs[:model]
      @parent_model = attrs[:parent_model]
      raise ArgumentError, 'a name is required for subqueries' if name.nil?
      raise ArgumentError, 'a model is required for subqueries' if model.nil? # required for derived
      raise ArgumentError, 'a parent_model is required for subqueries' if parent_model.nil?

      @constraints = Model::Constraints.array(attrs[:constraints])
    end
  end
end
