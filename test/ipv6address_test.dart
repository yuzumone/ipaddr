import 'package:ipaddr/ipaddr.dart';
import 'package:ipaddr/src/exception.dart';
import 'package:test/test.dart';

void main() {
  group('IPv6Address tests', () {
    IPv6Address addr;

    test('OK: from ip string', () {
      var ipStr = '2001:4860:4860::8888';
      var intStr = '42541956123769884636017138956568135816';
      addr = IPv6Address(ipStr);
      expect(addr.toString(), ipStr);
      expect(addr.toBigInt(), BigInt.parse(intStr));
    });

    test('OK: from ip int', () {
      var ipStr = '2001:4860:4860::8888';
      var intStr = '42541956123769884636017138956568135816';
      addr = IPv6Address.fromInt(BigInt.parse(intStr));
      expect(addr.toString(), ipStr);
      expect(addr.toBigInt(), BigInt.parse(intStr));
    });

    test('OK: tryParse', () {
      var ipStr = '2001:4860:4860::8888';
      addr = IPv6Address.tryParse(ipStr);
      expect(addr.toString(), ipStr);
    });

    test('OK: tryParse null', () {
      addr = IPv6Address.tryParse('-1');
      expect(addr, null);
    });

    test('OK: tryParseFromInt', () {
      var intStr = '42541956123769884636017138956568135816';
      addr = IPv6Address.tryParseFromInt(BigInt.parse(intStr));
      expect(addr.toBigInt(), BigInt.parse(intStr));
    });

    test('OK: tryParseFromInt null', () {
      var fault = BigInt.one - BigInt.two;
      addr = IPv6Address.tryParseFromInt(fault);
      expect(addr, null);
    });

    test('OK: equal test', () {
      var ipStr = '2001:4860:4860::8888';
      expect(IPv6Address(ipStr) == IPv6Address(ipStr), true);
    });

    test('OK: equal false test', () {
      expect(
          IPv6Address('2001:4860:4860::8888') ==
              IPv6Address('2001:4860:4860::8844'),
          false);
    });

    test('OK: equal other class false test', () {
      expect(IPv6Address('2001:4860:4860::8888') == Object(), false);
    });

    test('OK: not equal test', () {
      expect(
          IPv6Address('2001:4860:4860::8888') !=
              IPv6Address('2001:4860:4860::8844'),
          true);
    });

    test('OK: not equal false test', () {
      var ipStr = '2001:4860:4860::8888';
      expect(IPv6Address(ipStr) != IPv6Address(ipStr), false);
    });

    test('OK: > operator test', () {
      expect(
          IPv6Address('2001:4860:4860::8888') >
              IPv6Address('2001:4860:4860::8844'),
          true);
    });

    test('OK: > operator false test', () {
      expect(
          IPv6Address('2001:4860:4860::8844') >
              IPv6Address('2001:4860:4860::8888'),
          false);
    });

    test('OK: > operator other class false test', () {
      expect(IPv6Address('2001:4860:4860::8844') > Object(), false);
    });

    test('OK: >= operator test', () {
      expect(
          IPv6Address('2001:4860:4860::8888') >=
              IPv6Address('2001:4860:4860::8844'),
          true);
    });

    test('OK: >= operator false test', () {
      expect(
          IPv6Address('2001:4860:4860::8844') >=
              IPv6Address('2001:4860:4860::8888'),
          false);
    });

    test('OK: >= operator other class false test', () {
      expect(IPv6Address('2001:4860:4860::8844') >= Object(), false);
    });

    test('OK: plus test', () {
      var ipStr1 = '2001:4860:4860::8888';
      var ipStr2 = '2001:4860:4860::8889';
      expect((IPv6Address(ipStr1) + 1) == IPv6Address(ipStr2), true);
    });

    test('OK: plus bigint test', () {
      var ipStr1 = '2001:4860:4860::8888';
      var ipStr2 = '2001:4860:4860::8889';
      expect((IPv6Address(ipStr1) + BigInt.one) == IPv6Address(ipStr2), true);
    });

    test('OK: minus test', () {
      var ipStr1 = '2001:4860:4860::8888';
      var ipStr2 = '2001:4860:4860::8887';
      expect((IPv6Address(ipStr1) - 1) == IPv6Address(ipStr2), true);
    });

    test('OK: minus bigint test', () {
      var ipStr1 = '2001:4860:4860::8888';
      var ipStr2 = '2001:4860:4860::8887';
      expect((IPv6Address(ipStr1) - BigInt.one) == IPv6Address(ipStr2), true);
    });

    test('NG: include subnet', () {
      var fault = '2001:4860:4860::8888/24';
      expect(
          () => IPv6Address(fault), throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address is null', () {
      expect(
          () => IPv6Address(null), throwsA(TypeMatcher<AddressValueError>()));
      expect(() => IPv6Address.fromInt(null),
          throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address is minus', () {
      var fault = BigInt.one - BigInt.two;
      expect(() => IPv6Address.fromInt(fault),
          throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address is over 2 ^ 128', () {
      var fault = BigInt.two.pow(128);
      expect(() => IPv6Address.fromInt(fault),
          throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address most 4 char', () {
      var fault = '2001:4860:4860::88888';
      expect(
          () => IPv6Address(fault), throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address not 16 radix', () {
      var fault = '2001:4860:4860::zzzz';
      expect(
          () => IPv6Address(fault), throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address min parts', () {
      var fault = '2001:4860';
      expect(
          () => IPv6Address(fault), throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address over max parts', () {
      var fault = '1111:1111:1111:1111:1111:1111:1111:1111:1111';
      expect(
          () => IPv6Address(fault), throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address two ::', () {
      var fault = '1111::1111::1111';
      expect(
          () => IPv6Address(fault), throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address leading ":"', () {
      var fault = ':2001:4860:4860::8888';
      expect(
          () => IPv6Address(fault), throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address trailing ":"', () {
      var fault = '2001:4860:4860::8888:';
      expect(
          () => IPv6Address(fault), throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address expected at most 8 other parts with "::"', () {
      var fault = '1111:1111:1111:1111:1111:1111:1111::1111';
      expect(
          () => IPv6Address(fault), throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address leading with 8 len', () {
      var fault = ':1111:1111:1111:1111:1111:1111:1111';
      expect(
          () => IPv6Address(fault), throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: address trailing with 8 len', () {
      var fault = '1111:1111:1111:1111:1111:1111:1111:';
      expect(
          () => IPv6Address(fault), throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: plus over 2 ^ 128', () {
      var addr = IPv6Address('ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff');
      expect(() => addr + 100, throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: plus other class', () {
      var addr = IPv6Address('ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff');
      expect(() => addr + Object, throwsA(TypeMatcher<ValueError>()));
    });

    test('NG: minus under 0', () {
      var addr = IPv6Address('::0');
      expect(() => addr - 100, throwsA(TypeMatcher<AddressValueError>()));
    });

    test('NG: minus other class', () {
      var addr = IPv6Address('::0');
      expect(() => addr - Object, throwsA(TypeMatcher<ValueError>()));
    });
  });
}
