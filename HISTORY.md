# master

### Added
 * Servers can now listen on all hosts or localhost via the command-line options -a / --listen-on-all-hosts or -l / --listen-on-localhost.  The default is to listen on localhost.


### Changed
 * Behaviors receive their parameters through their constructors instead of being passed via the serve method.  That is,
  the serve(io, options) method has been changed to serve(io).  Behaviors that need to accept user-specified parameters
  should accept them via constructor arguments, and should provide a default version since the command-line interface
  does not specify options.  e.g.
    class MyBehavior
      def initialize(options = {})
      ...
* BehaviorServer no longer accepts options; instead these are created with the Behavior objects.


### Removed


