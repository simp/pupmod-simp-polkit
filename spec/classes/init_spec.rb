require 'spec_helper'

describe 'polkit' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('polkit') }
      it do
        is_expected.to create_class('polkit::install')
          .that_notifies('Class[polkit::service]')
          .that_comes_before('Class[polkit::user]')
      end
      it { is_expected.to create_class('polkit::user').that_notifies('Class[polkit::service]') }
      it { is_expected.to create_class('polkit::service') }
      it { is_expected.to contain_package('polkit').with_ensure('installed') }
      it { is_expected.to contain_service('polkit').with_ensure('running') }
    end
  end
end
