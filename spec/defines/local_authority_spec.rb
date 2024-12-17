require 'spec_helper'

describe 'polkit::local_authority' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      let(:title) { 'test_title' }
      let(:req_params) do
        {
          identity: 'unix-user:foouser',
       action: 'com.example.domain',
        }
      end

      context 'with a name that requires substitution' do
        let(:title) { 'test/title' }
        let(:params) do
          req_params.merge({
                             result_any: 'no'
                           })
        end
        let(:expected) { File.read(File.expand_path('spec/files/any_sample.pkla')) }

        it {
          is_expected.to create_file('/etc/polkit-1/localauthority/90-mandatory.d/test_title.pkla').with_content(<<-EOF.gsub(%r{^\s+}, ''),
          [test/title]
          Identity=unix-user:foouser
          Action=com.example.domain
          ResultAny=no
        EOF
                                                                                                                )
        }
      end

      results = {
        result_active: 'ResultActive',
        result_inactive: 'ResultInactive',
        result_any: 'ResultAny',
      }
      results.each do |param, expected|
        context "with only #{param} set" do
          let(:params) do
            req_params.merge({
                               param => 'no'
                             })
          end

          it {
            is_expected.to create_file('/etc/polkit-1/localauthority/90-mandatory.d/test_title.pkla').with_content(<<-EOF.gsub(%r{^\s+}, ''),
            [test_title]
            Identity=unix-user:foouser
            Action=com.example.domain
            #{expected}=no
          EOF
                                                                                                                  )
          }
        end
      end

      context 'with many results specified' do
        let(:params) do
          req_params.merge({
                             result_active: 'yes',
          result_inactive: 'no'
                           })
        end

        it {
          is_expected.to create_file('/etc/polkit-1/localauthority/90-mandatory.d/test_title.pkla').with_content(<<-EOF.gsub(%r{^\s+}, ''),
          [test_title]
          Identity=unix-user:foouser
          Action=com.example.domain
          ResultActive=yes
          ResultInactive=no
        EOF
                                                                                                                )
        }
      end

      authority_map = {
        'vendor'    => '/etc/polkit-1/localauthority/10-vendor.d/test_title.pkla',
        'org'       => '/etc/polkit-1/localauthority/20-org.d/test_title.pkla',
        'site'      => '/etc/polkit-1/localauthority/30-site.d/test_title.pkla',
        'local'     => '/etc/polkit-1/localauthority/50-local.d/test_title.pkla',
        'mandatory' => '/etc/polkit-1/localauthority/90-mandatory.d/test_title.pkla'
      }
      authority_map.each do |authority, filename|
        context "with authority => #{authority}" do
          let(:params) do
            req_params.merge({
                               result_any: 'no',
            authority: authority,
                             })
          end

          it {
            is_expected.to create_file(filename).with_content(<<-EOF.gsub(%r{^\s+}, ''),
            [test_title]
            Identity=unix-user:foouser
            Action=com.example.domain
            ResultAny=no
          EOF
                                                             )
          }
        end
      end
    end
  end
end
