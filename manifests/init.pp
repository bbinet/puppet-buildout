# Class: buildout
#
# This module manages buildout and provides a define for setting up buildout
# environments.
#
class buildout {

    package { "python": }

    # Definition: buildout::venv
    #
    # setup buildout virtual python environment
    #
    # Parameters:
    #   $source  - source from which to grab buildout.cfg
    #   $python  - the python interpreter to use
    #   $ensure  - flag to setup or remove the buildout environment
    #
    # Actions:
    #   setup buildout virtual python environment
    #
    # Requires:
    #   $source must be set
    #
    # Sample Usage:
    #
    #    buildout::venv { "/path/to/buildout_env":
    #        source => "puppet:///files/mybuildout.cfg",
    #        python => "/path/to/your/python",
    #    }
    #
    define venv($source, $python='python', $ensure=present) {
        if $ensure == present {
            exec { "mkdir -p $name":
                unless => "test -d $name",
            }
            file { "$name/bootstrap.py":
                source => "puppet:///modules/buildout/bootstrap.py",
                require => Exec["mkdir -p $name"],
            }
            file { "$name/buildout.cfg":
                source => $source,
                require => Exec["mkdir -p $name"],
            }
            exec { "${python} $name/bootstrap.py":
                cwd => $name,
                require => [File["$name/bootstrap.py"], File["$name/buildout.cfg"]],
                unless => "test -f $name/bin/buildout",
            }
            exec { "$name/bin/buildout":
                cwd => $name,
                require => Exec["${python} $name/bootstrap.py"],
                subscribe => File["$name/buildout.cfg"],
                refreshonly => true,
            }
        } else {
            file { "$name":
                ensure => absent,
                force => true,
            }
        }
    }
}
