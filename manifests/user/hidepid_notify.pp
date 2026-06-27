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
  $log_level = 'warning'
){
  assert_private()

  # The 'hidepid' mount option may be reported by the kernel as either an
  # Integer (e.g. 2) or, on newer kernels, a normalized String
  # (e.g. 'invisible', 'noaccess', 'ptraceable'). Treat anything other than
  # the "disabled" values (0 / 'off') as enabled.
  $_hidepid = pick($facts.dig('simplib__mountpoints', '/proc', 'options_hash', 'hidepid'), 0)
  $_hidepid_enabled = $_hidepid ? {
    Integer => $_hidepid > 0,
    default => !($_hidepid in ['0', 'off']),
  }

  if $_hidepid_enabled {
    notify { "${module_name}::user - hidepid warning":
      loglevel => $log_level,
      message  => @("HIDEPID_WARNING")
        The "gid" option on "/proc" must be set if "hidepid" > 0.
        Set '${module_name}::user::report_proc_issues = false' to hide this message.
        | - HIDEPID_WARNING
    }
  }
}
