# == Define: polkit::local_authority
#
# This define allows you to add PolicyKit Local Authority policies to a system.
# See pklocalauthority(8) for information regarding the various options.
#
# Only the default 'authority' directories are currently supported.
#
# == Examples
#
# polkit::local_authority { 'test_policy':
#   identity        => 'unix-group:staff',
#   action          => 'com.example.awesomeproduct.*',
#   result_any      => 'no',
#   result_inactive => 'no',
#   result_active   => 'auth_admin'
# }
#
# == Parameters
#
# [*name*]
#   A descriptive valid filename in which to house your pkla entries. Do not
#   include the leading number or the trailing pkla.
#
# [*identity*]
#   An array of identities as designated by pklocalauthority(8)
#   Single entries may be entered as a string, but a semicolon separated
#   string should NOT be entered here.
#
# [*action*]
#
# [*ensure*]
#   This passes directly down to the file type but only cares if you set it
#   to 'absent'.
#
# [*target_directory*]
#   The destination base directory for your pkla file.
#   Anything may be used, but logical values are:
#     * /etc/polkit-1/localauthority (default)
#     * /var/lib/polkit-1/localauthority
#
# [*authority*]
#   The local authority directory in which to store the pkla file.
#   Supported values are:
#     * vendor
#     * org
#     * site
#     * local
#     * mandatory (default)
#
# [*order*]
#   The 'order' number given to your pkla file. Higher numbers override lower
#   ones in alphabetical/numeric order.
#
# [*section_name*]
#   The section name within the pkla file. Defaults to $name if not set.
#
# [*result_active*]
# [*result_inactive*]
# [*result_any*]
# [*return_value*]
# String
# One of
#     'yes',
#     'no',
#     'auth_self',
#     'auth_self_keep',
#     'auth_admin',
#     'auth_admin_keep'
#
#
# == Authors
#
# * Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
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
  String                  $section_name     = '',
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
  include 'polkit'

  polkit_validate_identity($identity)

  # Make the name safe
  $l_name = regsubst($name,'\/','_')
  $authority_map = {
    'vendor'    => '10-vendor.d',
    'org'       => '20-org.d',
    'site'      => '30-site.d',
    'local'     => '50-local.d',
    'mandatory' => '90-mandatory.d'
  }

  $target_file = "${target_directory}/${authority_map[$authority]}/${l_name}.pkla"

  $authority_map_err_string = join(keys($authority_map),', ')

  $valid_results = [
    'yes',
    'no',
    'auth_self',
    'auth_self_keep',
    'auth_admin',
    'auth_admin_keep'
  ]

  $valid_results_err_string = join($valid_results,', ')

  $_file_ensure = $ensure ? {
    'absent' => 'absent',
    default  => 'file'
  }

  file { $target_file:
    ensure  => $_file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('polkit/local_authority.erb'),
    require => Package['polkit']
  }

  if ! has_key($authority_map, $authority) {
    fail("Authority must be one of '${authority_map_err_string}'")
  }

  if ! ( $result_active or $result_inactive or $result_any ) {
    fail('You must set at least one of "result_active", "result_inactive", or "result_any"')
  }
}
