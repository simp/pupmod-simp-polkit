# Generate a condition for a policykit rule
Puppet::Functions.create_function(:'polkit::condition') do
  dispatch :condition do
    param 'String', :action_id
    param "Struct[{
      Optional[group]  => Optional[Variant[String,Array[String]]],
      Optional[user]   => Optional[Variant[String,Array[String]]],
      Optional[local]  => Boolean,
      Optional[active] => Boolean,
    }]", :opts

    return_type 'String'
  end

  def condition(action_id, opts)
    cond = []
    cond << "(action.id == '#{action_id}')"
    cond << 'subject.local'                         if opts['local']
    cond << 'subject.active'                        if opts['active']

    if opts['user'].is_a?(Array)
      opts['user'].each { |u| cond << "subject.user == '#{u}'" }
    else
      cond << "subject.user == '#{opts['user']}'" if opts['user']
    end

    if opts['group'].is_a?(Array)
      opts['group'].each { |g| cond << "subject.isInGroup('#{g}')" }
    else
      cond << "subject.isInGroup('#{opts['group']}')" if opts['group']
    end

    cond.join(' && ')
  end
end
