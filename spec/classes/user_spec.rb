# frozen_string_literal: true

require 'spec_helper'

describe 'polkit::user' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      let(:pre_condition) do
        <<~FUNCTION_STUB
          function assert_private(){}
        FUNCTION_STUB
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_user('polkitd').with_groups(nil) }

      context 'with gid set on /proc' do
        let(:facts) do
          os_facts.merge(
            {
              simplib__mountpoints: {
                '/proc' => {
                  'options_hash' => {
                    '_gid__group' => 'proc_access',
                  },
                },
              },
            },
          )
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_user('polkitd').with_groups(['proc_access']) }
        it { is_expected.not_to contain_notify('polkit::user - hidepid warning') }

        context 'with groups passed in the options' do
          let(:params) do
            {
              user_options: {
                'gid' => 123,
                'groups' => ['bob'],
              },
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_user('polkitd').with_gid(123) }
          it { is_expected.to contain_user('polkitd').with_groups(['proc_access', 'bob']) }
        end
      end

      [1, 2].each do |hidepid_val|
        context "with hidepid=#{hidepid_val} set on /proc" do
          context 'with gid unset' do
            let(:facts) do
              os_facts.merge(
                {
                  simplib__mountpoints: {
                    '/proc' => {
                      'options_hash' => {
                        'hidepid' => hidepid_val,
                      },
                    },
                  },
                },
              )
            end

            it do
              is_expected.to contain_notify('polkit::user - hidepid warning')
                .with_loglevel('warning')
                .with_message(%r{must be set})
            end

            context 'when disabling the warning' do
              let(:params) do
                {
                  report_proc_issues: false,
                }
              end

              it do
                is_expected.to contain_notify('polkit::user - hidepid warning')
                  .with_loglevel('debug')
                  .with_message(%r{must be set})
              end
            end
          end

          context 'with gid set' do
            let(:facts) do
              os_facts.merge(
                {
                  simplib__mountpoints: {
                    '/proc' => {
                      'options_hash' => {
                        '_gid__group' => 'proc_access',
                        'hidepid' => hidepid_val,
                      },
                    },
                  },
                },
              )
            end

            it { is_expected.not_to contain_notify('polkit::user - hidepid warning') }
          end
        end
      end
    end
  end
end
