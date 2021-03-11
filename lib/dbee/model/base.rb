# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#
module Dbee
  class Model
    # A common base class for different types of data models.
    class Base
      extend Forwardable
      acts_as_hashable

      attr_reader :constraints, :name, :partitioners, :relationships

      def_delegator :partitioners, :sort, :sorted_partitioners

      def initialize(name:, relationships: [], partitioners: [])
        raise ArgumentError, 'name is required' if name.to_s.empty?

        @name           = name.to_s
        @relationships  = Relationships.make_keyed_by(:name, relationships)
        @partitioners   = Partitioner.array(partitioners).uniq

        freeze
      end

      def relationship_for_name(relationship_name)
        relationships[relationship_name]
      end

      def ==(other)
        other.instance_of?(self.class) &&
          other.name == name &&
          other.relationships == relationships &&
          other.sorted_partitioners == sorted_partitioners
      end
      alias eql? ==

      def <=>(other)
        name <=> other.name
      end

      def hash
        [name.hash, relationships.hash, sorted_partitioners.hash].hash
      end

      def to_s
        name
      end
    end
  end
end
