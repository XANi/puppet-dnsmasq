# Create an dnsmasq dnsrr record (--dns-rr).
define dnsmasq::dnsrr (
  $domain,
  Pattern[/^[a-fA-F0-9]+$/] $type,
  Pattern[/^[a-fA-F0-0]+$/] $rdata,
) {


  # Remove spaces or colons from rdata for consistency.
  $rdata_real = downcase(regsubst($rdata,'[ :]','','G'))
  include dnsmasq

  concat::fragment { "dnsmasq-dnsrr-${name}":
    order   => '12',
    target  => 'dnsmasq.conf',
    content => template('dnsmasq/dnsrr.erb'),
  }

}
