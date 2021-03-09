# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require_relative '../fixtures/models'

describe Dbee::Schema do
  def make_model(model_name)
    raise "no model named '#{model_name}'" unless schema_config.key?(model_name)

    Dbee::Model.make((schema_config[model_name] || {}).merge('name' => model_name))
  end

  let(:model_name) do
    'Theaters, Members, and Movies from DSL'
  end
  let(:schema_config) { yaml_fixture('models.yaml')[model_name] }

  let(:demographics_model) { make_model('demographic') }
  let(:members_model) { make_model('member') }
  let(:movies_model) { make_model('movie') }
  let(:phone_numbers_model) { make_model('phone_number') }
  let(:theaters_model) { make_model('theater') }

  let(:subject) { described_class.new(schema_config) }

  describe '#expand_query_path' do
    specify 'one model case' do
      expect(subject.expand_query_path(members_model, Dbee::KeyPath.new('id'))).to eq []
    end

    specify 'two model case' do
      expected_path = [[members_model.relationship_for_name('movies'), movies_model]]
      expect(
        subject.expand_query_path(members_model, Dbee::KeyPath.new('movies.id'))
      ).to eq expected_path
    end

    it 'traverses aliased models' do
      expected_path = [
        [members_model.relationship_for_name('demos'), demographics_model],
        [demographics_model.relationship_for_name('phone_numbers'), phone_numbers_model]
      ]

      expect(
        subject.expand_query_path(members_model, Dbee::KeyPath.new('demos.phone_numbers.id'))
      ).to eq expected_path
    end

    it 'raises an error given an unknown relationship' do
      expect do
        subject.expand_query_path(theaters_model, Dbee::KeyPath.new('demographics.id'))
      end.to raise_error("model 'theater' does not have a 'demographics' relationship")
    end
  end
end
