# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Dbee
  class Model
    # A model which is based on a database table.
    class TableBased < Dbee::Model::Base
      attr_reader :table

      # TODO: deal with this
      # rubocop:disable Metrics/ParameterLists
      def initialize(name:, constraints: [], models: [], partitioners: [], table: '', parent: nil)
        # rubocop:enable Metrics/ParameterLists
        @table = table.to_s.empty? ? name : table.to_s

        super(
          name: name,
          constraints: constraints,
          models: models,
          parent: parent,
          partitioners: partitioners
        )

        freeze
      end

      def ==(other)
        super && other.table == table
      end
    end
  end
end
