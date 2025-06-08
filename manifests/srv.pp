# Create an dnsmasq srv record (--srv-host).
define dnsmasq::srv (
  $hostname,
  Integer $port,
  Integer $priority = 10,
) {

  include dnsmasq

  concat::fragment { "dnsmasq-srv-${name}":
    order   => '09',
    target  => 'dnsmasq.conf',
    content => template('dnsmasq/srv.erb'),
  }

}
