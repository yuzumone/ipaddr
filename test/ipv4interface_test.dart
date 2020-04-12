import 'package:ipaddr/ipaddr.dart';
import 'package:ipaddr/src/exception.dart';
import 'package:test/test.dart';

void main() {
  group('IPv4Interface tests', () {
    IPv4Interface interface;

    test('OK: subnet is int', () {
      var ip = '192.168.10.0/30';
      interface = IPv4Interface(ip);
      expect(interface.toString(), ip);
      expect(interface.ip, IPv4Address('192.168.10.0'));
      expect(interface.network, IPv4Network(ip));
      expect(interface.withPrefixlen, ip);
      expect(interface.withNetmask, '192.168.10.0/255.255.255.252');
      expect(interface.withHostmask, '192.168.10.0/0.0.0.3');
    });

    test('OK: subnet is string', () {
      var ip = '192.168.10.0/255.255.255.252';
      interface = IPv4Interface(ip);
      expect(interface.toString(), '192.168.10.0/30');
      expect(interface.ip, IPv4Address('192.168.10.0'));
      expect(interface.network, IPv4Network(ip));
      expect(interface.withPrefixlen, '192.168.10.0/30');
      expect(interface.withNetmask, ip);
      expect(interface.withHostmask, '192.168.10.0/0.0.0.3');
    });

    test('OK: equal test', () {
      var ipStr = '192.168.10.0/30';
      expect(IPv4Interface(ipStr) == IPv4Interface(ipStr), true);
    });

    test('NG: exclude subnet', () {
      var fault = '192.168.10.10';
      expect(() => IPv4Interface(fault),
          throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: fault int subnet', () {
      var fault = '192.168.10.10/33';
      expect(() => IPv4Interface(fault),
          throwsA(TypeMatcher<NetmaskValueError>()));
    });

    test('NG: fault string subnet', () {
      var fault = '192.168.10.10/255.255.255.256';
      expect(() => IPv4Interface(fault),
          throwsA(TypeMatcher<NetmaskValueError>()));
    });

    test('NG: address is null', () {
      expect(
          () => IPv4Interface(null), throwsA(TypeMatcher<AddressValueError>()));
    });
  });
}
