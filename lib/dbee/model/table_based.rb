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
      extend Forwardable

      attr_reader :table

      def_delegator :constraints,     :sort,    :sorted_constraints
      def_delegator :models_by_name,  :values,  :models
      def_delegator :models,          :sort,    :sorted_models

      def initialize(params)
        @table = params[:table].to_s.empty? ? params[:name] : params[:table].to_s

        initialize_legacy_tree_based_model_attributes(params)

        super params.reject { |key, _| ADDITIONAL_ATTRIBUTES.include?(key) }
      end

      def ==(other)
        super &&
          other.table == table &&
          other.sorted_constraints == sorted_constraints &&
          other.sorted_models == sorted_models
      end
      alias eql? ==

      def hash
        [super, table.hash, sorted_constraints.hash, sorted_models.hash].hash
      end

      # TODO: remove this method
      #
      # This recursive method will walk a path of model names (parts) and return back a
      # flattened hash instead of a nested object structure.
      # The hash key will be an array of strings (model names) and the value will be the
      # identified model.
      #
      # Note that this method ends in a bang because it can raise a
      # `ModelNotFoundError` exception if the model is not found. This method
      # does not mutate any data.
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

      private

      ADDITIONAL_ATTRIBUTES = %i[constraints models table].freeze
      private_constant :ADDITIONAL_ATTRIBUTES

      attr_reader :models_by_name

      def assert_model(model_name, visited_parts)
        models_by_name[model_name] ||
          raise(ModelNotFoundError, "Missing: #{model_name}, after: #{visited_parts}")
      end

      def name_hash(array)
        array.map { |a| [a.name, a] }.to_h
      end

      def initialize_legacy_tree_based_model_attributes(params)
        @constraints    = Constraints.array(params[:constraints] || []).uniq
        @models_by_name = name_hash(Model.array(params[:models]))

        constraints&.any? && relationships&.any? && \
          raise(ArgumentError, 'constraints and relationships are mutually exclusive')
      end
    end
  end
end
