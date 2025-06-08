# Create an dnsmasq stub zone for caching upstream name resolvers
# (--dhcp-host).
define dnsmasq::dhcpstatic (

  Pattern[/^[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}$/] $mac,
  $ip,
) {
  $mac_real = downcase($mac)

  if !is_ip_address($ip) { fail("Expect IP address for ip, got ${ip}") }
  include dnsmasq

  concat::fragment { "dnsmasq-staticdhcp-${name}":
    order   => '05',
    target  => 'dnsmasq.conf',
    content => template('dnsmasq/dhcpstatic.erb'),
  }

}
