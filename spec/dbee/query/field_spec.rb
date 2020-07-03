# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Dbee::Query::Field do
  let(:config) do
    {
      display: 'd',
      key_path: 'a.b.c'
    }
  end

  let(:config_with_aggregation_and_filters) do
    config.merge(
      aggregator: :ave,
      filters: [
        {
          key_path: 'a.b',
          value: 'something'
        }
      ]
    )
  end

  subject { described_class.new(config_with_aggregation_and_filters) }

  let(:subject_without_aggregation_and_filters) do
    described_class.new(config)
  end

  it 'should act as hashable' do
    expect(described_class).to respond_to(:make)
    expect(described_class).to respond_to(:array)
  end

  context '#initialize' do
    specify 'key_path is required' do
      expect { described_class.new(key_path: '') }.to   raise_error(ArgumentError)
      expect { described_class.new(key_path: nil) }.to  raise_error(ArgumentError)
      expect { described_class.new }.to                 raise_error(ArgumentError)
    end
  end

  context 'equality' do
    specify '#hash produces same output as [aggregator, key_path, and display]' do
      expected = [
        subject.aggregator,
        subject.display,
        subject.filters,
        subject.key_path
      ].hash

      expect(subject.hash).to eq(expected)
    end

    specify '#== and #eql? compare attributes' do
      object2 = described_class.new(config_with_aggregation_and_filters)

      expect(subject).to eq(object2)
      expect(subject).to eql(object2)
    end

    it 'returns false unless comparing same object types' do
      expect(subject).not_to eq('a.b.c')
      expect(subject).not_to eq(nil)
    end
  end

  describe '#aggregator?' do
    it 'returns true if not nil' do
      expect(subject.aggregator?).to be true
    end

    it 'returns false if nil' do
      expect(subject_without_aggregation_and_filters.aggregator?).to be false
    end
  end

  describe '#filters?' do
    it 'returns true if at least one filter' do
      expect(subject.filters?).to be true
    end

    it 'returns false if nil' do
      expect(subject_without_aggregation_and_filters.filters?).to be false
    end
  end
end
