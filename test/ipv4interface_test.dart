import 'package:ipaddr/ipaddr.dart';
import 'package:ipaddr/src/exception.dart';
import 'package:test/test.dart';

void main() {
  group('IPv4Interface tests', () {
    test('OK: subnet is int', () {
      var ip = '192.168.10.0/30';
      var v4Interface = IPv4Interface(ip);
      expect(v4Interface.toString(), ip);
      expect(v4Interface.ip, IPv4Address('192.168.10.0'));
      expect(v4Interface.network, IPv4Network(ip));
      expect(v4Interface.withPrefixlen, ip);
      expect(v4Interface.withNetmask, '192.168.10.0/255.255.255.252');
      expect(v4Interface.withHostmask, '192.168.10.0/0.0.0.3');
    });

    test('OK: subnet is string', () {
      var ip = '192.168.10.0/255.255.255.252';
      var v4Interface = IPv4Interface(ip);
      expect(v4Interface.toString(), '192.168.10.0/30');
      expect(v4Interface.ip, IPv4Address('192.168.10.0'));
      expect(v4Interface.network, IPv4Network(ip));
      expect(v4Interface.withPrefixlen, '192.168.10.0/30');
      expect(v4Interface.withNetmask, ip);
      expect(v4Interface.withHostmask, '192.168.10.0/0.0.0.3');
    });

    test('OK: tryParse', () {
      var ip = '192.168.10.0/30';
      var v4Interface = IPv4Interface.tryParse(ip);
      expect(v4Interface.toString(), ip);
    });

    test('OK: tryParse null', () {
      var v4Interface = IPv4Interface.tryParse('-1');
      expect(v4Interface, null);
    });

    test('OK: equal test', () {
      var ipStr = '192.168.10.0/30';
      expect(IPv4Interface(ipStr) == IPv4Interface(ipStr), true);
    });

    test('OK: not equal test', () {
      expect(
          IPv4Interface('192.168.10.0/30') != IPv4Interface('192.168.10.10/30'),
          true);
    });

    test('OK: not equal false test', () {
      var ipStr = '192.168.10.10/30';
      expect(IPv4Interface(ipStr) != IPv4Interface(ipStr), false);
    });

    test('OK: > operator test', () {
      expect(
          IPv4Interface('192.168.10.10/30') > IPv4Interface('192.168.10.0/30'),
          true);
    });

    test('OK: > operator false test', () {
      expect(
          IPv4Interface('192.168.10.0/30') > IPv4Interface('192.168.10.10/30'),
          false);
    });

    test('OK: > operator other class false test', () {
      expect(IPv4Interface('192.168.10.0/30') > Object(), false);
    });

    test('OK: >= operator test', () {
      expect(
          IPv4Interface('192.168.10.10/30') >= IPv4Interface('192.168.10.0/30'),
          true);
    });

    test('OK: >= operator false test', () {
      expect(
          IPv4Interface('192.168.10.0/30') >= IPv4Interface('192.168.10.10/30'),
          false);
    });

    test('OK: >= operator other class false test', () {
      expect(IPv4Interface('192.168.10.0/30') >= Object(), false);
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
  });
}
