# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Dbee
  # Builds a Dbee::Schema given a Dbee::Base (DSL) model. Note that this class
  # does not exist in the "Dsl" module as it is not used for defining the DSL
  # itself.
  class DslSchemaBuilder # :nodoc:
    attr_reader :dsl_model, :key_chain

    def initialize(dsl_model, key_chain)
      @dsl_model = dsl_model || ArgumentError('dsl_model is required')
      @key_chain = key_chain || ArgumentError('key_chain is required')

      freeze
    end

    def to_schema
      schema_spec = { dsl_model.inflected_class_name => model_config(dsl_model) }

      ancestor_paths(key_chain).each do |key_path|
        start_model = dsl_model

        key_path.ancestor_names.each do |association_name|
          start_model = append_model_and_relationship(schema_spec, start_model, association_name)
        end
      end

      Schema.new(schema_spec)
    end

    private

    def model_config(dsl_model) #:nodoc:
      additional_config = if dsl_model.query_spec
                            { query: dsl_model.query_spec, type: :derived }
                          else
                            { table: dsl_model.inherited_table_name }
                          end

      {
        name: dsl_model.inflected_class_name,
        partitioners: dsl_model.inherited_partitioners,
        relationships: {}
      }.merge(additional_config)
    end

    def append_model_and_relationship(schema_spec, base_model, association_name)
      association = find_association!(base_model, association_name)
      target_model = association.model_constant

      schema_spec[target_model.inflected_class_name] ||= model_config(target_model)

      schema_spec[base_model.inflected_class_name][:relationships][association.name] = {
        constraints: association.constraints,
        model: relationship_model_name(association, target_model)
      }

      target_model
    end

    # Returns a unique list of ancestor paths from a key_chain. Omits any
    # fields on the base model.
    def ancestor_paths(key_chain)
      key_chain.to_unique_ancestors.key_path_set.select do |key_path|
        key_path.ancestor_names.any?
      end
    end

    def find_association!(base_model, association_name)
      base_model.inherited_associations.find { |assoc| assoc.name == association_name } \
        ||
        raise(
          ArgumentError,
          "no association #{association_name} exists on model #{base_model.name}"
        )
    end

    def relationship_model_name(association, target_model)
      return nil if association.name == target_model.inflected_class_name

      target_model.inflected_class_name
    end
  end
end
