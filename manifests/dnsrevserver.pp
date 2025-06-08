# Configure the DNS server to query sub domains to external DNS servers
# (--rev-server).
define dnsmasq::dnsrevserver (
  Stdlib::IP::Address $ip,
  $netmask,
  Stdlib::IP::Address $subnet,
  $port = undef,
) {

  $port_real = $port ? {
    undef   => '',
    default => "#${port}",
  }

  include dnsmasq

  concat::fragment { "dnsmasq-dnsserver-${name}":
    order   => '13',
    target  => 'dnsmasq.conf',
    content => template('dnsmasq/dnsrevserver.erb'),
  }
}
