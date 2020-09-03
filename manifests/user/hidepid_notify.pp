# @summary A notification for hidepid user creation
#
# This was moved into a separate class for resource notification chaining correctness
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
class polkit::user::hidepid_notify (
  $log_level = 'warning'
){
  assert_private()

  if pick($facts.dig('simplib__mountpoints', '/proc', 'options_hash', 'hidepid'), 0) > 0 {
    notify { "${module_name}::user - hidepid warning":
      loglevel => $log_level,
      message  => @("HIDEPID_WARNING")
        The "gid" option on "/proc" must be set if "hidepid" > 0.
        Set '${module_name}::user::report_proc_issues = false' to hide this message.
        | - HIDEPID_WARNING
    }
  }
}
