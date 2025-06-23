# @summary A notification for hidepid user creation
#
# This was moved into a separate class for resource notification chaining correctness
#
# @param log_level
#   The log level to use when generating the notification message
#
# @author https://github.com/simp/pupmod-simp-polkit/graphs/contributors
#
class polkit::user::hidepid_notify (
  String $log_level = 'warning'
) {
  assert_private()

  if Integer(pick($facts.dig('simplib__mountpoints', '/proc', 'options_hash', 'hidepid'), 0)) > 0 {
    notify { "${module_name}::user - hidepid warning":
      loglevel => $log_level,
      message  => @("HIDEPID_WARNING")
        The "gid" option on "/proc" must be set if "hidepid" > 0.
        Set '${module_name}::user::report_proc_issues = false' to hide this message.
        | - HIDEPID_WARNING
    }
  }
}
