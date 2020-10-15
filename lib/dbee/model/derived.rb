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

      def initialize(name:, constraints: [], models: [], partitioners: [], query:)
        raise ArgumentError, 'a query is required' unless query

        @query = Dbee::Query.make(query)

        super(name: name, constraints: constraints, models: models, partitioners: partitioners)
      end

      def ==(other)
        super && other.query == query
      end
    end
  end
end
