# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Dbee::Query do
  let(:config) do
    {
      fields: [
        { key_path: 'matt.nick.sam', display: 'some display' },
        { key_path: 'katie' },
        { key_path: 'jordan.pippen' }
      ],
      sorters: [
        { key_path: :sort_me },
        { key_path: :sort_me_too, direction: :descending }
      ],
      filters: [
        { key_path: 'filter_me.a_little', value: 'something' },
        { key_path: 'matt.nick.sam', value: 'something' }
      ],
      limit: 125
    }
  end

  subject { described_class.make(config) }

  specify '#eql? compares attributes' do
    expect(subject).to eq(described_class.make(config))
  end

  describe '#initialize' do
    it 'should remove duplicate filters (keep first instance)' do
      query_hash = {
        fields: [
          { key_path: 'a' }
        ],
        filters: [
          { key_path: 'a', value: 'something' },
          { key_path: 'b', value: 123 },
          { key_path: 'b', value: '123' },
          { key_path: 'c', value: nil },
          { key_path: 'c', value: '' },
          { key_path: 'd', value: 'r', type: :greater_than_or_equal_to },
          { key_path: 'd', value: 'r' },
          { key_path: 'e', value: [1, 2, 3] },
          { key_path: 'a', value: 'something' },
          { key_path: 'e', value: [1, 2, 3] }
        ]
      }

      expected_filters = Dbee::Query::Filters.array(
        [
          { key_path: 'a', value: 'something' },
          { key_path: 'b', value: 123 },
          { key_path: 'b', value: '123' },
          { key_path: 'c', value: nil },
          { key_path: 'c', value: '' },
          {
            key_path: 'd',
            value: 'r',
            type: :greater_than_or_equal_to
          },
          { key_path: 'd', value: 'r' },
          { key_path: 'e', value: [1, 2, 3] }
        ]
      )

      expect(described_class.make(query_hash).filters).to eq(expected_filters)
    end

    it 'should remove duplicate sorters (keep first instance)' do
      query_hash = {
        fields: [
          { key_path: 'a' }
        ],
        sorters: [
          { key_path: 'a' },
          { key_path: 'b' },
          { key_path: 'c', direction: :descending },
          { key_path: '1' },
          { key_path: :a },
          { key_path: 1 },
          { key_path: 'c', direction: :descending }
        ]
      }

      expected_sorters = Dbee::Query::Sorters.array([
                                                      { key_path: 'a' },
                                                      { key_path: 'b' },
                                                      { key_path: 'c', direction: :descending },
                                                      { key_path: '1' }
                                                    ])

      expect(described_class.make(query_hash).sorters).to eq(expected_sorters)
    end
  end

  describe 'sub types' do
    it 'creates a Dbee::Query::Base by default' do
      expect(described_class.make).to be_a Dbee::Query::Base
    end

    describe 'when subquery attributes are present' do
      it 'creates a Dbee::Query::Sub' do
        subject = described_class.make(name: 'test', model: 'foo', parent_model: 'parent')
        expect(subject).to be_a Dbee::Query::Sub
      end
    end

    describe 'when subquery attributes are present as string keys' do
      it 'creates a Dbee::Query::Sub' do
        subject = described_class.make(
          'name' => 'test',
          'model' => 'foo',
          'parent_model' => 'parent'
        )
        expect(subject).to be_a Dbee::Query::Sub
      end
    end

    it 'returns nil when given nil' do
      expect(described_class.make(nil)).to be_nil
    end
  end

  describe '#key_chain' do
    it 'should include filter, sorter, and field key_paths' do
      key_paths =
        config[:fields].map { |f| f[:key_path].to_s } +
        config[:filters].map { |f| f[:key_path].to_s } +
        config[:sorters].map { |s| s[:key_path].to_s }

      expected_key_chain = Dbee::KeyChain.new(key_paths)

      expect(subject.key_chain).to eq(expected_key_chain)
    end
  end

  describe 'nesting/subqueries' do
    describe 'given three levels of queries' do
      let(:subquery_constraint) { { name: :outer_id, parent: :id, type: :reference } }
      let(:outer_query) do
        {
          given: [inner_query1, inner_query2],
          fields: [{ key_path: :outer_field }]
        }
      end
      let(:inner_query1) do
        {
          name: :inner_query1,
          model: :foo,
          parent_model: :parent,
          fields: [{ key_path: :inner1_field }]
        }
      end
      let(:inner_query2) do
        {
          given: [third_level_query],
          model: :foo,
          parent_model: :parent,
          name: :inner_query2,
          constraints: [subquery_constraint],
          fields: [{ key_path: :inner2_field }]
        }
      end
      let(:third_level_query) do
        {
          name: :third_level_query,
          model: :foo,
          parent_model: :bar,
          fields: [{ key_path: :third_level_field }]
        }
      end
      let(:subject) { described_class.make(outer_query) }
      let(:second_level_queries) { subject.given }

      it 'exposes subqueries through the "given" method' do
        expect(second_level_queries.size).to eq 2
        expect(second_level_queries[0].name).to eq :inner_query1
        expect(second_level_queries[1].name).to eq :inner_query2

        third_level_queries = second_level_queries[1].given
        expect(third_level_queries[0].name).to eq :third_level_query
        # The tree ends here:
        expect(third_level_queries[0].given).to eq []
      end

      it 'populates all of the subquery fields' do
        subquery = second_level_queries[1]
        expect(subquery.name).to eq(:inner_query2)
        expect(subquery.model).to eq(:foo)
        expect(subquery.constraints).to eq [Dbee::Model::Constraints.make(subquery_constraint)]
      end
    end

    describe 'subquery validation' do
      let(:valid_subquery) { { name: :third_level_query, model: :foo, parent_model: :bar } }
      let(:subquery) { valid_subquery }
      let(:outer_query) { { given: [subquery] } }
      let(:subject) { described_class.make(outer_query) }

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

      describe 'given a subquery without a model' do
        let(:subquery) { valid_subquery.merge(model: nil) }

        it 'raises an error' do
          expect { subject }.to raise_error(
            ActsAsHashable::Hashable::HydrationError,
            /model is required for subqueries/
          )
        end
      end
    end
  end

  context 'README examples do not produce errors' do
    EXAMPLES = {
      'Get all practices' => {
        fields: [
          { key_path: 'id' },
          { key_path: 'active' },
          { key_path: 'name' }
        ]
      },
      'Get all practices, limit to 10, and sort by name (descending) then id (ascending)' => {
        fields: [
          { key_path: 'id' },
          { key_path: 'active' },
          { key_path: 'name' }
        ],
        sorters: [
          { key_path: 'name', direction: :descending },
          { key_path: 'id' }
        ],
        limit: 10
      },
      "Get top 5 active practices and patient whose name start with 'Sm':" => {
        fields: [
          { key_path: 'name', display: 'Practice Name' },
          { key_path: 'patients.first', display: 'Patient First Name' },
          { key_path: 'patients.middle', display: 'Patient Middle Name' },
          { key_path: 'patients.last', display: 'Patient Last Name' }
        ],
        filters: [
          { type: :equals, key_path: 'active', value: true },
          { type: :starts_with, key_path: 'patients.last', value: 'Sm' }
        ],
        limit: 5
      },
      'Get practice IDs, patient IDs, names, and cell phone numbers that starts with 555' => {
        fields: [
          { key_path: 'id', display: 'Practice ID #' },
          { key_path: 'patients.id', display: 'Patient ID #' },
          { key_path: 'patients.first', display: 'Patient First Name' },
          { key_path: 'patients.middle', display: 'Patient Middle Name' },
          { key_path: 'patients.last', display: 'Patient Last Name' },
          { key_path: 'patients.cell_phone_numbers.phone_number', display: 'Patient Cell #' }
        ],
        filters: [
          { type: :equals, key_path: 'active', value: true },
          {
            type: :starts_with,
            key_path: 'patients.cell_phone_numbers.phone_number',
            value: '555'
          }
        ]
      }
    }.freeze

    EXAMPLES.each_pair do |name, query|
      specify name do
        expect(described_class.make(query)).to be_a(Dbee::Query::Base)
      end
    end
  end
end
