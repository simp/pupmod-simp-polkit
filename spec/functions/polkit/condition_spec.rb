require 'spec_helper'

describe 'polkit::condition' do

  it { is_expected.to run.with_params().and_raise_error(/expects 2 arguments, got none/i) }
  it { is_expected.to run.with_params('org.libvirt.unix.manage').and_raise_error(/expects 2 arguments, got 1/i) }

  it { is_expected.to run.with_params(
    'org.libvirt.unix.manage',
    { 'notaparam' => 'break' }
    ).and_raise_error(/unrecognized key 'notaparam'/i)
  }

  it { is_expected.to run.with_params(
      'org.libvirt.unix.manage',
      { 'group' => 'virshusers' }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.isInGroup('virshusers')")
  }

  it { is_expected.to run.with_params(
      'org.libvirt.unix.manage',
      { 'group' => ['virshusers0','virshusers1','virshusers2'] }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.isInGroup('virshusers0') && subject.isInGroup('virshusers1') && subject.isInGroup('virshusers2')")
  }

  it { is_expected.to run.with_params(
    'org.libvirt.unix.manage',
    { 'user' => 'testuser' }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.user == 'testuser'")
  }

  it { is_expected.to run.with_params(
    'org.libvirt.unix.manage',
    { 'user' => ['testuser0','testuser1','testuser2'] }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.user == 'testuser0' && subject.user == 'testuser1' && subject.user == 'testuser2'")
  }

  it { is_expected.to run.with_params(
    'org.libvirt.unix.manage',
    { 'user' => 'testuser', 'group' => 'virshusers' }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.user == 'testuser' && subject.isInGroup('virshusers')")
  }

  it { is_expected.to run.with_params(
    'org.libvirt.unix.manage',
    { 'user' => ['testuser0','testuser1'], 'group' => ['virshusers0','virshusers1'] }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.user == 'testuser0' && subject.user == 'testuser1' && subject.isInGroup('virshusers0') && subject.isInGroup('virshusers1')")
  }

  it { is_expected.to run.with_params(
    'org.libvirt.unix.manage',
    { 'user' => 'testuser', 'local' => true }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.local && subject.user == 'testuser'")
  }

  it { is_expected.to run.with_params(
    'org.libvirt.unix.manage',
    { 'user' => 'testuser', 'active' => true }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.active && subject.user == 'testuser'")
  }

  it { is_expected.to run.with_params(
    'org.libvirt.unix.manage',
    { 'user' => 'testuser', 'active' => true, 'local' => true }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.local && subject.active && subject.user == 'testuser'")
  }

  it { is_expected.to run.with_params(
    'org.libvirt.unix.manage',
    { 'user' => 'testuser', 'active' => true, 'local' => true, 'group' => 'testgroup' }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.local && subject.active && subject.user == 'testuser' && subject.isInGroup('testgroup')")
  }

end