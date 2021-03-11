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
    let(:query_spec) { { limit: 10, from: 'subquery_model' } }

    it 'allows for a query to be an instance of Dbee::Query::Sub' do
      subquery = Dbee::Query::Sub.make(query_spec.merge(name: 'foo'))
      subject = described_class.make(name: 'foo', query: subquery)
      expect(subject.query).to eq subquery
    end

    describe 'for a root model' do
      it "populates the subquery's name" do
        model_spec = {
          name: 'test_name',
          query: query_spec
        }.freeze
        subject = described_class.make(model_spec)

        query = subject.query
        expect(query).to be_a Dbee::Query::Sub
        expect(query.name).to eq model_spec[:name]
      end
    end
  end
end
