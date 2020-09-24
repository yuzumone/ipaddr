import 'package:ipaddr/ipaddr.dart' as ipaddr;

void main() {
  var address = ipaddr.IPv4Address('192.168.10.10');
  print(address); // 192.168.10.10
  address = ipaddr.IPv4Address.fromInt(3232238090);
  print(address); // 192.168.10.10
  print(address + 1); // 192.168.10.11

  var network = ipaddr.IPv4Network('192.168.0.0/30');
  print(network); // 192.168.0.0/30
  print(network.networkAddress); // 192.168.0.0
  print(network.broadcastAddress); // 192.168.0.3
  print(network.prefixlen); // 30
  print(network.netmask); // 255.255.255.252
  print(network.hostmask); // 0.0.0.3
  print(network.hosts); // [192.168.0.1, 192.168.0.2]
  print(network
      .addresses); // [192.168.0.0, 192.168.0.1, 192.168.0.2, 192.168.0.4]
  print(network.numAddresses); // 4
  print(network.withPrefixlen); // 192.168.0.0/30
  print(network.withNetmask); // 192.168.0.0/255.255.255.255.252
  print(network.withHostmask); // 192.168.0.0/0.0.0.3

  var interface = ipaddr.IPv4Interface('192.168.10.10/24');
  print(interface); // 192.168.10.10/24
  print(interface.ip); // 192.168.10.10
  print(interface.network); // 192.168.10.10/24
  print(interface.withHostmask); // 192.168.10.10/0.0.0.255
  print(interface.withNetmask); // 192.168.10.10/255.255.255.0
  print(interface.withPrefixlen); // 192.168.10.10/24

  var v6address = ipaddr.IPv6Address('2001:4860:4860::8888');
  print(v6address); // 2001:4860:4860::8888
  v6address = ipaddr.IPv6Address.fromInt(
      BigInt.parse('42541956123769884636017138956568135816'));
  print(v6address); // 2001:4860:4860::8888
  print(v6address + 1); // 2001:4860:4860::8889

  var v6network = ipaddr.IPv6Network('dead:beef::/126');
  print(v6network); // dead:beef::/126
  print(v6network.networkAddress); // dead:beef::
  print(v6network.broadcastAddress); // dead:beef::3
  print(v6network.prefixlen); // 127
  print(v6network.netmask); // ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffc
  print(v6network.hostmask); // ::3
  print(v6network.hosts); // [dead:beef::1, dead:beef::2]
  print(v6network
      .addresses); // [dead:beef::, dead:beef::1, dead:beef::2, dead:beef::3]
  print(v6network.numAddresses); // 4
  print(v6network.withPrefixlen); // dead:beef::/126
  print(v6network
      .withNetmask); // dead:beef::/ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffc
  print(v6network.withHostmask); // dead:beef::/::3
}
