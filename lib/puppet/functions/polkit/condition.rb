# Generate a condition for a policykit rule
Puppet::Functions.create_function(:'polkit::condition') do
  dispatch :condition do
    param 'String', :action_id
    param "Struct[{
      Optional[group]  => Optional[String],
      Optional[user]   => Optional[String],
      Optional[local]  => Boolean,
      Optional[active] => Boolean,
    }]", :opts

    return_type 'String'
  end

  def condition(action_id, opts)
    cond = []
    cond << "(action.id == '#{action_id}')"
    cond << "subject.user == '#{opts['user']}'"     if opts['user']
    cond << "subject.isInGroup('#{opts['group']}')" if opts['group']
    cond << 'subject.local'                         if opts['local']
    cond << 'subject.active'                        if opts['active']
    cond.join(' && ')
  end
end
