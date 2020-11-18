# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'model/constraints'
require_relative 'model/partitioner'

module Dbee
  # In DB terms, a Model is usually a table, but it does not have to be.  You can also re-model
  # your DB schema using Dbee::Models.
  class Model
    extend Forwardable
    acts_as_hashable

    class ModelNotFoundError < StandardError; end

    attr_reader :constraints, :filters, :name, :partitioners, :table

    def_delegator :models_by_name,  :values,  :models
    def_delegator :models,          :sort,    :sorted_models
    def_delegator :constraints,     :sort,    :sorted_constraints
    def_delegator :partitioners,    :sort,    :sorted_partitioners

    def initialize(name:, constraints: [], models: [], partitioners: [], table: '')
      raise ArgumentError, 'name is required' if name.to_s.empty?

      @name           = name.to_s
      @constraints    = Constraints.array(constraints).uniq
      @models_by_name = name_hash(Model.array(models))
      @partitioners   = Partitioner.array(partitioners).uniq
      @table          = table.to_s.empty? ? @name : table.to_s

      freeze
    end

    # This recursive method will walk a path of model names (parts) and return back a
    # flattened hash instead of a nested object structure.
    # The hash key will be an array of strings (model names) and the value will be the
    # identified model.
    def ancestors!(parts = [], visited_parts = [], found = {})
      return found if Array(parts).empty?

      # Take the first entry in parts
      model_name = parts.first.to_s

      # Ensure we have it registered as a child, or raise error
      model = assert_model(model_name, visited_parts)

      # Push onto visited list
      visited_parts += [model_name]

      # Add found model to flattened structure
      found[visited_parts] = model

      # Recursively call for next parts in the chain
      model.ancestors!(parts[1..-1], visited_parts, found)
    end

    def ==(other)
      other.instance_of?(self.class) &&
        other.name == name &&
        other.table == table &&
        other.sorted_constraints == sorted_constraints &&
        other.sorted_partitioners == sorted_partitioners &&
        other.sorted_models == sorted_models
    end
    alias eql? ==

    def <=>(other)
      name <=> other.name
    end

    def hash
      [
        name.hash,
        table.hash,
        sorted_constraints.hash,
        sorted_partitioners.hash,
        sorted_models.hash
      ].hash
    end

    def to_s
      name
    end

    private

    attr_reader :models_by_name

    def assert_model(model_name, visited_parts)
      models_by_name[model_name] ||
        raise(ModelNotFoundError, "Missing: #{model_name}, after: #{visited_parts}")
    end

    def name_hash(array)
      array.map { |a| [a.name, a] }.to_h
    end
  end
end
