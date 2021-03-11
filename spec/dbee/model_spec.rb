# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require 'fixtures/models'

describe Dbee::Model do
  describe '#initialize' do
    specify 'name is set properly' do
      config = { name: 'theaters' }

      model = described_class.make(config)

      expect(model.name).to eq(config[:name])
    end

    specify 'models are set properly' do
      config = {
        name: 'theaters',
        models: [
          { name: 'members' },
          { name: 'passes' }
        ]
      }

      expected_association_names = config[:models].map { |a| a[:name] }

      model = described_class.make(config)

      association_names = model.models.map(&:name)

      expect(association_names).to eq(expected_association_names)
    end

    describe 'sub types' do
      it 'is table based by default' do
        config = { name: 'theaters' }
        model = described_class.make(config)

        expect(model).to be_a(Dbee::Model::TableBased)
      end

      it 'is derived when the type indicates this' do
        config = { name: 'theaters', type: :derived, query: { from: :sub_model, limit: 42 } }
        model = described_class.make(config)

        expect(model).to be_a(Dbee::Model::Derived)
      end

      it 'is derived when there is a query attribute' do
        pending 'this requires a custom make method'

        config = { name: 'theaters', query: :foo }
        model = described_class.make(config)

        expect(model).to be_a(Dbee::Model::Derived)
      end
    end
  end

  describe '.make_keyed_by' do
    it 'returns a hash of Models where the keys equal the names of the models' do
      input = {
        model1: nil,
        model2: { table: :model2_table }
      }
      expected_result = {
        'model1' => described_class.make(name: 'model1'),
        'model2' => described_class.make(name: 'model2', table: 'model2_table')
      }

      expect(described_class.make_keyed_by(:name, input)).to eq expected_result
    end

    it 'accepts values of Dbee::Model instances' do
      input = { model1: described_class.make(name: :model1) }
      expected_result = { 'model1' => described_class.make(name: :model1) }
      expect(described_class.make_keyed_by(:name, input)).to eq expected_result
    end

    it 'accepts values of Dbee::Model instances when the key attribute is a string' do
      input = { 'model1' => described_class.make(name: 'model1') }
      expected_result = { 'model1' => described_class.make(name: 'model1') }
      expect(described_class.make_keyed_by(:name, input)).to eq expected_result
    end

    it 'raises an error when the input hash key is not equal to the name of the model' do
      input = { model1: described_class.make(name: :bogus) }
      expect do
        described_class.make_keyed_by(:name, input)
      end.to raise_error ArgumentError, "expected a name of 'model1' but got 'bogus'"
    end
  end

  describe '#to_s' do
    it 'is represented by the model name' do
      expect(described_class.make(name: 'foo').to_s).to eq 'foo'
    end
  end

  describe '#ancestors!' do
    let(:yaml_entities) { yaml_fixture('models.yaml') }
    let(:entity_hash) { yaml_entities['Theaters, Members, and Movies Tree Based'] }

    subject { described_class.make(entity_hash) }

    it 'returns proper models' do
      members = subject.models.first

      expected_plan = {
        %w[members] => members
      }

      plan = subject.ancestors!(%w[members])

      expect(plan).to eq(expected_plan)
    end

    specify 'returns proper multi-level models' do
      members       = subject.models.first
      demos         = members.models.first
      phone_numbers = demos.models.first

      expected_plan = {
        %w[members] => members,
        %w[members demos] => demos,
        %w[members demos phone_numbers] => phone_numbers
      }

      plan = subject.ancestors!(%w[members demos phone_numbers])

      expect(plan).to eq(expected_plan)
    end
  end

  equality_cases = {
    tree_based: yaml_fixture('models.yaml')['Theaters, Members, and Movies Tree Based'],
    graph_based: yaml_fixture('models.yaml')['Theaters, Members, and Movies from DSL']['theater']
  }
  equality_cases[:graph_based].merge!(name: 'theaters')

  equality_cases.each do |test_case, config|
    describe "equality for #{test_case}" do
      let(:model1) { described_class.make(config) }
      let(:model2) { described_class.make(config) }

      subject { described_class.make(config) }

      specify 'equality compares attributes' do
        expect(model1).to eq(model2)
        expect(model1).to eql(model2)
      end

      it 'returns false unless comparing same object types' do
        expect(subject).not_to eq(config)
        expect(subject).not_to eq(nil)
      end

      describe 'hash codes' do
        specify 'are equal when objects are equal' do
          expect(model1).to eq(model2)
          expect(model1.hash).to eq(model2.hash)
        end

        specify 'are not equal when objects are not equal' do
          different_model = described_class.make(name: :oddball)
          expect(model1).not_to eq(different_model)
          expect(model1.hash).not_to eq(different_model.hash)
        end
      end
    end
  end
end
