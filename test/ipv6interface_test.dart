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

    test('OK: equal false test', () {
      expect(
          IPv6Interface('2001:4860:4860::8888/126') ==
              IPv6Interface('2001:4860:4860::8844/126'),
          false);
    });

    test('OK: equal other class false test', () {
      expect(IPv6Interface('2001:4860:4860::8888/126') == Object(), false);
    });

    test('OK: not equal test', () {
      expect(
          IPv6Interface('2001:4860:4860::8888/126') !=
              IPv6Interface('2001:4860:4860::8844/126'),
          true);
    });

    test('OK: not equal false test', () {
      var ipStr = '2001:4860:4860::8888/126';
      expect(IPv6Interface(ipStr) != IPv6Interface(ipStr), false);
    });

    test('OK: > operator test', () {
      expect(
          IPv6Interface('2001:4860:4860::8888/126') >
              IPv6Interface('2001:4860:4860::8844/126'),
          true);
    });

    test('OK: > operator false test', () {
      expect(
          IPv6Interface('2001:4860:4860::8844/126') >
              IPv6Interface('2001:4860:4860::8888/126'),
          false);
    });

    test('OK: > operator other class false test', () {
      expect(IPv6Interface('2001:4860:4860::8844/126') > Object(), false);
    });

    test('OK: >= operator test', () {
      expect(
          IPv6Interface('2001:4860:4860::8888/126') >=
              IPv6Interface('2001:4860:4860::8844/126'),
          true);
    });

    test('OK: >= operator false test', () {
      expect(
          IPv6Interface('2001:4860:4860::8844/126') >=
              IPv6Interface('2001:4860:4860::8888/126'),
          false);
    });

    test('OK: >= operator other class false test', () {
      expect(IPv6Interface('2001:4860:4860::8844/126') >= Object(), false);
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
