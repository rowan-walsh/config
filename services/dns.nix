{config, ...}: {
  # Use unbound as a recursive DNS resolver
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = "127.0.0.1";
        port = 5335;
        access-control = [
          "127.0.0.1/32 allow"
        ];
        # Security
        hide-identity = true; # Don't reveal server identity
        hide-version = true; # Don't reveal server version
        private-address = [
          "192.168.0.0/16"
          "169.254.0.0/16"
          "172.16.0.0/12"
          "10.0.0.0/8"
          "fd00::/8"
          "fe80::/10"
        ];
        module-config = ''"validator iterator"''; # (Default) Enable DNSSEC validation
        auto-trust-anchor-file = "/var/lib/unbound/root.key"; # (Default) Path to DNSSEC root key info, automatically updated by unbound
        # Performance
        num-threads = 4; # Use 4 worker threads
        msg-cache-slabs = 4; # Message cache distributed across 4 slabs
        rrset-cache-slabs = 4; # RRset cache distributed across 4 slabs
        infra-cache-slabs = 4; # Infrastructure cache distributed across 4 slabs
        key-cache-slabs = 4; # Key cache distributed across 4 slabs
        so-reuseport = true; # Allow multiple processes to bind to same port
        prefetch = true; # Enable prefetching of popular DNS records before expiry
        prefetch-key = true; # Enable prefetching of popular DNS keys before expiry
      };
    };
  };

  environment.persistence."/persist".directories = [
    "/var/lib/unbound" # Necessary to persist as root.key is automatically updated by unbound
  ];

  # Use Blocky as a filtering DNS server
  services.blocky = let
    # Use unbound server as upstream (same machine)
    upstreamDNS = "127.0.0.1:${toString config.services.unbound.settings.server.port}";
  in {
    enable = true;
    settings = {
      ports.dns = 53;
      ports.http = 4000;
      upstreams.strategy = "strict"; # Only one upstream, no sense being fancy
      upstreams.groups.default = [upstreamDNS];
      bootstrapDns.upstream = upstreamDNS;
      blocking = {
        denylists = {
          "general" = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://v.firebog.net/hosts/static/w3kbl.txt"
          ];
          "ads" = [
            "http://sysctl.org/cameleon/hosts"
            "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
            "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt"
            "https://adaway.org/hosts.txt"
            "https://v.firebog.net/hosts/AdguardDNS.txt"
            "https://v.firebog.net/hosts/Admiral.txt"
            "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
            "https://v.firebog.net/hosts/Easylist.txt"
            "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts"
            "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"
            "https://v.firebog.net/hosts/Prigent-Ads.txt"
          ];
          "tracking" = [
            "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
            "https://v.firebog.net/hosts/Easyprivacy.txt"
            "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
            "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt"
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts"
          ];
          "malicious" = [
            "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
            "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt"
            "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"
            "https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt"
            "https://phishing.army/download/phishing_army_blocklist_extended.txt"
            "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"
            "https://v.firebog.net/hosts/RPiList-Malware.txt"
            "https://v.firebog.net/hosts/RPiList-Phishing.txt"
          ];
          "other" = [
            "https://raw.githubusercontent.com/d43m0nhLInt3r/socialblocklists/master/TikTok/tiktokblocklist.txt"
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
            "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt"
            "https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts"
            "https://urlhaus.abuse.ch/downloads/hostfile/"
          ];
        };
        clientGroupsBlock.default = [
          "general"
          "ads"
          "tracking"
          "malicious"
          "other"
        ];
      };
      queryLog = {
        type = "csv";
        target = "/var/log/blocky";
      };
      prometheus.enable = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    config.services.blocky.settings.ports.dns
    config.services.blocky.settings.ports.http
  ];
  networking.firewall.allowedUDPPorts = [config.services.blocky.settings.ports.dns];

  # Create the /var/log/blocky directory
  systemd.services.blocky.serviceConfig.LogsDirectory = "blocky";
}
