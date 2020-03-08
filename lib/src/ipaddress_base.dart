import 'dart:typed_data';
import 'dart:math';
import 'package:ipaddress/src/exception.dart';
import 'package:ipaddress/src/utils.dart';

class _BaseIPAddress extends Object {
  List<String> _splitAddrPrefix(String address) {
    if (address == null) {
      throw AddressValueError('Address cannot be empty');
    }
    var addr = address.split('/');
    if (addr.length != 2) {
      throw AddressValueError('Only one \'/\' permitted in ${address}');
    }
    return addr;
  }
}

class _BaseAddress extends _BaseIPAddress {
  int _ip;

  @override
  bool operator ==(other) => _ip == other._ip;

  @override
  int get hashCode => _ip;

  bool operator >(other) => _ip > other._ip;

  bool operator <(other) => _ip < other._ip;

  bool operator >=(other) => _ip >= other._ip;

  bool operator <=(other) => _ip >= other._ip;

  int toInt() => _ip;
}

class _BaseNetwork extends _BaseIPAddress {
  int _ip;
  int prefixlen;

  @override
  bool operator ==(other) => _ip == other._ip && prefixlen == other.prefixlen;

  @override
  int get hashCode => _ip ^ prefixlen;
}

abstract class _Address {
  @override
  String toString();
}

abstract class _Network {
  _BaseAddress get networkAddress;
  _BaseAddress get netmask;
  _BaseAddress get hostmask;
  _BaseAddress get broadcastAddress;
  Iterable<_BaseAddress> get hosts;
  Iterable<_BaseAddress> get addresses;
  int get numAddresses;
  String get withPrefixlen;
  String get withNetmask;
  String get withHostmask;
  @override
  String toString();
}

mixin _BaseV4 {
  int get version => 4;
  int get maxPrefixlen => 32;
  int get _allOne => 4294967295;

  void _checkIntAddress(int ipInt) {
    if (ipInt < 0 || ipInt > _allOne) {
      throw AddressValueError(
          '${ipInt} (0 > addr => 255) is permitted as an IPv4 address');
    }
  }

  IPv4Address _makeNetmask(int arg) {
    var ipInt = _ipIntFromPrefix(arg);
    return IPv4Address.fromInt(ipInt);
  }

  int _makePrefix(String arg) {
    var prefix = int.tryParse(arg);
    if (prefix != null) {
      if (0 >= prefix || prefix > maxPrefixlen) {
        throw NetmaskValueError('${prefix}');
      }
      return prefix;
    } else {
      try {
        var prefix = _prefixFromPrefixString(arg);
        return prefix;
      } catch (e) {
        var prefix = _prefixFromIpString(arg);
        return prefix;
      }
    }
  }

  int _countRighthandZeroBits(int number, int bits) {
    if (number == 0) {
      return bits;
    }
    return min(bits, (~number & (number - 1)).bitLength);
  }

  Uint8List _parseOctets(List<String> octets) {
    var list = octets.map((x) {
      if (x.length > 3) {
        throw ValueError('At most 3 characters permitted in ${x}');
      }
      var octetInt = int.tryParse(x);
      if (octetInt == null || octetInt > 255) {
        throw ValueError('Octet ${octetInt} (> 255) not permitted');
      }
      return octetInt;
    }).toList();
    return Uint8List.fromList(list);
  }

  int _ipIntFromString(String addr) {
    if (addr == null) {
      throw AddressValueError('Address cannot be empty');
    }
    var octets = addr.split('.');
    if (octets.length != 4) {
      throw AddressValueError('Expected 4 octets in ${addr}');
    }
    var list = _parseOctets(octets);
    return ByteData.view(list.buffer).getUint32(0);
  }

  int _ipIntFromPrefix(int prefixlen) {
    return _allOne ^ (_allOne >> prefixlen);
  }

  String _stringFromIpInt(int ipInt) {
    var bdata = ByteData.view(Uint8List(4).buffer);
    bdata.setUint32(0, ipInt);
    return bdata.buffer.asUint8List().join('.');
  }

  int _prefixFromPrefixString(String prefixStr) {
    var prefix = int.tryParse(prefixStr);
    if (prefix == null) {
      throw NetmaskValueError(prefixStr);
    }
    return prefix;
  }

  int _prefixFromIpInt(int ipInt) {
    var trailingZeroes = _countRighthandZeroBits(ipInt, maxPrefixlen);
    var prefixlen = maxPrefixlen - trailingZeroes;
    var leadingOnes = ipInt >> trailingZeroes;
    var allOnes = (1 << prefixlen) - 1;
    if (leadingOnes != allOnes) {
      throw ValueError('Netmask pattern mixes zeroes & ones');
    }
    return prefixlen;
  }

  int _prefixFromIpString(String prefixStr) {
    try {
      var ipInt = _ipIntFromString(prefixStr);
      return _prefixFromIpInt(ipInt);
    } catch (e) {
      throw NetmaskValueError(prefixStr);
    }
  }
}

class _BaseIPv4Address = _BaseAddress with _BaseV4;
class _BaseIPv4Network = _BaseNetwork with _BaseV4;

class IPv4Address extends _BaseIPv4Address implements _Address {
  IPv4Address(String addr) {
    if (addr == null) {
      throw AddressValueError('Address cannot be empty');
    }
    if (addr.contains('/')) {
      throw AddressValueError('Unexpected \'/\' in ${addr}');
    }
    _ip = _ipIntFromString(addr);
  }

  IPv4Address.fromInt(int addr) {
    if (addr == null) {
      throw AddressValueError('Address cannot be empty');
    }
    _checkIntAddress(addr);
    _ip = addr;
  }

  @override
  String toString() => _stringFromIpInt(_ip);
}

class IPv4Network extends _BaseIPv4Network implements _Network {
  @override
  IPv4Address networkAddress;
  @override
  IPv4Address netmask;
  @override
  IPv4Address get hostmask => IPv4Address.fromInt(netmask.toInt() ^ _allOne);
  @override
  IPv4Address get broadcastAddress =>
      IPv4Address.fromInt(networkAddress.toInt() | hostmask.toInt());
  @override
  Iterable<IPv4Address> get hosts =>
      range(networkAddress.toInt() + 1, broadcastAddress.toInt()).map((x) {
        return IPv4Address.fromInt(x);
      }).toList();
  @override
  Iterable<IPv4Address> get addresses =>
      range(networkAddress.toInt(), broadcastAddress.toInt() + 1).map((x) {
        return IPv4Address.fromInt(x);
      }).toList();
  @override
  int get numAddresses => broadcastAddress.toInt() - networkAddress.toInt() + 1;
  @override
  String get withPrefixlen => '${networkAddress}/${prefixlen}';
  @override
  String get withNetmask => '${networkAddress}/${netmask}';
  @override
  String get withHostmask => '${networkAddress}/${hostmask}';

  IPv4Network(String addr) {
    var ap = _splitAddrPrefix(addr);
    networkAddress = IPv4Address(ap[0]);
    _ip = networkAddress.toInt();
    prefixlen = _makePrefix(ap[1]);
    netmask = _makeNetmask(prefixlen);
  }

  @override
  String toString() => withPrefixlen;
}
