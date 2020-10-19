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
  describe '#to_model' do
    it 'compiles correctly' do
      model_name      = 'Theaters, Members, and Movies'
      expected_config = yaml_fixture('models.yaml')[model_name]

      expected_model = Dbee::Model.make(expected_config)

      key_paths = %w[
        members.demos.phone_numbers.a
        members.movies.b
        members.favorite_comic_movies.c
        members.favorite_mystery_movies.d
        members.favorite_comedy_movies.e
        parent_theater.members.demos.phone_numbers.f
        parent_theater.members.movies.g
        parent_theater.members.favorite_comic_movies.h
        parent_theater.members.favorite_mystery_movies.i
        parent_theater.members.favorite_comedy_movies.j
      ]

      key_chain = Dbee::KeyChain.new(key_paths)

      actual_model = Models::Theater.to_model(key_chain)

      expect(actual_model).to eq(expected_model)
    end

    describe 'with a derived model' do
      it 'compiles correctly' do
        model_name      = 'Theaters with a Derived Model'
        expected_config = yaml_fixture('models.yaml')[model_name]

        expected_model = Dbee::Model.make(expected_config)

        key_paths = %w[
          members.foo
          member_derived_tests.members_column
        ]
        key_chain = Dbee::KeyChain.new(key_paths)

        actual_model = Models::Theater.to_model(key_chain)

        expect(actual_model).to eq(expected_model)
      end

      it 'compiles correctly when the query is a callable' do
        model_name      = 'Theaters with a Derived Model with a Callable Query'
        expected_config = yaml_fixture('models.yaml')[model_name]

        expected_model = Dbee::Model.make(expected_config)

        key_paths = %w[
          members.foo
          member_derived_callable_tests.members_column
        ]
        key_chain = Dbee::KeyChain.new(key_paths)

        actual_model = Models::Theater.to_model(key_chain)

        expect(actual_model).to eq(expected_model)
      end
    end

    it 'honors key_chain to flatten cyclic references' do
      model_name      = 'Cycle Example'
      expected_config = yaml_fixture('models.yaml')[model_name]

      expected_model = Dbee::Model.make(expected_config)

      key_paths = %w[
        b1.c.a.z
        b1.d.a.y
        b2.c.a.x
        b2.d.a.w
        b2.d.a.b1.c.z
      ]

      key_chain = Dbee::KeyChain.new(key_paths)

      actual_model = Cycles::A.to_model(key_chain)

      expect(actual_model).to eq(expected_model)
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

  describe 'partitioners' do
    it 'honors partitioners on a root model' do
      model_name      = 'Partitioner Example 1'
      expected_config = yaml_fixture('models.yaml')[model_name]
      expected_model = Dbee::Model.make(expected_config)

      key_paths = %w[id]
      key_chain = Dbee::KeyChain.new(key_paths)

      actual_model = PartitionerExamples::Dog.to_model(key_chain)

      expect(actual_model).to eq(expected_model)
    end

    it 'honors partitioners on a child model' do
      model_name      = 'Partitioner Example 2'
      expected_config = yaml_fixture('models.yaml')[model_name]
      expected_model = Dbee::Model.make(expected_config)

      key_paths = %w[id dogs.id]
      key_chain = Dbee::KeyChain.new(key_paths)

      actual_model = PartitionerExamples::Owner.to_model(key_chain)

      expect(actual_model).to eq(expected_model)
    end
  end

  it 'raises an error if a model has both a query and a table'
end
