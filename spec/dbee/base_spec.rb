# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require 'fixtures/models'

describe Dbee::Base do
  describe '.to_schema' do
    it 'passes the keychain and model to DslSchemaBuilder' do
      key_chain = Dbee::KeyChain.new

      schema_builder_double = double(Dbee::DslSchemaBuilder)
      expect(Dbee::DslSchemaBuilder).to receive(:new).with(Models::A, key_chain).and_return(
        schema_builder_double
      )
      expect(schema_builder_double).to receive(:to_schema)

      Models::A.to_schema(key_chain)
    end
  end

  context 'inheritance' do
    specify 'table is honored if set on subclass' do
      expect(Models::A.inherited_table_name).to eq('table_set_to_a')
      expect(Models::B.inherited_table_name).to eq('table_set_to_b')
    end

    specify 'table is honored if set on parent' do
      expect(Models::C.inherited_table_name).to eq('table_set_to_a')
      expect(Models::D.inherited_table_name).to eq('table_set_to_a')
      expect(Models::E.inherited_table_name).to eq('table_set_to_e')
    end
  end
end
