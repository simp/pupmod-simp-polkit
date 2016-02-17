require 'spec_helper'

describe 'polkit' do

  it { is_expected.to create_class('polkit') }
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_package('polkit').with_ensure(/latest/) }
end
