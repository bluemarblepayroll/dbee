# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#
require_relative '../util/make_keyed_by'

module Dbee
  class Model
    # A model which is derived using a subquery.
    class Derived < Dbee::Model::Base
      extend Dbee::Util::MakeKeyedBy
      extend Forwardable

      attr_reader :query

      def_delegators :query, :relationships_from

      def initialize(params)
        query = params[:query]
        raise ArgumentError, 'a query is required' unless query

        # TODO: raise an error if the query already has a name and it is
        # different from this model's name
        @query = if query.is_a?(Dbee::Query::Sub)
                   query
                 else
                   Dbee::Query::Sub.make(query.merge(name: params[:name]))
                 end

        super params.reject { |key, _| key == :query }
      end

      def ==(other)
        # TODO: add deep query equality:
        super && other.query.name == query.name
      end
      alias eql? ==

      def hash
        [super, query.hash].hash
      end
    end
  end
end
