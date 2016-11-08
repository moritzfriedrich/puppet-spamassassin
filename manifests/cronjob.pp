# Define: cronjob
# Parameters:
# [*gpghomedir*]
# set the gpghomedir, default could be /var/lib/spamassassin/sa-update-keys
# [*nogpg*]
# enable or disable sa-update argument '--nogpg'
# default: false
# [*channel*]
# set the channel domain
# [*schedule*]
# define the schedule of the cronjob, could be hourly, daily, weekly, monthly
# default: daily
#
define spamassassin::cronjob (
    $gpghomedir = undef,
    $nogpg      = false,
    $channel    = undef,
    $schedule   = 'daily',
    ) {

    if $gpghomedir {
        validate_absolute_path($gpghomedir)
    }

    validate_bool($nogpg)

    if $channel {
        validate_re($channel, '^(([a-zA-Z]{1})|([a-zA-Z]{1}[a-zA-Z]{1})|([a-zA-Z]{1}[0-9]{1})|([0-9]{1}[a-zA-Z]{1})|([a-zA-Z0-9][a-zA-Z0-9-_]{1,61}[a-zA-Z0-9]))\.([a-zA-Z]{2,6}|[a-zA-Z0-9-]{2,30}\.[a-zA-Z]{2,3})$', 'channel should be a valid domain')
    }
    
    validate_re($schedule, '^(hourly|daily|weekly|monthly)$', 'cron parameter must have a value of: hourly, daily, weekly or monthly')

    if !$channel and !$gpghomedir {
        fail('Please define parameter gpghomedir or channel.')
    }

    file { "/etc/cron.${schedule}/spamassassin_${title}":
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template("${module_name}/sa-update.cron.erb")
    }

}
