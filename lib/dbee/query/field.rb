# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Dbee
  class Query
    # This class is an abstraction of the SELECT part of a SQL statement.
    # The key_path is the relative path to the column while the display is the AS part of the
    # SQL SELECT statement.
    class Field
      acts_as_hashable

      module Aggregator
        AVE   = :ave
        COUNT = :count
        MAX   = :max
        MIN   = :min
        SUM   = :sum
      end
      include Aggregator

      attr_reader :aggregator, :display, :filters, :key_path

      def initialize(key_path:, aggregator: nil, display: nil, filters: [])
        raise ArgumentError, 'key_path is required' if key_path.to_s.empty?

        @aggregator = aggregator ? Aggregator.const_get(aggregator.to_s.upcase.to_sym) : nil
        @display    = (display.to_s.empty? ? key_path : display).to_s
        @filters    = Filters.array(filters).uniq
        @key_path   = KeyPath.get(key_path)

        freeze
      end

      def filters?
        filters.any?
      end

      def aggregator?
        !aggregator.nil?
      end

      def hash
        [
          aggregator,
          display,
          filters,
          key_path
        ].hash
      end

      def ==(other)
        other.instance_of?(self.class) &&
          other.aggregator == aggregator &&
          other.key_path == key_path &&
          other.filters == filters &&
          other.display == display
      end
      alias eql? ==

      def <=>(other)
        "#{key_path}#{display}" <=> "#{other.key_path}#{other.display}"
      end

      def key_paths
        [key_path] + filters.map(&:key_path)
      end
    end
  end
end
