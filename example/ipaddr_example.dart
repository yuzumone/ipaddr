import 'package:ipaddr/ipaddr.dart' as ipaddr;

void main() {
  var address = ipaddr.IPv4Address('192.168.0.1');
  print(address); // 102.168.0.10
  address = ipaddr.IPv4Address.fromInt(3232238090);
  print(address); // 102.168.0.10

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
}
