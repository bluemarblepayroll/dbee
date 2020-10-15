# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Dbee::Model::Derived do
  it 'makes a Dbee::Query::Sub' do
    pending 'This needs to be updated to produce a subquery'
    subject = described_class.make(name: 'theaters', query: { limit: 100 })
    expect(subject.query).to be_a Dbee::Query::Sub
  end

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
end
