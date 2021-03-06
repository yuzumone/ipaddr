import 'package:ipaddr/ipaddr.dart';
import 'package:ipaddr/src/exception.dart';
import 'package:test/test.dart';

void main() {
  group('IPv4Network tests', () {
    var networkAddress = IPv4Address('192.168.10.0');
    var broadcastAddress = IPv4Address('192.168.10.3');
    var netmask = IPv4Address('255.255.255.252');
    var hostmask = IPv4Address('0.0.0.3');

    test('OK: subnet is int', () {
      var ip = '192.168.10.0/30';
      var network = IPv4Network(ip);
      expect(network.toString(), ip);
      expect(network.networkAddress, networkAddress);
      expect(network.broadcastAddress, broadcastAddress);
      expect(network.prefixlen, 30);
      expect(network.netmask, netmask);
      expect(network.hostmask, hostmask);
      expect(network.hosts,
          [IPv4Address('192.168.10.1'), IPv4Address('192.168.10.2')]);
      expect(network.addresses, [
        IPv4Address('192.168.10.0'),
        IPv4Address('192.168.10.1'),
        IPv4Address('192.168.10.2'),
        IPv4Address('192.168.10.3'),
      ]);
      expect(network.withPrefixlen, ip);
      expect(network.withNetmask, '192.168.10.0/255.255.255.252');
      expect(network.withHostmask, '192.168.10.0/0.0.0.3');
      expect(network.numAddresses, 4);
    });

    test('OK: subnet is string', () {
      var ip = '192.168.10.0/255.255.255.252';
      var network = IPv4Network(ip);
      expect(network.toString(), '192.168.10.0/30');
      expect(network.networkAddress, networkAddress);
      expect(network.broadcastAddress, broadcastAddress);
      expect(network.prefixlen, 30);
      expect(network.netmask, netmask);
      expect(network.hostmask, hostmask);
      expect(network.hosts,
          [IPv4Address('192.168.10.1'), IPv4Address('192.168.10.2')]);
      expect(network.addresses, [
        IPv4Address('192.168.10.0'),
        IPv4Address('192.168.10.1'),
        IPv4Address('192.168.10.2'),
        IPv4Address('192.168.10.3'),
      ]);
      expect(network.withPrefixlen, '192.168.10.0/30');
      expect(network.withNetmask, ip);
      expect(network.withHostmask, '192.168.10.0/0.0.0.3');
      expect(network.numAddresses, 4);
    });

    test('OK: tryParse', () {
      var ip = '192.168.10.0/30';
      var network = IPv4Network.tryParse(ip);
      expect(network.toString(), ip);
    });

    test('OK: tryParse null', () {
      var network = IPv4Network.tryParse('-1');
      expect(network, null);
    });

    test('OK: equal test', () {
      var ipStr = '192.168.10.0/30';
      expect(IPv4Network(ipStr) == IPv4Network(ipStr), true);
    });

    test('OK: equal false test', () {
      expect(IPv4Network('192.168.10.0/30') == IPv4Network('192.168.10.0/31'),
          false);
    });

    test('OK: equal other class false test', () {
      expect(IPv4Network('192.168.10.0/30') == Object(), false);
    });

    test('OK: not equal test', () {
      expect(IPv4Network('192.168.10.0/30') != IPv4Network('192.168.10.0/31'),
          true);
    });

    test('OK: not equal false test', () {
      var ipStr = '192.168.10.0/30';
      expect(IPv4Network(ipStr) != IPv4Network(ipStr), false);
    });

    test('OK: strict option is false', () {
      expect(
          IPv4Network('192.168.10.1/30', strict: false) ==
              IPv4Network('192.168.10.0/30'),
          true);
    });

    test('NG: strict option is true and network address is not supplied.', () {
      expect(() => IPv4Network('192.168.10.1/30', strict: true),
          throwsA(TypeMatcher<ValueError>()));
    });

    test('NG: exclude subnet', () {
      var fault = '192.168.10.10';
      expect(
          () => IPv4Network(fault), throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: fault int subnet', () {
      var fault = '192.168.10.10/33';
      expect(
          () => IPv4Network(fault), throwsA(TypeMatcher<NetmaskValueError>()));
    });

    test('NG: fault string subnet', () {
      var fault = '192.168.10.10/255.255.255.256';
      expect(
          () => IPv4Network(fault), throwsA(TypeMatcher<NetmaskValueError>()));
    });
  });
}
