# force.pp
# force a package from a specific release

define apt::force(
  $release      = 'testing',
  $version      = false,
  $cfg_files    = undef,
  $cfg_missing  = undef,
) {

  $config_files = $cfg_files ? {
    'new'       => '-o Dpkg::Options::="--force-confnew"',
    'old'       => '-o Dpkg::Options::="--force-confold"',
    'unchanged' => '-o Dpkg::Options::="--force-confdef"',
    default     => '',
  }

  $config_missing = $cfg_missing ? {
    true    => '-o Dpkg::Options::="--force-confmiss"',
    default => '',
  }

  $version_string = $version ? {
    false   => undef,
    default => "=${version}",
  }

  $install_check = $version ? {
    false   => "/usr/bin/dpkg -s ${name} | grep -q 'Status: install'",
    default => "/usr/bin/dpkg -s ${name} | grep -q 'Version: ${version}'",
  }
  exec { "/usr/bin/aptitude -y ${config_files} ${config_missing} -t ${release} install ${name}${version_string}":
    unless => $install_check,
  }

}
