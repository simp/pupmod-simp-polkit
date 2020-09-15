# @summary Manage the `polkit` user
#
# @param user
#   The user that `polkit` runs as
#
# @param user_options
#   Allows setting of any of the usual puppet `User` resource options. Will
#   have the GID assigned to `/proc` added to the `groups` to preserve proper
#   system functionality.
#
# @param report_proc_issues
#   Actively notify the user about issues with the `hidepid` setting on the
#   `/proc` filesystem
#
# @author https://github.com/simp/pupmod-simp-polkit/graphs/contributors
#
class polkit::user (
  String[1] $user               = 'polkitd',
  Hash      $user_options       = {},
  Boolean   $report_proc_issues = true
){
  assert_private()

  $_proc_mount_group = $facts.dig('simplib__mountpoints', '/proc', 'options_hash', '_gid__group')

  if $_proc_mount_group {
    $_default_user_options = {
      'groups' => ([$_proc_mount_group] + $user_options['groups']).filter |$val| { $val =~ NotUndef }
    }
  }
  else {
    $_default_user_options = {}

    if pick($facts.dig('simplib__mountpoints', '/proc', 'options_hash', 'hidepid'), 0) > 0 {
      if $report_proc_issues {
        $_hidepid_loglevel = 'warning'
      }
      else {
        $_hidepid_loglevel = 'debug'
      }

      class { 'polkit::user::hidepid_notify': log_level => $_hidepid_loglevel }
    }
  }

  if $user_options {
    $_user_options = $user_options.merge($_default_user_options)
  }
  else {
    $_user_options = $_default_user_options
  }

  user { $user: * => $_user_options }
}
