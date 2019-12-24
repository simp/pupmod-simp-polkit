# @summary Add a rule file containing javascript Polkit configuration to the system
#
# @see polkit(8)
#
# The intention of this define is to make it easy to add simple polkit rules
# to a system. An example simple rule template is shown below:
#
# ```
# // This file is managed by Puppet
# polkit.addRule(function(action, subject) {
#   if (<condition>) {
#       return polkit.Result.<result>;
#     }
#   }
# });
# ```
#
# A user-specified <condition> can be supplied with the $condition parameter,
# or the define can use the polkit::condition function to generate a condition
# using $action_id, $user and/or $group, an (optionally) $local and $active.
#
# @example Allow users in the virtusers group to use the system libvirt
#   polkit::authorization::basic_policy { 'Allow users to use libvirt':
#     ensure    => present,
#     group     => 'virtusers',
#     result    => 'yes'
#     action_id => 'org.libvirt.unix.manage',
#     priority  => 20,
#     local     => true,
#     active    => true,
#   }
#
#   # Generates a policy file that looks like this
#   // This file is managed by Puppet
#   polkit.addRule(function(action, subject) {
#     if ((action.id == 'org.libvirt.unix.manage') && subject.user == 'testuser' && subject.isInGroup('testgroup') && subject.local && subject.active) {
#         return polkit.Result.YES;
#       }
#     }
#   });
#
# @param ensure
#   Create or destroy the rules file
#
# @param result
#   The authorization result of the polkit transaction, for example `yes` or `auth_admin`
#
# @param action_id
#   The polkit action to operate on
#
#   * A list of available actions can be found by running `pkaction`
#
# @param user
#   User to check
#
# @param group
#   The group(s) that the user checking authorization belongs to
#
# @param local
#   Check if the user is a local user. See man page for more explaination
#
# @param active
#   Check if the user is currently active. See man page for more explaination
#
# @param condition
#   If specified, will be placed in the javascript condition to be met for polkit authorization
#
# @param log_action
#   Log the action to the system log
#
# @param log_subject
#   Log the subject to the system log
#
# @param priority
#   Priority of the file to be created
#
# @param rulesd Location of the poklit rules directory
#
define polkit::authorization::basic_policy (
  Polkit::Result                      $result,
  Enum['present','absent']            $ensure      = 'present',
  Optional[String]                    $action_id   = undef,
  Variant[Undef,String,Array[String]] $user        = undef,
  Variant[Undef,String,Array[String]] $group       = undef,
  Boolean                             $local       = false,
  Boolean                             $active      = false,
  Optional[String]                    $condition   = undef,
  Boolean                             $log_action  = true,
  Boolean                             $log_subject = true,
  Integer[0,99]                       $priority    = 10,
  Stdlib::AbsolutePath                $rulesd      = '/etc/polkit-1/rules.d',
) {
  simplib::assert_metadata($module_name)

  if !$condition {
    if !$action_id {
      fail('If $condition is not specified, $action_id must be')
    }
  }

  polkit::authorization::rule { $name:
    ensure   => $ensure,
    priority => $priority,
    rulesd   => $rulesd,
    content  => template('polkit/basic_policy.erb'),
  }
}
