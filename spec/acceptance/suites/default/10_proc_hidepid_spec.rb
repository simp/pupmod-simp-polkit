# frozen_string_literal: true

require 'spec_helper_acceptance'

test_name 'polkit with /proc hidepid=2'

describe 'polkit with /proc hidepid=2' do
  hosts.each do |_host|
    let(:manifest) do
      'include polkit'
    end

    hosts.each do |host|
      context "on #{host}" do
        # DO NOT DO THIS IN PRODUCTION - JUST FOR TESTING
        it 'remounts /proc with hidepid=2 and gid=100' do
          on(host, 'mount -o remount,hidepid=2,gid=100 /proc')
        end

        it 'applies with no errors' do
          apply_manifest_on(host, manifest)
        end

        it 'is idempotent' do
          apply_manifest_on(host, manifest, catch_changes: true)
        end

        it 'allows anyone to run pkexec commands without authentication' do
          on(host, 'runuser -u test pkexec ls /root')
        end

        it 'does not show pkttyagent warnings when running service restarts' do
          expect(on(host, 'service foo restart', :accept_all_exit_codes => true).output)
            .not_to match(%r{pkttyagent.+WARNING})
        end
      end
    end
  end
end
