* IRCinch 2.4.2, 3 April 2025
  - Improve Gemspec metadata
  - Performance and linting improvements

* IRCinch 2.4.1, 1 April 2025
  - Gemspec updates for compatibility with Ruby >= 3.4.0
  - Minor readme and documentation updates

* IRCinch 2.4.0, 21 November 2022
  - Fork the archived Cinch project as IRCinch
  - Various updates to rename the project to IRCinch without breaking drop-in
    compatibility with Cinch
  - Start separation of positional and keyword arguments for compatibility
    with Ruby >= 3.0

* Cinch 2.3.2, 25 April 2016
  - Fix exception and premature timeouts in DCC send

* Cinch 2.3.1, 01 November 2015
  - Fix logging of exceptions, which was broken by Cinch 2.3.0
  - Fix the accidental removal of hooks. This could lead to hooks
    never executing or being removed under certain conditions. Anyone
    relying on hooks, especially those using them for ACL systems,
    should update to Cinch 2.3.1.

* Cinch 2.3.0, 26 October 2015
  - Add basic support for STATUSMSG messages. These are messages
    directed at voiced or ops in a channel, by sending a message to
    +#channel or @#channel. Cinch will now correctly identify those as
    channel messages. Channel#reply will reply to the same group of
    people, and Channel#statusmsg_mode will contain the mode that was
    addressed.
  - Add support for filtering log messages, allowing to hide passwords
    and other confidential information. See
    http://www.rubydoc.info/gems/cinch/file/docs/logging.md for more
    information.

* Cinch 2.2.8, 23 October 2015
  - Fix WHOIS retry code, don't raise an exception

* Cinch 2.2.7, 28 September 2015
  - Don't replace the letter "z" with spaces when splitting long
    messages

* Cinch 2.2.6, 08 July 2015
  - Better support for Slack
  - Support channel owners on InspIRCd
  - Don't get stuck in a WHOIS forever on certain servers

* Cinch 2.2.5, 30 March 2015
  - Correctly split messages containing multibyte characters
  - Fix User#authname on servers that send both 330 (WHOISACCOUNT) and
    307 (WHOISREGNICK)

* Cinch 2.2.4, 10 Feburary 2015
  - Fix User#away

* Cinch 2.2.3, 10 January 2015
  - Fix processing of RPL_WHOISACCOUNT, broken in 2.2.0

* Cinch 2.2.2, 06 January 2015
  - Do not cause deprecation warnings in our own code

* Cinch 2.2.1, 01 January 2015
  - Fix message of deprecation warning
  - Make sure italic formatting is indeed italic, and not reverse
    video

* Cinch 2.2.0, 31 December 2014
  - Deprecate several methods and aliases:
    - Channel#msg
    - Channel#privmsg
    - Channel#to_str
    - Target#msg
    - Target#privmsg
    - Target#safe_msg
    - Target#safe_privmsg
    - User#whois
    - Helpers.Color
  - Do not strip trailing whitespace in incoming messages
  - Fix handling of rate-limited WHOIS
  - Always send UTF-8 when using "irc" encoding
  - Add Helpers.sanitize
  - Add Formatting.unformat
  - Add Channel#remove
  - Fix (wrong) exceptions in mode parser

* Cinch 2.1.0, 27 Februrary 2014
  - Add User#monitored? and User#synced? as aliases for User#monitored
    and User#synced
  - Add Bot#oper to OPER the bot
  - Add User#oper? to check if a user is an OPER
  - Add Utilities::String.strip_colors
  - New matcher option `strip_colors`
  - Correctly re-apply bot modes on reconnect
  - Do not store duplicated bot modes
  - Add Message#action_reply and Message#safe_action_reply
  - Return started thread from Handler#call
  - Return started threads from HandlerList#dispatch
  - Per group hooks

* Cinch 2.0.12, 30 January 2013
  - Support second optional argument to User#respond_to?

* Cinch 2.0.11, 09 December 2013
  - Unsync authname on nick change
  - Work around bugs in Hector that prevented connecting
  - Update a user's host and username whenever we see it, to avoid
    unnecessary WHOIS calls
  - Correctly handle NOSUCHNICK in WHOIS requests
* Cinch 2.0.10, 03 November 2013
  - Fix registration process for InspIRCd 2.x servers

* Cinch 2.0.9, 02 September 2013
  - Fix support for IPv4 addresses in incoming DCC SEND (2.0.6 broke
    it)

* Cinch 2.0.8, 02 September 2013
  - Correctly expect NAK instead of NACK during client capability
    negotiation
  - Remove all references to the Storage API that has never officially
    been part of Cinch

* Cinch 2.0.7, 29 July 2013
  - Fix regression introduced by 2.0.6 where requesting channel
    attributes would lead to an exception

* Cinch 2.0.6, 26 July 2013
  - Correctly handle empty channel topics
  - Reset bot's channel list on reconnect
  - Fix example plugins that set options
  - Support IPv6 addresses in incoming DCC SEND

* Cinch 2.0.5, 21 June 2013
  - Fix internal handling of AWAY

* Cinch 2.0.4, 05 February 2013
  - Make User#unmonitor more robust
  - Do not unset SASL password after first authentication
  - Improve DCC SEND
    - Do not block when sending ACKs
    - Support spaces in file names
    - Better transfer handling
    - Return value to signal (un)successful file transfers when receiving a transfer
  - Fix PluginList#unregister_all

* Cinch 2.0.3, 27 June 2012
  - Fix monitoring of users
  - Support all types of channels (#, &, !) in Message#channel
  - Make c.delay_joins actually work
  - Don't break when the bot's nick changes
  - Fix User#authed?
  - Do not fire :notice event twice for a single message
  - Do not block on whois requests if a user isn't in any channels

* Cinch 2.0.2, 01 April 2012
  - Correctly mark quitting users as offline
  - Register dynamic timers so they can be unloaded (gh-70)
  - Set bot modes when connecting (gh-71)
  - Support fixnums in Bot#on (gh-72)

* Cinch 2.0.1, 24 March 2012
  - Include .yardopts in gem so documentation gets built correctly

* Cinch 2.0.0, 24 March 2012
  For detailed information check docs/changes.md

* Cinch 1.1.3, 12 May 2011
  - PRIVMSGs can now be matched with the event :privmsg (additionally
    to :message, :private and :channel)
  - Moved execution of the configure block further up the chain, to
    allow setting the logger before any log output is happening

* Cinch 1.1.2, 02 March 2011
  - Fix Mask#match (it was completly unusable in v1.1.0 and later)
  - Fix User#find_ensured (it was completly unusable in v1.1.0 and later; note
    however that this method is deprecated)
  - Fix Channel#has_user? (it was completly unusable in v1.1.0 and later)
  - Support the question mark as a globbing character in ban masks.
    Before, only the asterisk was supported.
  - Fix !help <plugin> – Since v1.1.0 it was not possible to use !help
    if the plugin prefix was not a plain string.
  - Plugin#config will never return nil
  - It is now possible to set the user name of the bot. Before, it was
    identical to the nick.
  - Implement User#respond_to? to match User#method_missing

* Cinch 1.1.1, 18 January 2011
  - Fixed a regression introduced by 1.1.0, which caused Plugin.ctcp
    and thus implementing custom CTCP handlers to break

* Cinch 1.1.0, 15 January 2011
  - New signals
    - :op(<Message>message, <User>target)         – emitted when someone gets opped
    - :deop(<Message>message, <User>target)       – emitted when someone gets deopped
    - :voice(<Message>message, <User>target)      – emitted when someone gets voiced
    - :devoice(<Message>message, <User>target)    – emitted when someone gets devoiced
    - :halfop(<Message>message, <User>target)     – emitted when someone gets half-opped
    - :dehalfop(<Message>message, <User>target)   – emitted when someone gets de-half-opped
    - :ban(<Message>message, <Ban>ban)            – emitted when someone gets banned
    - :unban(<Message>message, <Ban>ban)          – emitted when someone gets unbanned
    - :mode_change(<Message>message, <Array>modes) – emitted on any mode change on a user or channel
    - :catchall(<Message>message)                 – a generic signal that matches any kind of event
  - New methods
    - User#last_nick    – stores the last nick of a user. This can for
      example be used in `on :nick` to compare a user's old nick against
      the new one.
    - User#notice, Channel#notice and Bot#notice – for sending notices
    - Message#to_s      – Provides a nicer representation of Message objects
    - Channel#has_user? – Provides an easier way of checking if a given
      user is in a channel
    - Channel#half_opped? – Check if a user is half-opped
  - Plugins/extensions can send their own events using Bot#dispatch
  - Modes as reported by Channel#users now use mode characters, not prefixes (e.g. "@" becomes "o")
  - Modes reported by Channel#users now are an array of modes, not a string anymore
  - The formatted logger (which is the default one) has been improved
    and now contains timestamps and won't use color codes when not
    writing to a tty. Additionally it can log objects which are not
    strings.
  - A minor bug in the handling of the original IRC casemap has been fixed
  - User#authed? now is synced and won't return a wrong value on the
    first use
  - The string "!help" in the middle of a message won't cause Cinch to
    print help messages anymore
  - Quitting will not cause a deadlock anymore
  - Using a regexp prefix with a string pattern no longer breaks Cinch
  - User and channel caching have been completly rewritten, allowing to
    run multiple bots at once. This deprecates and replaces the
    following methods (syntax: deprecated → substitution):
    - User.find_ensured    → UserManager#find_ensured
    - User.find            → UserManager#find
    - User.all             → UserManager#each
    - Channel.find_ensured → ChannelManager#find_ensured
    - Channel.find         → ChannelManager#find
    - Channel.all          → ChannelManager#each

    Additionally this changes fix a bug where wrong User/Channel objects
    could've been returned.
  - Additionally to prefixes, plugins can now have suffixes
    New option: plugins.suffix
  - Various improvements to the handling of SSL have been made
    - The option 'ssl' now is a set of options, as opposed to a simple boolean switch
      - 'ssl.use' (Boolean) sets if SSL should be used
      - 'ssl.verify' (Boolean) sets if the SSL certificate should be verified
      - 'ssl.ca_path' (String) sets the path to a directory with
        certificates. This has to be set properly for 'ssl.verify' to work.
      - 'ssl.client_cert' (String) allows to set a client certificate,
        which some networks can use for authentication (see
        http://www.oftc.net/oftc/NickServ/CertFP)
  - Instances of Mask can be checked for equality
  - Mask#match has been fixed
  - Timer functionality has been added to plugins
  - A new option 'nicks' has been added which overrules 'nick' and
    allows Cinch to try multiple nicks before appending underscores
  - Proper disconnect and reconnect handling has been added to Cinch
    - Cinch will notice unexpected disconnects
    - New options:
      - timeouts.read    – If no data has been received for X seconds,
        consider the connection dead
      - timeouts.connect – Give up connecting after X seconds
      - ping_interval    – Ping the server every X seconds. This interval
        should be smaller than 'timeouts.read' to prevent Cinch from
        falsely declaring a connection dead
      - reconnect        – If true, try to reconnect after a connection loss
  - pre- and post-execution hooks have been added to the plugin
    architecture
  - A new option 'user_host' has been added, which allows Cinch to
    bind to a specific IP/Host, which is commonly used for using so
    called "vhosts"
  - Added support for RPL_WHOISREGNICK (+r flag on UnrealIRC)
  - Prefixes, suffixes and patterns can now, additionally to strings
    and regexps, also be procs/lambdas, which get executed everytime
    before a message is matched against the pattern. This allows for
    highly dynamic patterns. One possible use case are plugins that
    only respond if the bot was directly addressed.
  - A new encoding called :irc has been added and made the default.
    - If incoming text is valid UTF-8, it will be interpreted as such.
      If it fails validation, a CP1252 -> UTF-8 conversion is
      performed.
    - If your outgoing message contains only characters that fit
      inside the CP1252 code page, the entire message will be sent
      that way. If the text doesn't fit inside the CP1252 code page,
      it will be sent using its original encoding, which should be UTF-8.
    - This hybrid encoding allows Cinch to transparently handle nearly
      all configurations in western countries, even if users in a
      single channel cannot decide on one encoding. The :irc encoding
      exploits the fact that most people either use UTF-8 or CP1252
      (which is nearly identical to ISO-8859-1) and that text encoded
      in CP1252 is not valid in UTF-8.
  - Invalid bytes in incoming messages (e.g. if a wrong encoding has
    been used) will be replaced with question marks (or U+FFFD if
    using UTF-8)

* Cinch 1.0.2, 01 September 2010
  - Left-over debug output has been removed
  - Patterns won't be wrongly modified during registration anymore
  - Using the same internal and external encoding doesn't break Cinch anymore
  - Messages coming from SSL will be properly encoded

* Cinch 1.0.1, 19 August 2010
  - fix several bugs regarding user syncing and unsyncing which cause
    exceptions in the core of Cinch and which don't unsync users who
    quit.

* Cinch 1.0.0, 18 August 2010
  - first stable release of Cinch
