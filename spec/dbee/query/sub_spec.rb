# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Dbee::Query::Sub do
  describe 'given three levels of queries' do
    let(:subquery_relationships) do
      {
        foo: {
          name: 'foo',
          constraints: [
            { name: :outer_id, parent: :id, type: :reference }
          ]
        }
      }
    end
    let(:relationships_from) do
      {
        bar: {
          name: 'bar',
          constraints: [
            { name: :bar_id, parent: :id, type: :reference }
          ]
        }
      }
    end
    let(:outer_query) do
      {
        given: [inner_query1, inner_query2],
        fields: [{ key_path: :outer_field }]
      }
    end
    let(:inner_query1) do
      {
        name: :inner_query1,
        from: :foo,
        fields: [{ key_path: :inner1_field }]
      }
    end
    let(:inner_query2) do
      {
        name: :inner_query2,
        given: [third_level_query],
        from: :foo,
        relationships: subquery_relationships,
        relationships_from: relationships_from,
        fields: [{ key_path: :inner2_field }]
      }
    end
    let(:third_level_query) do
      {
        name: :third_level_query,
        from: :foo,
        fields: [{ key_path: :third_level_field }]
      }
    end
    let(:subject) { Dbee::Query.make(outer_query) }
    let(:second_level_queries) { subject.given }

    it 'exposes subqueries through the "given" method' do
      expect(second_level_queries.size).to eq 2
      expect(second_level_queries[0].name).to eq 'inner_query1'
      expect(second_level_queries[1].name).to eq 'inner_query2'

      third_level_queries = second_level_queries[1].given
      expect(third_level_queries[0].name).to eq 'third_level_query'
      # The tree ends here:
      expect(third_level_queries[0].given).to eq []
    end

    it 'populates all of the subquery fields' do
      subquery = second_level_queries[1]
      expect(subquery.name).to eq 'inner_query2'
      expect(subquery.from).to eq 'foo'
      expect(subquery.relationships).to eq(
        'foo' => Dbee::Model::Relationships.make(subquery_relationships[:foo])
      )
      expect(subquery.relationships_from).to eq(
        'bar' => Dbee::Model::Relationships.make(relationships_from[:bar])
      )
    end
  end

  describe 'validation' do
    let(:valid_subquery) { { name: :third_level_query, from: :foo } }
    let(:subquery) { valid_subquery }
    let(:outer_query) { { given: [subquery] } }
    let(:subject) { Dbee::Query.make(outer_query) }

    it 'constructs a valid subquery' do
      expect(subject).to be_a Dbee::Query::Base
      expect(subject.given.first).to be_a Dbee::Query::Sub
    end

    describe 'given a subquery without a name' do
      let(:subquery) { valid_subquery.merge(name: nil) }

      it 'raises an error' do
        expect { subject }.to raise_error(
          ActsAsHashable::Hashable::HydrationError,
          /name is required for subqueries/
        )
      end
    end
  end
end
