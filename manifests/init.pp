# Primary class with options.  See documentation at
# http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html
class dnsmasq (
  $auth_sec_servers         = undef,
  $auth_server              = undef,
  $auth_ttl                 = undef,
  $auth_zone                = undef,
  Boolean $bogus_priv               = true,
  $cache_size               = 1000,
  Hash $config_hash         = {},
  $dhcp_boot                = undef,
  $dhcp_leasefile           = undef,
  Boolean $dhcp_no_override         = false,
  $domain                   = undef,
  Boolean $domain_needed            = true,
  $dns_forward_max          = undef,
  $dnsmasq_confdir          = $dnsmasq::params::dnsmasq_confdir,
  $dnsmasq_conffile         = $dnsmasq::params::dnsmasq_conffile,
  $dnsmasq_hasstatus        = $dnsmasq::params::dnsmasq_hasstatus,
  $dnsmasq_logdir           = $dnsmasq::params::dnsmasq_logdir,
  $dnsmasq_package          = $dnsmasq::params::dnsmasq_package,
  $dnsmasq_package_provider = $dnsmasq::params::dnsmasq_package_provider,
  $dnsmasq_service          = $dnsmasq::params::dnsmasq_service,
  Boolean $enable_tftp              = false,
  Boolean $expand_hosts             = true,
  $interface                = undef,
  Variant[Undef,Stdlib::IP::Address] $listen_address           = undef,
  Variant[Undef,Integer[0]] $local_ttl                = undef,
  Boolean $manage_tftp_root         = false,
  Variant[Undef,Integer[0]] $max_ttl                  = undef,
  Variant[Undef,Integer[0]] $max_cache_ttl            = undef,
  Variant[Undef,Integer[0]] $neg_ttl                  = undef,
  $no_dhcp_interface        = undef,
  Boolean $no_hosts                 = false,
  Boolean $no_negcache              = false,
  Boolean $no_resolv                = false,
  $port                     = '53',
  Boolean $read_ethers              = false,
  Boolean $reload_resolvconf        = true,
  Boolean $resolv_file              = false,
  Boolean $restart                  = true,
  $run_as_user              = undef,
  Boolean $save_config_file         = true,
  Boolean $service_enable           = true,
  Pattern[/^(running|stopped)/]  $service_ensure           = 'running',
  Boolean $strict_order             = true,
  $tftp_root                = '/var/lib/tftpboot',
) inherits dnsmasq::params {

  ## VALIDATION

  ## CLASS VARIABLES

  # Allow custom ::provider fact to override our provider, but only
  # if it is undef.
  $provider_real = empty($::provider) ? {
    true    => $dnsmasq_package_provider ? {
      undef   => $::provider,
      default => $dnsmasq_package_provider,
    },
    default => $dnsmasq_package_provider,
  }

  ## MANAGED RESOURCES

  concat { 'dnsmasq.conf':
    path    => $dnsmasq_conffile,
    warn    => true,
    require => Package['dnsmasq'],
  }

  concat::fragment { 'dnsmasq-header':
    order   => '00',
    target  => 'dnsmasq.conf',
    content => template('dnsmasq/dnsmasq.conf.erb'),
  }

  package { 'dnsmasq':
    ensure   => installed,
    name     => $dnsmasq_package,
    provider => $provider_real,
    before   => Service['dnsmasq'],
  }

  service { 'dnsmasq':
    ensure    => $service_ensure,
    name      => $dnsmasq_service,
    enable    => $service_enable,
    hasstatus => $dnsmasq_hasstatus,
  }

  if $restart {
    Concat['dnsmasq.conf'] ~> Service['dnsmasq']
  }

  if $dnsmasq_confdir {
    file { $dnsmasq_confdir:
      ensure => 'directory',
      owner  => 0,
      group  => 0,
      mode   => '0755',
    }
  }

  if $save_config_file {
    # let's save the commented default config file after installation.
    exec { 'save_config_file':
      command => "cp ${dnsmasq_conffile} ${dnsmasq_conffile}.orig",
      creates => "${dnsmasq_conffile}.orig",
      path    => [ '/usr/bin', '/usr/sbin', '/bin', '/sbin', ],
      require => Package['dnsmasq'],
      before  => Concat['dnsmasq.conf'],
    }
  }

  if $reload_resolvconf {
    exec { 'reload_resolvconf':
      provider => shell,
      command  => '/sbin/resolvconf -u',
      path     => [ '/usr/bin', '/usr/sbin', '/bin', '/sbin', ],
      user     => root,
      onlyif   => 'test -f /sbin/resolvconf',
      before   => Service['dnsmasq'],
      require  => Package['dnsmasq'],
    }
  }

  if $manage_tftp_root {
    file { $tftp_root:
      ensure => directory,
      owner  => 0,
      group  => 0,
      mode   => '0644',
      before => Service['dnsmasq'],
    }
  }

  if ! $no_hosts {
    Host <||> {
      notify +> Service['dnsmasq'],
    }
  }
}

