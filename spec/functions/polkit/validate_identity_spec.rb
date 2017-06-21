require 'spec_helper'

describe 'polkit::validate_identity' do
  context 'valid identities ' do
    [ 'unix-user:user1', 
      'unix-group:groupA', 
      ['unix-user:*', 'unix-group:group-a_1.0*']
    ].each do |identity_list|
      it { is_expected.to run.with_params(identity_list) }
    end
  end

  context 'invalid identities' do
    it 'rejects invalid identity prefix' do
      is_expected.to run.with_params('unix-usr:oops').and_raise_error(
      /Error, identity specifier 'unix-usr'/)
    end

    it 'rejects identity missing value' do
      is_expected.to run.with_params(['unix-group:groupA', 'unix-user:']).and_raise_error(
      /Error, value '' is invalid for entry 'unix-user:'/)
    end

    it 'rejects identity with invalid characters value' do
      is_expected.to run.with_params('unix-user:user1?').and_raise_error(
        /Error, value 'user1.' is invalid for entry/)
    end
  end
end
