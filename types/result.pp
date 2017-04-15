# Polkit result types
type Polkit::Result = Optional[
  Enum[
    'yes',
    'no',
    'auth_self',
    'auth_self_keep',
    'auth_admin',
    'auth_admin_keep',
  ]
]
