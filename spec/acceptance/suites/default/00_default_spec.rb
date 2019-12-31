require 'spec_helper_acceptance'

test_name 'polkit'

describe 'polkit' do
  hosts.each do |host|
    let(:manifest) { <<-EOF
      user { 'test': ensure => 'present' }

      polkit::authorization::basic_policy { 'Allow all pkexec':
        result      => 'yes',
        action_id   => 'org.freedesktop.policykit.exec',
        log_action  => true,
        log_subject => true
      }
      EOF
    }

    hosts.each do |host|
      context "on #{host}" do
        it 'should apply with no errors' do
          apply_manifest_on(host,manifest)
        end

        it 'should be idempotent' do
          apply_manifest_on(host,manifest, catch_changes: true)
        end

        it 'should allow anyone to run pkexec commands without authentication' do
          on(host, 'runuser -u test pkexec ls /root')
        end
      end
    end
  end
end
