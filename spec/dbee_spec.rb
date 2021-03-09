# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require 'fixtures/models'

describe Dbee do
  describe '#sql' do
    let(:provider) { Dbee::Providers::NullProvider.new }
    let(:query_hash) do
      {
        from: 'my_model',
        fields: [
          { key_path: :a }
        ]
      }
    end
    let(:query) { Dbee::Query.make(query_hash) }
    let(:schema) { Dbee::Schema.new({}) }

    it 'accepts a query hash and a Schema and passes them into provider#sql' do
      expect(provider).to receive(:sql).with(schema, query)

      described_class.sql(schema, query_hash, provider)
    end

    it 'does not allow a nil schema' do
      expect do
        described_class.sql(nil, query, provider)
      end.to raise_error ArgumentError, /schema or model is required/
    end

    it 'does not allow a nil query' do
      expect do
        described_class.sql(schema, nil, provider)
      end.to raise_error ArgumentError, /query is required/
    end

    it 'does not allow a nil provider' do
      expect do
        described_class.sql(schema, query, nil)
      end.to raise_error ArgumentError, /provider is required/
    end
  end
end
