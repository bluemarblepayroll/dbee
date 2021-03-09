# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'query/base'
require_relative 'query/field'
require_relative 'query/filters'
require_relative 'query/sorters'
require_relative 'query/sub'

module Dbee
  # Top-level factory that allows for the making of queries.
  class Query
    acts_as_hashable_factory
    using ActsAsHashable::HashRefinements

    attr_reader :fields,
                :filters,
                :from,
                :limit,
                :sorters

    DEFAULT_TYPE = 'base'
    SUBQUERY_TYPE = 'sub'
    private_constant :DEFAULT_TYPE, :SUBQUERY_TYPE

    register DEFAULT_TYPE, '', Dbee::Query::Base
    register SUBQUERY_TYPE,    Dbee::Query::Sub

    # TODO: should I just keep this class as is an have Dbee::Query::Base inherit from it?
    class << self
      # "make" is overridden from acts_as_hashable_factory so that it can
      # derive the type based on the provided keys.
      def make(spec = {})
        return spec if spec.is_a?(Dbee::Query::Base) || spec.nil?

        super spec.merge(type: determine_type(spec))
      end

      private

      def determine_type(spec)
        spec = spec.symbolize_keys
        return spec[:type] if spec[:type]

        Sub::ATTRIBUTES.any? { |attrib| spec.key?(attrib) } ? SUBQUERY_TYPE : DEFAULT_TYPE
      end
    end
  end
end
