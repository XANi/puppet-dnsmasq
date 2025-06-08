# Create a dnsmasq A record (--address).
define dnsmasq::address (
  Stdlib::IP::Address $ip,
) {

  include dnsmasq

  concat::fragment { "dnsmasq-staticdns-${name}":
    order   => "07_${name}",
    target  => 'dnsmasq.conf',
    content => template('dnsmasq/address.erb'),
  }

}
