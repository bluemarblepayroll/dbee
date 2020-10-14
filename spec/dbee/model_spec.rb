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
        config = { name: 'theaters', type: :derived, query: { limit: 42 } }
        model = described_class.make(config)

        expect(model).to be_a(Dbee::Model::Derived)
      end

      # Not sure if acts_as_hashable_factory can support this...
      pending 'is derived when there is a query attribute' do
        config = { name: 'theaters', query: :foo }
        model = described_class.make(config)

        expect(model).to be_a(Dbee::Model::Derived)
      end
    end
  end

  describe '#ancestors' do
    let(:yaml_entities) { yaml_fixture('models.yaml') }

    let(:entity_hash) { yaml_entities['Theaters, Members, and Movies'] }

    subject { described_class.make(entity_hash) }

    specify 'returns proper models' do
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

  describe 'equality' do
    let(:config) { yaml_fixture('models.yaml')['Theaters, Members, and Movies'] }

    subject { described_class.make(config) }

    specify 'equality compares attributes' do
      model1 = described_class.make(config)
      model2 = described_class.make(config)

      expect(model1).to eq(model2)
      expect(model1).to eql(model2)
    end

    it 'returns false unless comparing same object types' do
      expect(subject).not_to eq(config)
      expect(subject).not_to eq(nil)
    end
  end

  context 'README examples' do
    specify 'code-first and configuration-first models are equal' do
      config        = yaml_fixture('models.yaml')['Readme']
      config_model  = described_class.make(config)

      key_chain = Dbee::KeyChain.new(%w[
                                       patients.a
                                       patients.notes.b
                                       patients.work_phone_number.c
                                       patients.cell_phone_number.d
                                       patients.fax_phone_number.e
                                     ])

      code_model = ReadmeDataModels::Practice.to_model(key_chain)

      expect(config_model).to eq(code_model)
    end
  end
end
