# Validate that all entries are valid PolicyKit identities per
# pkla-check-authorization(8).  Abort catalog compilation if any entry
# fails this check.
# 
Puppet::Functions.create_function(:'polkit::validate_identity') do

  # @param identity Polkit identity; must begin with a 'unix-user:'
  #   or 'unix_group:' header; the value portion can contain a wildcard.
  #   For example, 'unix-user:username' or 'unix-group:mygroup*'
  dispatch :validate_identity do
    required_param 'String', :identity
  end

  # @param identities Array of Polkit identities; each must begin
  #   with a 'unix-user:' or 'unix_group:' header; each value portion
  #   can contain a wildcard.
  dispatch :validate_identities do
    required_param 'Array[String]', :identities
  end

  def validate_identity(identity)
    validate_identities(Array(identity))
  end

  def validate_identities(identities)
    valid_headers = [
        'unix-user',
        'unix-group',
        'unix-netgroup'
    ]

    identities.each do |entry|
      next if entry == 'default'

      header,val = entry.split(':')

      if not valid_headers.include?(header) then
        fail("polkit::validate_identity(): Error, identity specifier '#{header}' must be one of '#{valid_headers.join(', ')}' for entry '#{entry}'")
      end

      valid_name = Regexp.new(/^[A-Za-z0-9_.*-]+$/)
      if not valid_name.match(val) then
        fail("polkit::validate_identity(): Error, value '#{val}' is invalid for entry '#{entry}'")
      end

      if header == 'unix-netgroup' and val.include?('*')
        fail("polkit::validate_identity(): Error, value '#{val}' cannot contain glob for entry '#{entry}'")
      end
    end
  end
end
