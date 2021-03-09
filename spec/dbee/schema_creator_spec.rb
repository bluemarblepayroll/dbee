# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require 'fixtures/models'

describe Dbee::SchemaCreator do
  let(:model_hash_graph) do
    {
      'model1' => {
        relationships: {
          model2: {
            constraints: [
              {
                type: 'reference',
                parent: 'id',
                name: 'model1_id'
              }
            ]
          }
        }
      },
      'model2' => nil
    }
  end
  let(:schema) { Dbee::Schema.new(model_hash_graph) }

  let(:model_hash_tree) do
    {
      name: 'model1',
      models: [
        {
          name: 'model2',
          constraints: [
            {
              type: 'reference',
              parent: 'id',
              name: 'model1_id'
            }
          ]
        }
      ]
    }
  end

  let(:model_tree) { Dbee::Model.make(model_hash_tree) }

  let(:query_hash) do
    {
      from: 'model1',
      fields: [
        { key_path: :a }
      ]
    }
  end
  let(:query) { Dbee::Query.make(query_hash) }

  let(:query_hash_no_from) { query_hash.slice(:fields) }
  let(:query_no_from) { Dbee::Query.make(query_hash_no_from) }

  describe 'query parsing' do
    it 'passes through Dbee::Query instances' do
      expect(described_class.new(schema, query).query).to eq query
    end

    it 'creates a Dbee::Query from a query hash' do
      expect(described_class.new(schema, query_hash).query).to eq query
    end

    describe 'the "from" field' do
      it 'raises an error when nil' do
        expect do
          described_class.new(schema, query_hash_no_from)
        end.to raise_error(ArgumentError, 'query requires a from model name')
      end

      it 'raises an error when the empty string' do
        expect do
          described_class.new(schema, query_hash_no_from.merge(from: ''))
        end.to raise_error(ArgumentError, 'query requires a from model name')
      end
    end
  end

  describe 'tree based models' do
    it 'creates a schema from a Dbee::Model' do
      expect(described_class.new(model_tree, query).schema).to eq schema
    end

    describe 'hash detection' do
      it 'creates a schema from a hash model' do
        expect(described_class.new(model_hash_tree, query).schema).to eq schema
      end

      it 'creates a schema from a minimal hash model with no child models' do
        minimal_tree_hash = { name: :practice }
        minimal_schema =  Dbee::Schema.new(practice: nil)

        expect(described_class.new(minimal_tree_hash, {}).schema).to eq minimal_schema
      end
    end

    describe 'query "from" field' do
      it 'is set using name of the root model of the tree' do
        expect(described_class.new(model_tree, query_no_from).query).to eq query
      end

      it 'raises an error the query "from" does not equal the root model name' do
        query_hash_different_from = query_hash_no_from.merge(from: :bogus_model)

        expect do
          described_class.new(model_tree, query_hash_different_from)
        end.to raise_error(
          ArgumentError,
          "expected from model to be 'model1' but got 'bogus_model'"
        )
      end
    end
  end

  describe 'graph based models' do
    it 'creates a schema from a hash schema' do
      expect(described_class.new(model_hash_graph, query).schema).to eq schema
    end

    it 'passes through Dbee::Schema instances' do
      expect(described_class.new(schema, query).schema).to eq schema
    end

    describe 'when given a Dbee::Base class' do
      let(:dsl_model_class) { PartitionerExamples::Dog }

      it 'creates a schema' do
        expected_config = yaml_fixture('models.yaml')['Partitioner Example 1']
        expected_schema = Dbee::Schema.new(expected_config)
        dog_query = Dbee::Query.make(query_hash_no_from.merge(from: :dog))

        expect(described_class.new(dsl_model_class, dog_query).schema).to eq expected_schema
      end

      it "can infer the query's 'from' field" do
        expect(described_class.new(dsl_model_class, query_no_from).query.from).to eq 'dog'
      end

      it 'raises an error the query "from" does not equal the DSL model name' do
        cat_query = Dbee::Query.make(query_hash_no_from.merge(from: :cat))

        expect do
          described_class.new(dsl_model_class, cat_query)
        end.to raise_error(
          ArgumentError,
          "expected from model to be 'dog' but got 'cat'"
        )
      end
    end
  end
end
