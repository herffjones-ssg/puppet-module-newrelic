# == Class: newrelic
#
# Full description of class newrelic here.
#
class newrelic (
  $newrelic_license_key = 'f3303ace67c7b1ebdc8f9ba68bcf6ff1f2aaf3f0',
){
    file { "/etc/pki/rpm-gpg/RPM-GPG-KEY-NewRelic":
        owner  => root,
        group  => root,
        mode   => 0644,
        source => "puppet:///modules/newrelic/RPM-GPG-KEY-NewRelic",
        notify => Exec["import_newrelic_key"],
    }

    exec { "import_newrelic_key":
        command => "rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-NewRelic",
        unless  => "rpm -qi gpg-pubkey-548c16bf-4c29a642 | grep -q 'New Relic'",
        path => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
        before  => Package["newrelic-sysmond"],
    }

    package { "newrelic-sysmond":
        ensure  => latest,
        notify  => Exec["newrelic-set-license"],
        require => File["/etc/pki/rpm-gpg/RPM-GPG-KEY-NewRelic"],
    }

    exec { "newrelic-set-license":
        unless  => "egrep -q '^license_key=${newrelic_license_key}$' /etc/newrelic/nrsysmond.cfg",
        command => "nrsysmond-config --set license_key=${newrelic_license_key}",
        path    => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
        require => Package['newrelic-sysmond'],
        notify  => Service['newrelic-sysmond'],
    }

    exec { "newrelic-set-ssl":
        unless  => "egrep -q ^ssl=true$ /etc/newrelic/nrsysmond.cfg",
        command => "nrsysmond-config --set ssl=true",
        path    => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
        require => Package['newrelic-sysmond'],
        notify  => Service['newrelic-sysmond'],
    }

    service { "newrelic-sysmond":
        enable => true,
        ensure => running,
        hasstatus => true,
        hasrestart => true,
        require => Package["newrelic-sysmond"],
    }
}
