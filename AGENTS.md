# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`simp-polkit` is a SIMP Puppet module that manages **PolicyKit (polkit)** on
Enterprise Linux systems. It installs and enables the `polkit` package/service,
optionally manages the `polkitd` service user, and provides defined types for
adding authorization policies in both the modern JavaScript **rules.d** format
(`polkit::authorization::rule` / `polkit::authorization::basic_policy`) and the
legacy **Local Authority `.pkla`** format (`polkit::local_authority`)
(`metadata.json` `summary`, `manifests/init.pp:1-3`).

The module is **OS-gated and inert by default on unsupported systems.** The main
class and every public defined type wrap their logic in
`simplib::module_metadata::os_supported(load_module_metadata($module_name), {
'release_match' => 'major' })` and do nothing (the class only optionally warns)
when the OS is not in `metadata.json`'s support matrix
(`manifests/init.pp:31-46`, `manifests/local_authority.pp:81`,
`manifests/authorization/basic_policy.pp:94`, `manifests/authorization/rule.pp:22`).

### Business logic

- **`polkit` (`manifests/init.pp:26-47`)** — Public entry class (**not**
  `assert_private()`'d; consumers `include 'polkit'`). Parameters
  (`init.pp:27-29`):
  - `$manage_polkit_user` (`Boolean`, default `true`) — whether to manage the
    `polkitd` user. Enabled by default because newer polkit versions require the
    user to be in the group assigned to `/proc` to function (`init.pp:7-13`).
  - `$package_ensure` (`Polkit::PackageEnsure`) — defaults to
    `simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })`
    (`init.pp:28`).
  - `$warn_on_unsupported_os` (`Boolean`, default `true`) — emit a `warning()`
    (not `fail()`) on an unsupported OS (`init.pp:18-22`, `44-46`).

  Control flow (all guarded by the `os_supported` check, `init.pp:31`):
  - `include polkit::install` and `include polkit::service`, with
    `Class['polkit::install'] ~> Class['polkit::service']` (`init.pp:32-35`).
  - If `$manage_polkit_user`: `include polkit::user`, ordered
    `Class['polkit::install'] -> Class['polkit::user'] ~> Class['polkit::service']`
    (`init.pp:37-42`).
  - Else (unsupported OS + `$warn_on_unsupported_os`): emit a `warning()`
    naming the OS and how to silence it (`init.pp:44-46`).

- **`polkit::install` (`manifests/install.pp:11-18`)** — `assert_private()`'d
  (`install.pp:15`). Manages `package { $package_name }` (default `'polkit'`) at
  `$package_ensure` (defaults to `$polkit::package_ensure`, `install.pp:12-17`).

- **`polkit::service` (`manifests/service.pp:14-27`)** — Public (**not**
  `assert_private()`'d; it instead calls `simplib::assert_metadata($module_name)`
  at `service.pp:19`). Manages `service { $service_name }` (default `'polkit'`)
  `ensure => running`, `enable => true`, `hasrestart`/`hasstatus => true`
  (`service.pp:15-26`).

- **`polkit::user` (`manifests/user.pp:17-53`)** — `assert_private()`'d
  (`user.pp:22`). Manages the `polkitd` user. Reads the `/proc` mount's group
  from the `simplib__mountpoints` fact
  (`$facts.dig('simplib__mountpoints', '/proc', 'options_hash', '_gid__group')`,
  `user.pp:24`):
  - If the `/proc` group is set, it is prepended to the user's `groups`
    (`user.pp:26-30`).
  - Else, if `/proc` is mounted with `hidepid > 0`, it declares
    `polkit::user::hidepid_notify` at `warning` or `debug` level depending on
    `$report_proc_issues` (`user.pp:31-44`).
  - Declares `user { $user: * => $_user_options }` via the splat operator
    (`user.pp:53`).

- **`polkit::user::hidepid_notify` (`manifests/user/hidepid_notify.pp:10-24`)** —
  `assert_private()`'d (`hidepid_notify.pp:13`). Split into its own class purely
  for notification-chaining correctness (`hidepid_notify.pp:3`). Emits a `notify`
  at `$log_level` warning that `/proc` needs a `gid` option when `hidepid > 0`
  (`hidepid_notify.pp:15-23`).

- **`polkit::local_authority` (`manifests/local_authority.pp:66-116`)** — Public
  defined type. Writes a legacy `.pkla` file. Requires at least one of
  `$result_active` / `$result_inactive` / `$result_any`, else `fail()`
  (`local_authority.pp:89-91`). Maps the `$authority` enum to a numbered
  directory (`vendor`→`10-vendor.d` … `mandatory`→`90-mandatory.d`,
  `local_authority.pp:93-99`), validates `$identity` via
  `polkit::validate_identity()` (`local_authority.pp:84`), and manages a
  `file` rendered from `templates/local_authority.erb`, `require => Package['polkit']`
  (`local_authority.pp:108-115`).

- **`polkit::authorization::rule` (`manifests/authorization/rule.pp:15-34`)** —
  Public defined type. Low-level: writes an arbitrary `$content` string to
  `${rulesd}/${priority}-${sanitized_name}.rules` (default rulesd
  `/etc/polkit-1/rules.d`). The name is downcased and non-alphanumerics are
  replaced with `_` (`rule.pp:25-33`).

- **`polkit::authorization::basic_policy`
  (`manifests/authorization/basic_policy.pp:79-109`)** — Public defined type.
  A convenience wrapper that renders `templates/basic_policy.erb` (which builds
  the JavaScript condition from `$action_id` / `$user` / `$group` / `$local` /
  `$active`, or uses a supplied `$condition`) and hands the result to
  `polkit::authorization::rule` (`basic_policy.pp:103-108`). If no `$condition`
  is given, `$action_id` is required, else `fail()` (`basic_policy.pp:97-101`).

### Gotchas / non-obvious details

- **The module is inert, not failing, on unsupported OSes.** The main class and
  all three public defined types wrap their logic in the `os_supported` check
  and simply do nothing on an unsupported OS (`init.pp:31,44`,
  `local_authority.pp:81`, `basic_policy.pp:94`, `rule.pp:22`). The comment
  "this defined type is inert if called from an unsupported OS" appears verbatim
  in each define. This is deliberate backwards compatibility.
- **`polkit::service` is public but is the class that asserts metadata.** It is
  the one class calling `simplib::assert_metadata($module_name)` (`service.pp:19`),
  not the entry class. `polkit::install`, `polkit::user`, and
  `polkit::user::hidepid_notify` are the only `assert_private()`'d classes.
- **`$manage_polkit_user` defaults to `true` for a reason.** Newer polkit needs
  `polkitd` in the `/proc` group; the module wires the group in from the
  `simplib__mountpoints` fact (`init.pp:7-13`, `user.pp:24-30`).
- **The hidepid warning only fires under specific conditions** — `/proc` mounted
  with `hidepid > 0` **and** no `_gid__group` set (`user.pp:31-44`,
  `hidepid_notify.pp:15`). The check is duplicated in both `polkit::user` and
  `polkit::user::hidepid_notify`.
- **`polkit::validate_identity` accepts `unix-netgroup` but the type/docstrings
  advertise fewer.** The Ruby function's valid headers are `unix-user`,
  `unix-group`, `unix-netgroup`, plus the literal `default`; netgroups may not
  contain a glob (`lib/puppet/functions/polkit/validate_identity.rb:29-51`). The
  local_authority docstring only mentions user/group (`local_authority.pp:22-26`).
- **The `basic_policy` docstring references a `polkit::condition` function that
  does not exist.** `basic_policy.pp:19` says the define "can use the
  polkit::condition function to generate a condition", but no such function is
  present in `lib/` — the condition is actually built inline inside
  `templates/basic_policy.erb`. Treat the docstring as stale.
- **`simp/simp_options` is NOT a declared dependency** in `metadata.json`, yet
  the manifest consumes the `simp_options::*` seam via `simplib::lookup`
  (provided by `simp/simplib`). `simp_options` does not even appear in
  `.fixtures.yml` — only `simplib` and `stdlib` are checked out.
- **Acceptance runs in CI under podman/docker.**
  `spec/acceptance/suites/default/` has beaker specs, and
  `.github/workflows/pr_tests.yml` runs them in an `acceptance` job over
  `docker_*` nodesets (see Repository layout).

## The `simp_options` / `simplib::lookup` seam

This is the module's SIMP configuration seam. There is exactly one such call:

| Line | Key | `default_value` |
|------|-----|-----------------|
| `init.pp:28` | `simp_options::package_ensure` | `'installed'` |

`polkit::install::package_ensure` and `polkit::service::ensure` do **not** call
the seam directly — `install` inherits `$polkit::package_ensure` (`install.pp:13`),
and `service::ensure` hard-defaults to `'running'` (`service.pp:15`). Keep
routing SIMP feature toggles through `simplib::lookup('simp_options::*', {
'default_value' => ... })` with an explicit default rather than assuming
`simp_options` is included.

## Dependencies

Module dependencies (from `metadata.json` `dependencies`):

- `puppetlabs/stdlib` `>= 8.0.0 < 10.0.0` (provides `Stdlib::Absolutepath`,
  string helpers).
- `simp/simplib` `>= 4.9.0 < 6.0.0` (provides `simplib::lookup`,
  `simplib::assert_metadata`, `simplib::module_metadata::os_supported`, and the
  `simplib__mountpoints` fact).

There is **no** `simp.optional_dependencies` key in `metadata.json`.

Fixture-only dependencies (from `.fixtures.yml`, present for test compilation,
not runtime deps): `simplib`, `stdlib` (the runtime deps above; nothing else).

Runtime requirement (from `metadata.json` `requirements`): `openvox
>= 8.0.0 < 9.0.0`.

Supported OS matrix (from `metadata.json` `operatingsystem_support`): CentOS
9/10; RedHat 8/9/10; OracleLinux 8/9/10; Rocky 8/9/10; AlmaLinux 8/9/10.

## Repository layout

- `manifests/init.pp` — the `polkit` entry class (OS gate + install/service/user
  wiring).
- `manifests/install.pp` — private `polkit::install` (the `polkit` package).
- `manifests/service.pp` — public `polkit::service` (the `polkit` service; calls
  `assert_metadata`).
- `manifests/user.pp` — private `polkit::user` (the `polkitd` user + `/proc`
  group logic).
- `manifests/user/hidepid_notify.pp` — private `polkit::user::hidepid_notify`
  (hidepid warning, split out for chaining).
- `manifests/local_authority.pp` — public define writing legacy `.pkla` files.
- `manifests/authorization/rule.pp` — public define writing raw `.rules` files.
- `manifests/authorization/basic_policy.pp` — public define wrapping `rule` with
  a generated JS condition.
- `types/authority.pp` — `Polkit::Authority` enum (vendor/org/site/local/mandatory).
- `types/packageensure.pp` — `Polkit::PackageEnsure` (String or ensure enum).
- `types/result.pp` — `Polkit::Result` (optional polkit result enum).
- `lib/puppet/functions/polkit/validate_identity.rb` — Ruby function validating
  polkit identity strings.
- `templates/local_authority.erb` — renders `.pkla` content.
- `templates/basic_policy.erb` — renders the JS rule + builds the condition.
- `metadata.json` — deps, OS matrix, OpenVox requirement (no optional deps, no
  `data`).
- `spec/classes/{init,user}_spec.rb`,
  `spec/defines/{local_authority,authorization/basic_policy,authorization/rule}_spec.rb`,
  `spec/functions/polkit/validate_identity_spec.rb` — rspec-puppet unit tests.
- `spec/acceptance/suites/default/{00_default,10_proc_hidepid}_spec.rb` — beaker
  acceptance specs; `spec/acceptance/nodesets/` ships both `docker_*` and
  vagrant nodesets (`almalinux`/`centos`/`oel`/`rhel`/`rocky` 8/9/10).
- `REFERENCE.md` — generated Puppet Strings reference.
- **No `data/` or `hiera.yaml`** — this module ships no module data; parameter
  defaults live in the manifests and in `metadata.json`.
- **Acceptance runs in CI:** `.github/workflows/pr_tests.yml` has an
  `acceptance` job (`pr_tests.yml:116-154`) alongside `puppet-syntax`,
  `puppet-style`, `ruby-style`, `file-checks`, `releng-checks`, and
  `spec-tests` (matrix over Puppet/Ruby versions). Its matrix nodes are
  `docker_alma8/9/10`, `docker_centos9/10`, `docker_oel8/9/10`,
  `docker_rhel8/9`, and `docker_rocky8/9/10`. It starts `podman.socket`,
  exports `DOCKER_HOST`, and runs `bundle exec rake beaker:suites[default,<node>]`
  with `BEAKER_HYPERVISOR=docker` (`pr_tests.yml:152`).

## Common commands

```sh
# Install dependencies
bundle install

# Run all unit tests
bundle exec rake spec

# Run a single spec
bundle exec rspec spec/classes/init_spec.rb

# Puppet lint
bundle exec rake lint

# Ruby lint
bundle exec rake rubocop

# Regenerate REFERENCE.md from puppet-strings docstrings
puppet strings generate --format markdown --out REFERENCE.md

# Run the default beaker acceptance suite (CI runs the docker_* nodes)
bundle exec rake beaker:suites[default]
```

Relevant gem pins (from `Gemfile`): `puppetlabs_spec_helper ~> 8.0.0`,
`simp-rake-helpers ~> 5.24.0`, `simp-rspec-puppet-facts ~> 4.0.0`,
`simp-beaker-helpers ~> 2.0.0`. Rubocop is pinned to `~> 1.88.0`. The test group
installs both `openvox` and `puppet` gems, defaulting to the `>= 8 < 9` range.
`spec/spec_helper.rb` requires `puppetlabs_spec_helper/module_spec_helper` and
`simp/rspec-puppet-facts` (`spec/spec_helper.rb:11,13`).

## Conventions

- Preserve the `@summary` / `@param` puppet-strings docstrings on classes,
  defines, types, and the Ruby function — they drive `REFERENCE.md`. Regenerate
  `REFERENCE.md` after changing docs or parameters.
- Keep every public entry point **OS-gated** with
  `simplib::module_metadata::os_supported(load_module_metadata($module_name), {
  'release_match' => 'major' })` — the module is inert (not failing) on
  unsupported OSes, and callers rely on that.
- Continue routing SIMP feature toggles through
  `simplib::lookup('simp_options::*', { 'default_value' => ... })` rather than
  assuming `simp_options` is included.
- Keep private helper classes (`install`, `user`, `hidepid_notify`)
  `assert_private()`'d; the public seam is `polkit`, `polkit::service`, and the
  three defined types.
- `Gemfile`, `spec/spec_helper.rb`, and `.github/workflows/pr_tests.yml` carry a
  **puppetsync** notice — they are baseline-managed and the next sync overwrites
  local edits. Push changes to those files upstream to the baseline, not here.
- Match the existing 2-space Puppet indentation and aligned-arrow parameter
  style used in `manifests/`.
