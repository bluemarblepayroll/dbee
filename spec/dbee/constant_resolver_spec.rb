# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

# rubocop:disable Lint/EmptyClass
# These are intentionally empty to keep the tests focused.
module A
  class B; end

  class E; end
end

class B; end

module C
  class D; end

  class E; end

  module F
    class G; end
  end
end
# rubocop:enable Lint/EmptyClass

describe Dbee::ConstantResolver do
  it 'resolves nested constant with the same as an ancestor constants sibling' do
    expect(subject.constantize('A::B')).to eq(::A::B)
  end

  it 'resolves root constant' do
    expect(subject.constantize('B')).to eq(::B)
  end

  it 'does not resolve constant in a different parent module' do
    expect { subject.constantize('C::B') }.to raise_error(NameError)
  end

  it 'does not resolve constant in a different parent module' do
    expect { subject.constantize('D') }.to raise_error(NameError)
  end

  it 'resolves same leaf constants specific to their parents' do
    expect(subject.constantize('A::E')).to eq(::A::E)
    expect(subject.constantize('C::E')).to eq(::C::E)
  end

  it 'does not resolve constant without its parent' do
    expect { subject.constantize('F') }.to raise_error(NameError)
  end
end
