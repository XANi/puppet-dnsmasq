# Create an dnsmasq cname record (--cname).
define dnsmasq::cname (
  String[1,255]$hostname,
) {
  include dnsmasq

  concat::fragment { "dnsmasq-cname-${name}":
    order   => '12',
    target  => 'dnsmasq.conf',
    content => template('dnsmasq/cname.erb'),
  }

}
