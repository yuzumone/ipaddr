import 'package:ipaddr/ipaddr.dart';
import 'package:ipaddr/src/exception.dart';
import 'package:test/test.dart';

void main() {
  group('IPv6Interface tests', () {
    IPv6Interface interface;

    test('OK: subnet is int', () {
      var ip = 'dead:beef::/126';
      interface = IPv6Interface(ip);
      expect(interface.toString(), ip);
      expect(interface.ip, IPv6Address('dead:beef::'));
      expect(interface.network, IPv6Network(ip));
      expect(interface.withPrefixlen, ip);
      expect(interface.withNetmask,
          'dead:beef::/ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffc');
      expect(interface.withHostmask, 'dead:beef::/::3');
    });

    test('OK: equal test', () {
      var ipStr = 'dead:beef::1/126';
      expect(IPv6Interface(ipStr) == IPv6Interface(ipStr), true);
    });

    test('NG: exclude subnet', () {
      var fault = 'dead:beef::1';
      expect(() => IPv6Interface(fault),
          throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: fault subnet', () {
      var fault = 'dead:beef::1/130';
      expect(() => IPv6Interface(fault),
          throwsA(TypeMatcher<NetmaskValueError>()));
    });

    test('NG: address is null', () {
      expect(
          () => IPv6Interface(null), throwsA(TypeMatcher<AddressValueError>()));
    });
  });
}
