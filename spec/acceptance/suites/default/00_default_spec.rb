require 'spec_helper_acceptance'

test_name 'polkit'

describe 'polkit' do
  hosts.each do |_host|
    let(:manifest) do
      <<-EOF
      user { 'test': ensure => 'present' }

      polkit::authorization::basic_policy { 'Allow all pkexec':
        result      => 'yes',
        action_id   => 'org.freedesktop.policykit.exec',
        log_action  => true,
        log_subject => true
      }
      EOF
    end

    hosts.each do |host|
      context "on #{host}" do
        it 'applies with no errors' do
          apply_manifest_on(host, manifest)
        end

        it 'is idempotent' do
          apply_manifest_on(host, manifest, catch_changes: true)
        end

        it 'allows anyone to run pkexec commands without authentication' do
          on(host, 'runuser -u test pkexec ls /root')
        end
      end
    end
  end
end
