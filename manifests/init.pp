# Set up PolicyKit
#
# Allows you to set up and manipulate PolicyKit objects
#
# @see http://www.freedesktop.org/software/polkit/docs/latest/ PolicyKit Documentation
#
# @param package_ensure The ensure status of packages
#
# @author Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class polkit (
  Polkit::PackageEnsure $package_ensure = 'installed'
) {
  package { 'polkit':
    ensure => $package_ensure,
  }
}
