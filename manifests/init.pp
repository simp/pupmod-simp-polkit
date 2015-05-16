# == Class: polkit
#
# Set up polkit.
#
# Allows you to set up and manipulate PolicyKit objects. See the PolicyKit
# documentation for details.
# http://www.freedesktop.org/software/polkit/docs/latest/
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class polkit {
  package { 'polkit':
    ensure => 'latest'
  }
}
