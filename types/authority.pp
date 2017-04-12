# polkit authority types
type Polkit::Authority = Enum[
  'vendor',
  'org',
  'site',
  'local',
  'mandatory',
]
