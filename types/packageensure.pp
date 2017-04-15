# Package ensure type
type Polkit::PackageEnsure = Variant[
  String,
  Enum[
    'latest',
    'installed',
    'absent',
    'purged'
  ]
]
