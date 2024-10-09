{config, ...}: {
  services.blocky = {
    enable = true;

    settings = {
      ports.dns = 53;
      ports.http = "127.0.0.1:4000";
      upstreams.groups.default = [
        # Cloudflare
        "1.1.1.1" # need at least one plain IP address in case the system time is wrong, which breaks TLS
        "https://one.one.one.one/dns-query"
        "tcp-tls:2606:4700:4700::1111"
        "tcp-tls:1.1.1.1"

        # Quad9
        "https://dns.quad9.net/dns-query"
        "tcp-tls:2620:fe::fe"
      ];
      bootstrapDns.upstream = "1.1.1.1";
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
            "https://v.firebog.net/hosts/Prigent-Crypto.txt"
            "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt"
            "https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts"
            "https://urlhaus.abuse.ch/downloads/hostfile/"
            "https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser"
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
    };
  };

  networking.firewall.allowedTCPPorts = [config.services.blocky.settings.ports.dns];
  networking.firewall.allowedUDPPorts = [config.services.blocky.settings.ports.dns];

  # Create the /var/log/blocky directory
  systemd.services.blocky.serviceConfig.LogsDirectory = "blocky";
}
