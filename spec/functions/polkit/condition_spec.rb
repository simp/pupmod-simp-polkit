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
    { 'user' => 'testuser' }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.user == 'testuser'")
  }

  it { is_expected.to run.with_params(
    'org.libvirt.unix.manage',
    { 'user' => 'testuser', 'group' => 'virshusers' }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.user == 'testuser' && subject.isInGroup('virshusers')")
  }

  it { is_expected.to run.with_params(
    'org.libvirt.unix.manage',
    { 'user' => 'testuser', 'local' => true }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.user == 'testuser' && subject.local")
  }

  it { is_expected.to run.with_params(
    'org.libvirt.unix.manage',
    { 'user' => 'testuser', 'active' => true }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.user == 'testuser' && subject.active")
  }

  it { is_expected.to run.with_params(
    'org.libvirt.unix.manage',
    { 'user' => 'testuser', 'active' => true, 'local' => true }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.user == 'testuser' && subject.local && subject.active")
  }

  it { is_expected.to run.with_params(
    'org.libvirt.unix.manage',
    { 'user' => 'testuser', 'active' => true, 'local' => true, 'group' => 'testgroup' }
    ).and_return("(action.id == 'org.libvirt.unix.manage') && subject.user == 'testuser' && subject.isInGroup('testgroup') && subject.local && subject.active")
  }

end