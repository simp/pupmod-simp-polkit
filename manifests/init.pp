# @summary Set up PolicyKit
#
# Allows you to set up and manipulate PolicyKit objects
#
# @see http://www.freedesktop.org/software/polkit/docs/latest/ PolicyKit Documentation
#
# @param manage_polkit_user
#   Enables managment of the `$polkit_user`
#
#   * Enabled by default since newer versions of polkit require the
#     `$polkit_user` to be in the group assigned to /proc to function properly
#
#   @see `polkit::user`
#
# @param package_ensure
#   The ensure status of packages
#
# @author https://github.com/simp/pupmod-simp-polkit/graphs/contributors
#
class polkit (
  Boolean               $manage_polkit_user = true,
  Polkit::PackageEnsure $package_ensure     = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
){
  simplib::assert_metadata($module_name)

  include polkit::install
  include polkit::service

  Class['polkit::install'] ~> Class['polkit::service']

  if $manage_polkit_user {
    include polkit::user

    Class['polkit::install'] -> Class['polkit::user']
    Class['polkit::user'] ~> Class['polkit::service']
  }
}
