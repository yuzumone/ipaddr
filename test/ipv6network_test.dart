import 'package:ipaddr/ipaddr.dart';
import 'package:ipaddr/src/exception.dart';
import 'package:test/test.dart';

void main() {
  group('IPv6Network tests', () {
    IPv6Network network;
    var networkAddress = IPv6Address('dead:beef::');
    var broadcastAddress = IPv6Address('dead:beef::3');
    var netmask = IPv6Address('ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffc');
    var hostmask = IPv6Address('::3');

    test('OK: subnet is int', () {
      var ip = 'dead:beef::/126';
      network = IPv6Network(ip);
      expect(network.toString(), ip);
      expect(network.networkAddress, networkAddress);
      expect(network.broadcastAddress, broadcastAddress);
      expect(network.prefixlen, 126);
      expect(network.netmask, netmask);
      expect(network.hostmask, hostmask);
      expect(network.hosts,
          [IPv6Address('dead:beef::1'), IPv6Address('dead:beef::2')]);
      expect(network.addresses, [
        IPv6Address('dead:beef::'),
        IPv6Address('dead:beef::1'),
        IPv6Address('dead:beef::2'),
        IPv6Address('dead:beef::3'),
      ]);
      expect(network.withPrefixlen, ip);
      expect(network.withNetmask,
          'dead:beef::/ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffc');
      expect(network.withHostmask, 'dead:beef::/::3');
      expect(network.numAddresses, BigInt.from(4));
    });

    test('OK: equal test', () {
      var ipStr = 'dead:beef::/126';
      expect(IPv6Network(ipStr) == IPv6Network(ipStr), true);
    });

    test('OK: equal false test', () {
      expect(IPv6Network('dead:beef::/126') == IPv6Network('dead:beef::/64'),
          false);
    });

    test('OK: equal other class false test', () {
      expect(IPv6Network('dead:beef::/126') == Object(), false);
    });

    test('OK: not equal test', () {
      expect(IPv6Network('dead:beef::/126') != IPv6Network('dead:beef::/64'),
          true);
    });

    test('OK: not equal false test', () {
      var ipStr = 'dead:beef::/126';
      expect(IPv6Network(ipStr) != IPv6Network(ipStr), false);
    });

    test('OK: strict option is false', () {
      expect(
          IPv6Network('dead:beef::1/126', strict: false) ==
              IPv6Network('dead:beef::/126'),
          true);
    });

    test('NG: strict option is true and network address is not supplied.', () {
      expect(() => IPv6Network('dead:beef::1/126', strict: true),
          throwsA(TypeMatcher<ValueError>()));
    });

    test('NG: exclude subnet', () {
      var fault = 'dead:beef::';
      expect(
          () => IPv6Network(fault), throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: fault int subnet', () {
      var fault = 'dead:beef::/130';
      expect(
          () => IPv6Network(fault), throwsA(TypeMatcher<NetmaskValueError>()));
    });

    test('NG: address is null', () {
      expect(
          () => IPv6Network(null), throwsA(TypeMatcher<AddressValueError>()));
    });
  });
}
