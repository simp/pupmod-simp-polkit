require 'spec_helper'

describe 'polkit::local_authority' do

  let(:title) {'test_title'}
  let(:params) {{
    :identity   => 'unix-user:foouser',
    :action     => 'com.example.domain',
    :result_any => 'no'
  }}

  it { is_expected.to create_file('/etc/polkit-1/localauthority/90-mandatory.d/test_title.pkla') }
end
