require 'spec_helper'

describe 'polkit::authorization::basic_policy' do
  supported_os = on_supported_os.delete_if { |e| e =~ /-6-/ } #TODO do this right
  supported_os.each do |os, facts|
  # on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'authorize group to do an action' do
        let(:title) { 'test' }
        let(:params) {{
          :ensure    => 'present',
          :result    => 'yes',
          :action_id => 'an.action',
          :group     => 'developers',
        }}
        it { is_expected.to create_polkit__authorization__rule('test').with({
          :ensure => 'present',
          :content => <<-EOF
// This file is managed by Puppet
polkit.addRule(function(action, subject) {
  if ((action.id == 'an.action') && subject.isInGroup('developers')) {
      polkit.log("action=" + action);
      polkit.log("subject=" + subject);
      return polkit.Result.YES;
  }
});
          EOF
        }) }
      end

      context 'authorize list of groups to do an action' do
        let(:title) { 'test' }
        let(:params) {{
          :ensure    => 'present',
          :result    => 'yes',
          :action_id => 'an.action',
          :group     => ['developers0','developers1','developers2'],
        }}
        it { is_expected.to create_polkit__authorization__rule('test').with({
          :ensure => 'present',
          :content => <<-EOF
// This file is managed by Puppet
polkit.addRule(function(action, subject) {
  if ((action.id == 'an.action') && subject.isInGroup('developers0') && subject.isInGroup('developers1') && subject.isInGroup('developers2')) {
      polkit.log("action=" + action);
      polkit.log("subject=" + subject);
      return polkit.Result.YES;
  }
});
          EOF
        }) }
      end

      context 'deny a user to do an action' do
        let(:title) { 'test' }
        let(:params) {{
          :ensure    => 'present',
          :result    => 'no',
          :action_id => 'an.action',
          :user      => 'person',
        }}
        it { is_expected.to create_polkit__authorization__rule('test').with({
          :ensure => 'present',
          :content => <<-EOF
// This file is managed by Puppet
polkit.addRule(function(action, subject) {
  if ((action.id == 'an.action') && subject.user == 'person') {
      polkit.log("action=" + action);
      polkit.log("subject=" + subject);
      return polkit.Result.NO;
  }
});
          EOF
        }) }
      end

      context 'with a custom conditional set' do
        let(:title) { 'test' }
        let(:params) {{
          :ensure    => 'present',
          :result    => 'auth_admin',
          :condition => 'some whacky javascript hack'
        }}
        it { is_expected.to create_polkit__authorization__rule('test').with({
          :ensure => 'present',
          :content => <<-EOF
// This file is managed by Puppet
polkit.addRule(function(action, subject) {
  if (some whacky javascript hack) {
      polkit.log("action=" + action);
      polkit.log("subject=" + subject);
      return polkit.Result.AUTH_ADMIN;
  }
});
          EOF
        }) }
      end

      context 'without logging' do
        let(:title) { 'test' }
        let(:params) {{
          :ensure      => 'present',
          :result      => 'auth_admin',
          :condition   => 'some whacky javascript hack',
          :log_action  => false,
          :log_subject => false
        }}
        it { is_expected.to create_polkit__authorization__rule('test').with({
          :ensure => 'present',
          :content => <<-EOF
// This file is managed by Puppet
polkit.addRule(function(action, subject) {
  if (some whacky javascript hack) {
      return polkit.Result.AUTH_ADMIN;
  }
});
          EOF
        }) }
      end
    end
  end
end
