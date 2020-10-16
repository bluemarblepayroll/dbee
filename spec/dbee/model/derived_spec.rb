# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Dbee::Model::Derived do
  it 'requires a query' do
    expect do
      described_class.make(name: 'theaters', query: nil)
    end.to raise_error ActsAsHashable::Hashable::HydrationError, /query is required/
  end

  it 'does not allow a table' do
    expect do
      described_class.make(name: 'theaters', table: 'theaters', query: { limit: 100 })
    end.to raise_error ActsAsHashable::Hashable::HydrationError
  end

  describe 'subquery creation' do
    describe 'for a root model' do
      it "populates the subquery's name" do
        model_spec = {
          name: 'test_name',
          query: { limit: 10, model: 'subquery_model' }
        }.freeze
        subject = described_class.make(model_spec)

        query = subject.query
        expect(query).to be_a Dbee::Query::Sub
        expect(query.name).to eq model_spec[:name]
      end

      it 'requires that the query is a hash'
    end

    describe 'when not the root model' do
      let(:derived_model_spec) do
        {
          type: :derived,
          name: 'derived_model',
          constraints: [
            {
              type: :reference,
              parent: :id,
              name: :root_table_id
            }
          ],
          query: { limit: 10, model: 'other_model' }
        }
      end
      let(:model_spec) do
        {
          name: 'root_model',
          table: 'root_table',
          models: [derived_model_spec]
        }.freeze
      end
      let(:root_model) { Dbee::Model.make(model_spec) }
      subject { root_model.models.first }
      let(:query) { subject.query }

      it "sets the subquery's parent model" do
        expect(query).to be_a Dbee::Query::Sub
        expect(query.parent_model).to eq 'root_model'
      end

      it 'copies down the constraint to the subquery' do
        expect(query).to be_a Dbee::Query::Sub
        constraints = query.constraints
        expect(constraints).to eq Dbee::Model::Constraints.array(derived_model_spec[:constraints])
      end
    end
  end
end
