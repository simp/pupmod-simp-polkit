# Add PolicyKit Local Authority policies to a system
#
# Only the default ``authority`` directories are currently supported
#
# @see pklocalauthority(8)
#
# @example Local Test Policy
#   polkit::local_authority { 'test_policy':
#     identity        => 'unix-group:staff',
#     action          => 'com.example.awesomeproduct.*',
#     result_any      => 'no',
#     result_inactive => 'no',
#     result_active   => 'auth_admin'
#   }
#
# @param name
#   A descriptive, valid **filename** (not path) in which to house your pkla entries
#
#   * Do not include the leading number or the trailing ``.pkla``
#
# @param identity
#   Identities as designated by ``pklocalauthority(8)``
#
#   Single entries may be entered as a string, but a semicolon separated string
#   should **NOT** be entered here.
#
# @param action
#
# @param ensure
#   This passes directly down to the file type but only cares if you set it to
#   ``absent``
#
# @param target_directory
#   The destination base directory for your ``pkla`` file
#
#   * Anything may be used, but logical values are:
#       * ``/etc/polkit-1/localauthority``
#       * ``/var/lib/polkit-1/localauthority``
#
# @param authority
#   The local authority directory in which to store the pkla file
#
#   Supported values are:
#     * local
#     * mandatory
#     * org
#     * site
#     * vendor
#
# @param order
#   The ``order`` number given to your ``pkla`` file
#
#   * Higher numbers override lower ones in alphanumeric order
#
# @param section_name
#   The section name within the ``pkla`` file
#
# @param result_active
# @param result_inactive
# @param result_any
# @param return_value
#
# @author Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
define polkit::local_authority (
  Variant[String,
          Array[String]]  $identity,
  String                  $action,
  Enum['present',
       'absent',
       'file',
       'directory',
       'link']            $ensure           = 'present',
  Stdlib::Absolutepath    $target_directory = '/etc/polkit-1/localauthority',
  Enum['vendor',
       'org',
       'site',
       'local',
       'mandatory']       $authority        = 'mandatory',
  Integer                 $order            = 50,
  String                  $section_name     = $name,
  Optional[Enum['yes',
    'no',
    'auth_self',
    'auth_self_keep',
    'auth_admin',
    'auth_admin_keep']]   $result_active    = undef,
  Optional[Enum['yes',
    'no',
    'auth_self',
    'auth_self_keep',
    'auth_admin',
    'auth_admin_keep']]   $result_inactive  = undef,
  Optional[Enum['yes',
    'no',
    'auth_self',
    'auth_self_keep',
    'auth_admin',
    'auth_admin_keep']]   $result_any       = undef,
  Optional[Enum['yes',
    'no',
    'auth_self',
    'auth_self_keep',
    'auth_admin',
    'auth_admin_keep']]   $return_value     = undef
) {
  include '::polkit'

  polkit_validate_identity($identity)

  # Make the name safe
  $_name = regsubst($name,'\/','_')

  if !( $result_active or $result_inactive or $result_any ) {
    fail('You must set at least one of "result_active", "result_inactive", or "result_any"')
  }

  $authority_map = {
    'vendor'    => '10-vendor.d',
    'org'       => '20-org.d',
    'site'      => '30-site.d',
    'local'     => '50-local.d',
    'mandatory' => '90-mandatory.d'
  }

  $target_file = "${target_directory}/${authority_map[$authority]}/${_name}.pkla"

  $_file_ensure = $ensure ? {
    'absent' => 'absent',
    default  => 'file'
  }

  file { $target_file:
    ensure  => $_file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/local_authority.erb"),
    require => Package['polkit']
  }
}
