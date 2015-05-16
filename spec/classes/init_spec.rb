require 'spec_helper'

describe 'polkit' do

  it { should create_class('polkit') }
  it { should compile.with_all_deps }
  it { should contain_package('polkit').with_ensure(/latest/) }
end
