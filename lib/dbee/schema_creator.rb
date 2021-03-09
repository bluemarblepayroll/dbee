# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Dbee
  # This creates a Dbee::Schema from a variety of different inputs:
  #
  # 1. The hash representation of a schema.
  # 2. A Dbee::Base subclass (code based models).
  #
  # For backward compatibility, tree based models are also supported in the
  # following formats:
  #
  # 3. The hash representation of a tree based model.
  # 4. Dbee::Model instances in tree based form (using the deprecated constraints and models
  #    attributes).
  class SchemaCreator # :nodoc:
    attr_reader :schema

    # An ArgumentError is raised if the query "from" attribute differs from the name of the root
    # model of a tree based model or if the "from" attribute is blank.
    def initialize(schema_or_model, query)
      @orig_query = Query.make(query) || raise(ArgumentError, 'query is required')
      raise ArgumentError, 'a schema or model is required' unless schema_or_model

      @schema = make_schema(schema_or_model)

      # Note that for backward compatibility reasons, this validation does not
      # exist in the DBee::Query class. This allows continued support for
      # old callers who depend on the "from" field being inferred from the root
      # tree model name.
      raise ArgumentError, 'query requires a from model name' if expected_from_model.empty?

      validate_query_from_model!

      freeze
    end

    # Returns a Dbee::Query instance with a "from" attribute which is
    # sometimes derived for tree based models.
    def query
      return orig_query if expected_from_model == orig_query.from

      Query.make(
        from: expected_from_model,
        fields: orig_query.fields,
        filters: orig_query.filters,
        sorters: orig_query.sorters,
        limit: orig_query.limit
      )
    end

    private

    attr_reader :orig_query, :expected_from_model

    def make_schema(input)
      @expected_from_model = orig_query.from

      return input if input.is_a?(Dbee::Schema)

      if input.respond_to?(:to_schema)
        @expected_from_model = input.inflected_class_name
        return input.to_schema(orig_query.key_chain)
      end

      model_or_schema = to_object(input)
      if model_or_schema.is_a?(Model::Base)
        @expected_from_model = model_or_schema.name.to_s
        SchemaFromTreeBasedModel.convert(model_or_schema)
      else
        model_or_schema
      end
    end

    def to_object(input)
      return input unless input.is_a?(Hash)

      if tree_based_hash?(input)
        Model.make(input)
      else
        Schema.new(input)
      end
    end

    def validate_query_from_model!
      !orig_query.from.empty? && expected_from_model.to_s != orig_query.from.to_s && \
        raise(
          ArgumentError,
          "expected from model to be '#{expected_from_model}' but got '#{orig_query.from}'"
        )
    end

    def tree_based_hash?(hash)
      name = hash[:name] || hash['name']

      # In the unlikely event that schema based hash had a model called "name",
      # its value would either be nil or a hash.
      name.is_a?(String) || name.is_a?(Symbol)
    end
  end
end
