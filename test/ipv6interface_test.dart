import 'package:ipaddr/ipaddr.dart';
import 'package:ipaddr/src/exception.dart';
import 'package:test/test.dart';

void main() {
  group('IPv6Interface tests', () {
    test('OK: subnet is int', () {
      var ip = 'dead:beef::/126';
      var v6Interface = IPv6Interface(ip);
      expect(v6Interface.toString(), ip);
      expect(v6Interface.ip, IPv6Address('dead:beef::'));
      expect(v6Interface.network, IPv6Network(ip));
      expect(v6Interface.withPrefixlen, ip);
      expect(v6Interface.withNetmask,
          'dead:beef::/ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffc');
      expect(v6Interface.withHostmask, 'dead:beef::/::3');
    });

    test('OK: tryParse', () {
      var ip = 'dead:beef::/126';
      var v6Interface = IPv6Interface.tryParse(ip);
      expect(v6Interface.toString(), ip);
    });

    test('OK: tryParse null', () {
      var v6Interface = IPv6Interface.tryParse('-1');
      expect(v6Interface, null);
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
  });
}
