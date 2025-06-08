# Create a dnsmasq A,AAAA and PTR record (--host-record).
define dnsmasq::hostrecord (
   Stdlib::IP::Address $ip,
   Variant[Undef,Stdlib::IP::Address::V6] $ipv6 = undef,
) {

  include dnsmasq

  $ipv6_real = $ipv6 ? {
    undef   => '',
    default => ",${ipv6}",
  }

  concat::fragment { "dnsmasq-hostrecord-${name}":
    order   => '07',
    target  => 'dnsmasq.conf',
    content => template('dnsmasq/hostrecord.erb'),
  }

}
