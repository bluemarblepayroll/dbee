# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Dbee
  class Model
    # A model which is derived using a subquery.
    class Derived < Dbee::Model::Base
      attr_reader :query

      # TODO: deal with this
      # rubocop:disable Metrics/ParameterLists
      def initialize(name:, constraints: [], models: [], parent: nil, partitioners: [], query:)
        # rubocop:enable Metrics/ParameterLists
        raise ArgumentError, 'a query is required' unless query

        super(
          name: name,
          constraints: constraints,
          models: models,
          parent: parent,
          partitioners: partitioners
        )

        @query = Dbee::Query::Sub.make(query.merge(subquery_attributes))

        freeze
      end

      def ==(other)
        super && other.query == query
      end

      private

      def subquery_attributes
        {
          name: name,
          parent_model: parent&.name,
          constraints: constraints
        }
      end
    end
  end
end
