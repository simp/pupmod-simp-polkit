require 'spec_helper'

polkit_content = {
  :cresultany =>
    '[test_title]' +
    "\nIdentity=unix-user:foouser\n" +
    "Action=com.example.domain\n" +
    "ResultAny=no",

  :cresultmany =>
    "\[foo_title\]\n" +
    "Identity=unix-user:foouser\n" +
    "Action=com.example.domain\n" +
    "ResultActive=yes\n" +
    "ResultInActive=no"
}

describe 'polkit::local_authority' do
   let(:any_sample) {
     File.read(File.expand_path('spec/files/any_sample.pkla'))
   }

   let(:many_sample) {
     File.read(File.expand_path('spec/files/many_sample.pkla'))
   }

  context  'generate_resultany_file' do
    let(:content_option) { :cresultany }
    let(:title) {'test_title'}
    let(:params) {{
      :identity   => 'unix-user:foouser',
      :action     => 'com.example.domain',
      :result_any => 'no'
    }}

    it { is_expected.to create_file('/etc/polkit-1/localauthority/90-mandatory.d/test_title.pkla')}
    it { is_expected.to create_file('/etc/polkit-1/localauthority/90-mandatory.d/test_title.pkla').with_content(any_sample)}
  end

  context  'generate_resultmany_file' do
    let(:title) {'test_title'}
    let(:content_option) { :cresultmany }
    let(:params) {{
      :section_name => 'foo_title',
      :authority  =>  'site',
      :identity   => 'unix-user:foouser',
      :action     => 'com.example.domain',
      :result_active => 'yes',
      :result_inactive => 'no'
    }}

    it { is_expected.to create_file('/etc/polkit-1/localauthority/30-site.d/test_title.pkla').with_content(many_sample)}
  end

end
