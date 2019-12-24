# @summary Add a rule file containing javascript Polkit configuration to the system
#
# @param ensure
#   Create or destroy the rules file
#
# @param content
#   An arbitrary string of javascript polkit configuration
#
# @param priority
#   Priority of the file to be created, lower priority means the rule would be read earlier
#
# @param rulesd
#   Location of the poklit rules directory
#
define polkit::authorization::rule (
  Enum['present','absent'] $ensure,
  Optional[String]         $content,
  Integer[0,99]            $priority = 10,
  Stdlib::AbsolutePath     $rulesd   = '/etc/polkit-1/rules.d'
) {

  simplib::assert_metadata($module_name)

  $_name = regsubst($name.downcase, '( |/|!|@|#|\$|%|\^|&|\*|[|])', '_', 'G')

  file { "${rulesd}/${priority}-${_name}.rules":
    ensure  => $ensure,
    content => $content,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
