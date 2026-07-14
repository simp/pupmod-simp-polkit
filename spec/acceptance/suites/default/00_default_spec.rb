require 'spec_helper_acceptance'

test_name 'polkit'

describe 'polkit' do
  hosts.each do |_host|
    let(:manifest) do
      <<~EOF
        user { 'test': ensure => 'present' }

        polkit::authorization::basic_policy { 'Allow all pkexec':
          result      => 'yes',
          action_id   => 'org.freedesktop.policykit.exec',
          log_action  => true,
          log_subject => true,
        }
      EOF
    end

    hosts.each do |host|
      # Exercise noop from a clean (uninstalled) state: on a fresh node the Sicura
      # console previews the module with `puppet apply --noop`, which must not error
      # even though nothing polkit manages exists yet. Real idempotence is covered
      # by the applies below. A post-convergence noop check is deliberately omitted:
      # `puppet apply --noop --detailed-exitcodes` always exits 0, so it could never
      # fail and would test nothing.
      context 'in noop mode from a clean state' do
        # Setup, not an assertion: as before(:context) a failure errors this context
        # rather than aborting the whole suite under .rspec's --fail-fast. `puppet
        # resource` exits 0 whether it removes the package or finds it already absent
        # (no --detailed-exitcodes), so no acceptable_exit_codes override is needed.
        before(:context) do
          on(host, 'puppet resource package polkit ensure=absent')
        end

        it 'applies without errors in noop mode' do
          apply_manifest_on(host, manifest, catch_failures: true, noop: true)
        end
      end

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
