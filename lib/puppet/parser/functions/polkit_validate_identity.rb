module Puppet::Parser::Functions

  newfunction(:polkit_validate_identity, :doc => <<-'ENDHEREDOC') do |args|
    Validate that all entries in the passed array are valid PolicyKit
    identities per pklocalauthority(8).  Abort catalog compilation if any value
    fails this check.

    Multiple strings may be passed as separate entries to the function.

    The following values will pass:

        $my_identities = 'unix-user:username'
        $my_identities = 'unix-group:groupname'
        $my_identities = ['unix-group:groupname','unix-group:group*']
        polkit_validate_identity($my_identities)

    The following values will fail, causing compilation to abort:

        polkit_validate_identity('foo')
        polkit_validate_identity('unix-group:groupname,unix-group:group*')
        polkit_validate_identity('unix-group:groupname;unix-group:group*')

    ENDHEREDOC

    unless args.length > 0 then
      raise Puppet::ParseError, ("validate_string(): wrong number of arguments (#{args.length}; must be > 0)")
    end

    args.each do |arg|
      if not ( arg.is_a?(Array) or arg.is_a?(String) ) then
        raise Puppet::ParseError, ("#{arg.inspect} is not an array or a string.  It looks to be a #{arg.class}")
      end

      valid_headers = [
        'unix-user',
        'unix-group'
      ]

      Array(arg).each do |entry|
        header,val = entry.split(':')

        if not valid_headers.include?(header) then
          raise Puppet::ParseError, ("Identity specifier #{header} must be one of '#{valid_headers.join(', ')}' for entry '#{arg}'")
        end

        valid_name = Regexp.new(/^[A-Za-z0-9_.*-]+$/)
        if not valid_name.match(val) then
          raise Puppet::ParseError, ("Value '#{val}' does not match #{valid_name} for entry '#{arg}'")
        end
      end
    end
  end
end
