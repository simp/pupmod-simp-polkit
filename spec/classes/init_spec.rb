require 'spec_helper'

describe 'polkit' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('polkit') }
      it { is_expected.to contain_package('polkit').with_ensure('installed') }

    end
  end
end
