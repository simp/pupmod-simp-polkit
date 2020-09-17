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
# @param warn_on_unsupported_os
#   Warn if the module is trying to be used on an unsupported OS
#
#   * The module will not fail on an unsupported OS but also will not perform
#     any action
#
# @author https://github.com/simp/pupmod-simp-polkit/graphs/contributors
#
class polkit (
  Boolean               $manage_polkit_user     = true,
  Polkit::PackageEnsure $package_ensure         = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),
  Boolean               $warn_on_unsupported_os = true
){
  if simplib::module_metadata::os_supported( load_module_metadata($module_name), { 'release_match' => 'major' }) {
    include polkit::install
    include polkit::service

    Class['polkit::install'] ~> Class['polkit::service']

    if $manage_polkit_user {
      include polkit::user

      Class['polkit::install'] -> Class['polkit::user']
      Class['polkit::user'] ~> Class['polkit::service']
    }
  }
  elsif $warn_on_unsupported_os {
    warning("${facts['os']['name']} ${facts['os']['release']['full']} is not supported by ${module_name}. To silence this warning, set ${module_name}::warn_on_unsupported_os to 'false'")
  }
}
