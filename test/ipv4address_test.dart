import 'package:ipaddr/ipaddr.dart';
import 'package:ipaddr/src/exception.dart';
import 'package:test/test.dart';

void main() {
  group('IPv4Address tests', () {
    IPv4Address addr;

    test('OK: from ip string', () {
      var ipStr = '192.168.10.10';
      var ipInt = 3232238090;
      addr = IPv4Address(ipStr);
      expect(addr.toString(), ipStr);
      expect(addr.toInt(), ipInt);
    });

    test('OK: from ip int', () {
      var ipStr = '192.168.10.10';
      var ipInt = 3232238090;
      addr = IPv4Address.fromInt(ipInt);
      expect(addr.toString(), ipStr);
      expect(addr.toInt(), ipInt);
    });

    test('OK: equal test', () {
      var ipStr = '192.168.10.10';
      expect(IPv4Address(ipStr) == IPv4Address(ipStr), true);
    });

    test('OK: equal false test', () {
      expect(
          IPv4Address('192.168.10.0') == IPv4Address('192.168.10.10'), false);
    });

    test('OK: equal other class false test', () {
      expect(IPv4Address('192.168.10.0') == Object(), false);
    });

    test('OK: not equal test', () {
      expect(IPv4Address('192.168.10.0') != IPv4Address('192.168.10.10'), true);
    });

    test('OK: not equal false test', () {
      var ipStr = '192.168.10.10';
      expect(IPv4Address(ipStr) != IPv4Address(ipStr), false);
    });

    test('OK: > operator test', () {
      expect(IPv4Address('192.168.10.10') > IPv4Address('192.168.10.0'), true);
    });

    test('OK: > operator false test', () {
      expect(IPv4Address('192.168.10.0') > IPv4Address('192.168.10.10'), false);
    });

    test('OK: > operator other class false test', () {
      expect(IPv4Address('192.168.10.0') > Object(), false);
    });

    test('OK: >= operator test', () {
      expect(IPv4Address('192.168.10.10') >= IPv4Address('192.168.10.0'), true);
    });

    test('OK: >= operator false test', () {
      expect(
          IPv4Address('192.168.10.0') >= IPv4Address('192.168.10.10'), false);
    });

    test('OK: >= operator other class false test', () {
      expect(IPv4Address('192.168.10.0') >= Object(), false);
    });

    test('OK: plus test', () {
      expect((IPv4Address('192.168.10.9') + 1) == IPv4Address('192.168.10.10'),
          true);
    });

    test('OK: plus bigint test', () {
      expect(
          (IPv4Address('192.168.10.9') + BigInt.one) ==
              IPv4Address('192.168.10.10'),
          true);
    });

    test('OK: minus test', () {
      expect((IPv4Address('192.168.10.11') - 1) == IPv4Address('192.168.10.10'),
          true);
    });

    test('OK: minus bigint test', () {
      expect(
          (IPv4Address('192.168.10.11') - BigInt.one) ==
              IPv4Address('192.168.10.10'),
          true);
    });

    test('NG: include subnet', () {
      var fault = '192.168.10.10/24';
      expect(
          () => IPv4Address(fault), throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address is null', () {
      expect(
          () => IPv4Address(null), throwsA(TypeMatcher<AddressValueError>()));
      expect(() => IPv4Address.fromInt(null),
          throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address is not 4 octects', () {
      var fault = '100.100.100';
      expect(
          () => IPv4Address(fault), throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address over 3 str length', () {
      var fault = '1000.10.10.10';
      expect(() => IPv4Address(fault), throwsA(TypeMatcher<ValueError>()));
    });

    test('NG: address over 255', () {
      var fault = '100.10.10.256';
      expect(() => IPv4Address(fault), throwsA(TypeMatcher<ValueError>()));
    });

    test('NG: plus over 4294967295', () {
      var addr = IPv4Address('255.255.255.255');
      expect(() => addr + 100, throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: plus other class', () {
      var addr = IPv4Address('192.168.10.10');
      expect(() => addr + Object, throwsA(TypeMatcher<ValueError>()));
    });

    test('NG: minus under 0', () {
      var addr = IPv4Address('0.0.0.0');
      expect(() => addr - 100, throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: minus other class', () {
      var addr = IPv4Address('192.168.10.10');
      expect(() => addr - Object, throwsA(TypeMatcher<ValueError>()));
    });
  });
}
