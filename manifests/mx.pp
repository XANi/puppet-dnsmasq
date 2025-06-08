# Create an dnsmasq mx record (--mx-host).
define dnsmasq::mx (
  # allow for duplicate "mx-host=<name>,..." entries
  $mx_name = $name,
  $hostname = undef,
  Variant[Undef,String['^[0-9]+$'] $preference = undef,
) {
  include dnsmasq

  $hostname_real = $hostname ? {
    undef   => '',
    default => ",${hostname}",
  }

  $preference_real = $preference ? {
    undef   => '',
    default => ",${preference}",
  }

  concat::fragment { "dnsmasq-mx-${name}":
    # prevent "reordering" changes
    order   => "08_${mx_name}_${hostname_real}_${preference_real}",
    target  => 'dnsmasq.conf',
    content => template('dnsmasq/mx.erb'),
  }

}
