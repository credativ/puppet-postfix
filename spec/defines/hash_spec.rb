require 'spec_helper'

describe 'postfix::hash' do
  context 'with default parameter' do
    let(:title) { '/test' }
    it do
      is_expected.to compile
    end
  end
end
