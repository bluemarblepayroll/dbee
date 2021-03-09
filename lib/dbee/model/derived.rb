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

      attr_reader :query

      def initialize(params)
        query = params[:query]
        raise ArgumentError, 'a query is required' unless query

        @query = Dbee::Query::Sub.make(query.merge(name: params[:name]))

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
