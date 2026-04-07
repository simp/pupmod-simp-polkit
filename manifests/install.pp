# @summary Manage the polkit package
#
# @param package_name
#   The name of the package to manage
#
# @param package_ensure
#   `ensure` state from the service resource
#
# @author https://github.com/simp/pupmod-simp-polkit/graphs/contributors
#
class polkit::install (
  String[1]                  $package_name   = 'polkit',
  Variant[String[1],Boolean] $package_ensure = $polkit::package_ensure
) {
  assert_private()

  package { $package_name: ensure => $package_ensure }
}
