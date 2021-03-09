# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Dbee
  # Converts a tree based model to a Schema. Note that this results in a
  # different but compatible schema compared to the result of generating a
  # Dbee::Schema by calling to_schema on a Dbee::Base class. This is
  # because converting from a tree based model is a lossy.
  class SchemaFromTreeBasedModel # :nodoc:
    class << self
      def convert(tree_model)
        Schema.new(to_graph_based_models(tree_model))
      end

      private

      def to_graph_based_models(tree_model, parent_model = nil, models_attrs_by_name = {})
        models_attrs_by_name[tree_model.name] = {
          name: tree_model.name,
          table: tree_model.table,
          partitioners: tree_model.partitioners,
          relationships: {}
        }

        parent_model && add_relationship_to_parent_model(
          tree_model, models_attrs_by_name[parent_model.name]
        )

        tree_model.models.each do |sub_model|
          to_graph_based_models(sub_model, tree_model, models_attrs_by_name)
        end

        models_attrs_by_name
      end

      def add_relationship_to_parent_model(model, graph_model_attrs)
        graph_model_attrs[:relationships][model.name] = { constraints: model.constraints }
      end
    end
  end
end
