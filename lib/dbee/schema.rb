# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Dbee
  # A schema represents an entire graph of related models.
  class Schema
    attr_reader :models

    extend Forwardable
    def initialize(schema_config)
      @models_by_name = Model.make_keyed_by(:name, schema_config)

      freeze
    end

    # Given a Dbee::Model and Dbee::KeyPath, this returns a list of
    # Dbee::Relationship and Dbee::Model tuples that lie on the key path.
    # The returned list is a two dimensional array in
    # the form of <tt>[[relationship, model], [relationship2, model2]]</tt>,
    # etc. The relationships and models correspond to each ancestor part of the
    # key path.
    #
    # The key_path argument can be either a Dbee::KeyPath or an array of
    # string ancestor names.
    #
    # An exception is raised of the provided key_path contains relationship
    # names that do not exist in this schema.
    def expand_query_path(model, key_path, query_path = [])
      ancestors = key_path.respond_to?(:ancestor_names) ? key_path.ancestor_names : key_path
      relationship_name = ancestors.first
      return query_path unless relationship_name

      relationship = relationship_for_name!(model, relationship_name)
      join_model = model_for_name!(relationship.model_name)
      expand_query_path(
        join_model,
        ancestors.drop(1),
        query_path + [[relationship_for_name!(model, relationship_name), join_model]]
      )
    end

    def model_for_name!(model_name)
      models_by_name[model_name.to_s] || raise(Model::ModelNotFoundError, model_name)
    end

    def ==(other)
      other.instance_of?(self.class) && other.send(:models_by_name) == models_by_name
    end
    alias eql? ==

    private

    attr_reader :models_by_name

    def relationship_for_name!(model, rel_name)
      model.relationship_for_name(rel_name) ||
        raise("model '#{model.name}' does not have a '#{rel_name}' relationship")
    end
  end
end
