# Set up PolicyKit
#
# Allows you to set up and manipulate PolicyKit objects
#
# @see http://www.freedesktop.org/software/polkit/docs/latest/ PolicyKit Documentation
#
# @author Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class polkit {
  package { 'polkit':
    ensure => 'latest'
  }
}
