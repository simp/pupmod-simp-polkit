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

  context 'on Windows' do
    let(:facts) do
      {
        os: {
          'architecture' => 'x64',
         'family' => 'windows',
         'hardware' => 'x86_64',
         'name' => 'windows',
         'release' => { 'full' => '2008 R2', 'major' => '2008 R2' },
         'windows' => { 'system32' => 'C:\\Windows\\system32' }
        }
      }
    end

    let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

    let(:pre_condition) do
      # Mask `warning` for testing
      <<~PRE_CONDITION
      function warning($message) { notify { 'warning_test': message => $message } }
      PRE_CONDITION
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to create_class('polkit') }
    it { is_expected.to create_notify('warning_test').with_message(%r{is not supported}) }
  end
end
