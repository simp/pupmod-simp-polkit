# Add a rule file containing javascript Polkit configuration to the system
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
#     result    => ''
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
# @param ensure Create or destroy the rules file
#
# @param result The end result of the polkit, like 'yes' or 'auth_admin'
#
# @param action_id The polkit action to operate on
#
#   * A list of available actions can be found by running `pkaction`
#
# @param group Group to check membership of
#
# @param user User to check
#
# @param local Check of the user is a local user. See man page for more
#   explaination.
#
# @param active Check if the user is currently active. See man page for more
#   explaination.
#
# @param condition If specified, will be placed in the javascript condition to be met
#   for polkit authorization
#
# @param priority Priority of the file to be created
#
# @param rulesd Location of the poklit rules directory
#
define polkit::authorization::basic_policy (
  Enum['present','absent'] $ensure,
  Polkit::Result           $result,
  Optional[String]         $action_id   = undef,
  Optional[String]         $group       = undef,
  Optional[String]         $user        = undef,
  Boolean                  $local       = false,
  Boolean                  $active      = false,
  Optional[String]         $condition   = undef,
  Boolean                  $log_action  = true,
  Boolean                  $log_subject = true,
  Integer[0,99]            $priority    = 10,
  Stdlib::AbsolutePath     $rulesd      = '/etc/polkit-1/rules.d',
) {
  if !$condition {
    if !$action_id {
      fail('If $condition is not specified, $action_id must be')
    }
  }
  if $facts['os']['release']['major'] == '6' {
    fail('The version of Polkit available on EL6 does not support javascript configuration')
  }

  $_opts = {
    'group'  => $group,
    'user'   => $user,
    'local'  => $local,
    'active' => $active,
  }
  $_condition = $condition ? {
    String  => $condition,
    default => polkit::condition($action_id, $_opts)
  }

  $_content = inline_epp(@(EOF))
  // This file is managed by Puppet
  polkit.addRule(function(action, subject) {
    if (<%= $_condition -%>) {
        <%- if $log_action  { -%>
        polkit.log("action=" + action);
        <%- } -%>
        <%- if $log_subject { -%>
        polkit.log("subject=" + subject);
        <%- } -%>
        return polkit.Result.<%= $result.upcase -%>;
      }
    }
  });
  |EOF

  polkit::authorization::rule { $name:
    ensure   => $ensure,
    priority => $priority,
    rulesd   => $rulesd,
    content  => $_content,
  }

}
