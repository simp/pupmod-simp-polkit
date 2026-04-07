# @summary Ensure that the polkit service is running
#
# @param ensure
#   `ensure` state from the service resource
#
# @param enable
#   `enable` state from the service resource
#
# @param service_name
#   The `name` of the service to manage
#
# @author https://github.com/simp/pupmod-simp-polkit/graphs/contributors
#
class polkit::service (
  Variant[String[1],Boolean] $ensure       = 'running',
  Boolean                    $enable       = true,
  String[1]                  $service_name = 'polkit'
) {
  service { $service_name:
    ensure     => $ensure,
    enable     => $enable,
    hasrestart => true,
    hasstatus  => true
  }
}
