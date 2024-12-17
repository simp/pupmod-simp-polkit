require 'spec_helper'

describe 'polkit::authorization::rule' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      context 'with minimal parameters' do
        let(:title) { 'test' }
        let(:params) do
          {
            ensure: 'present',
         content: 'totally javascript trust me it me your friend'
          }
        end

        it { is_expected.to create_file('/etc/polkit-1/rules.d/10-test.rules') }
      end

      context 'with a name that requires substitution' do
        let(:title) { 'A rule that manages libvirt/users' }
        let(:params) do
          {
            ensure: 'present',
         content: 'totally javascript trust me it me your friend'
          }
        end

        it { is_expected.to create_file('/etc/polkit-1/rules.d/10-a_rule_that_manages_libvirt_users.rules') }
      end

      context 'with a different priority and rulesd' do
        let(:title) { 'test' }
        let(:params) do
          {
            ensure: 'present',
         content: 'totally javascript trust me it me your friend',
         priority: 99,
         rulesd: '/best/path'
          }
        end

        it { is_expected.to create_file('/best/path/99-test.rules') }
      end
    end
  end
end
