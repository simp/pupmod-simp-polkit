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
        it 'remounts /proc with hidepid=2' do
          on(host, 'mount -o remount,hidepid=2 /proc')
        end

        it 'shows a notification message but does not restart the service' do
          output = apply_manifest_on(host, manifest, :accept_all_exit_codes => true).output

          expect(output).to match(/hidepid warning/)
          expect(output).not_to match(/Service/)
        end

        # DO NOT DO THIS IN PRODUCTION - JUST FOR TESTING
        it 'remounts /proc with hidepid=2 and gid=100' do
          on(host, 'mount -o remount,hidepid=2,gid=100 /proc')
        end

        it 'applies with no errors and does not show a notification message' do
          output = apply_manifest_on(host, manifest).output

          expect(output).not_to match(/hidepid warning/)
        end

        it 'is idempotent' do
          apply_manifest_on(host, manifest, catch_changes: true)
        end

        it 'does not show pkttyagent warnings when running service restarts' do
          expect(on(host, 'service foo restart', :accept_all_exit_codes => true).output)
            .not_to match(%r{pkttyagent.+WARNING})
        end
      end
    end
  end
end
