import 'dart:typed_data';
import 'dart:math';
import 'package:ipaddr/src/exception.dart';
import 'package:ipaddr/src/utils.dart';

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
  BigInt _ip;

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is _BaseAddress &&
          runtimeType == other.runtimeType &&
          _ip == other._ip;

  @override
  int get hashCode => _ip.hashCode;

  bool operator >(other) =>
      other is _BaseAddress &&
      runtimeType == other.runtimeType &&
      _ip > other._ip;

  bool operator <(other) =>
      other is _BaseAddress &&
      runtimeType == other.runtimeType &&
      _ip < other._ip;

  bool operator >=(other) =>
      other is _BaseAddress &&
      runtimeType == other.runtimeType &&
      _ip >= other._ip;

  bool operator <=(other) =>
      other is _BaseAddress &&
      runtimeType == other.runtimeType &&
      _ip >= other._ip;

  /// Returns an integer representation of an IP address.
  int toInt() => _ip.toInt();

  /// Returns an bigint representation of an IP address.
  BigInt toBigInt() => _ip;
}

class _BaseNetwork extends _BaseIPAddress {
  BigInt _ip;
  int _prefixlen;

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is _BaseNetwork &&
          runtimeType == other.runtimeType &&
          _ip == other._ip &&
          _prefixlen == other._prefixlen;

  @override
  int get hashCode => _ip.hashCode ^ _prefixlen;
}

abstract class _Address {
  @override
  String toString();

  /// Addition operator.
  _BaseAddress operator +(other);

  /// Subtraction operator.
  _BaseAddress operator -(other);
}

abstract class _Network {
  /// The network address for the network.
  _BaseAddress get networkAddress;

  /// The netmask address for the network.
  _BaseAddress get netmask;

  /// The hostmask address for the network.
  _BaseAddress get hostmask;

  /// The broadcast address for the network.
  _BaseAddress get broadcastAddress;

  /// Returns an iterator over the usable hosts in the network.
  Iterable<_BaseAddress> get hosts;

  /// Returns an iterator over the all address in the network.
  Iterable<_BaseAddress> get addresses;

  /// The prefix length of the network.
  int get prefixlen;

  /// The total number of addresses in the network.
  dynamic get numAddresses;

  /// A string resresentation of the netwrok, with the mask in prefix length.
  String get withPrefixlen;

  /// A string representation of the network, with the mask in net mask notation.
  String get withNetmask;

  /// A string representation of the network, with the mask in host mask notation.
  String get withHostmask;
  @override
  String toString();
}

abstract class _Interface {
  /// The address without network information.
  _BaseAddress get ip;

  /// The network this interface belongs to.
  _BaseNetwork get network;

  /// A string resresentation of the netwrok, with the mask in prefix length.
  String get withPrefixlen;

  /// A string representation of the network, with the mask in net mask notation.
  String get withNetmask;

  /// A string representation of the network, with the mask in host mask notation.
  String get withHostmask;
}

mixin _BaseV4 {
  /// The appropriate version number: 4 for IPv4, 6 for IPv6.
  int get version => 4;

  /// The total number of bits in the address representation for this version: 32 for IPv4, 128 for IPv6.
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

mixin _BaseV6 {
  /// The appropriate version number: 4 for IPv4, 6 for IPv6.
  int get version => 6;

  /// The total number of bits in the address representation for this version: 32 for IPv4, 128 for IPv6.
  int get maxPrefixlen => 128;
  BigInt get _allOne => BigInt.from(2).pow(128) - BigInt.one;
  int get _hextetCount => 8;

  void _checkIntAddress(BigInt ipInt) {
    if (ipInt < BigInt.zero || ipInt > _allOne) {
      throw AddressValueError(
          '${ipInt} (0 > addr => $_allOne) is permitted as an IPv6 address');
    }
  }

  BigInt _ipIntFromPrefix(int prefixlen) {
    return _allOne ^ (_allOne >> prefixlen);
  }

  IPv6Address _makeNetmask(int arg) {
    var ipInt = _ipIntFromPrefix(arg);
    return IPv6Address.fromInt(ipInt);
  }

  int _makePrefix(String arg) {
    var prefix = int.tryParse(arg);
    if (prefix != null) {
      if (0 >= prefix || prefix > maxPrefixlen) {
        throw NetmaskValueError('$prefix');
      }
      return prefix;
    }
    throw NetmaskValueError('$prefix');
  }

  BigInt _parseHextet(String hextetStr) {
    if (hextetStr.length > 4) {
      throw ValueError('At most 4 characters permitted in $hextetStr');
    }
    var result = int.tryParse(hextetStr, radix: 16);
    if (result == null) {
      throw ValueError('Only hex digits permitted in $hextetStr');
    }
    return BigInt.from(result);
  }

  BigInt _ipIntFromString(String addr) {
    if (addr == null) {
      throw AddressValueError('Address cannot be empty');
    }
    var _minParts = 3;
    var parts = addr.split(':');
    if (parts.length < _minParts) {
      throw AddressValueError('At least $_minParts parts expected in $addr');
    }

    var _maxParts = 9;
    if (parts.length > _maxParts) {
      throw AddressValueError(
          'At most ${_maxParts - 1} colons permitted in $addr');
    }

    var skipIndex;
    range(1, parts.length - 1).forEach((x) {
      if (parts[x].isEmpty) {
        if (skipIndex != null) {
          throw AddressValueError('At most one "::" permitted in $addr');
        }
        skipIndex = x;
      }
    });

    var partsHi;
    var partsLo;
    var partsSkipped;
    if (skipIndex != null) {
      partsHi = skipIndex;
      partsLo = parts.length - skipIndex - 1;
      if (parts[0].isEmpty) {
        partsHi -= 1;
        if (partsHi != 0) {
          throw AddressValueError(
              'Leading ":" only permitted as part of "::" in $addr');
        }
      }
      if (parts[parts.length - 1].isEmpty) {
        partsLo -= 1;
        if (partsLo != 0) {
          throw AddressValueError(
              'Trailing ":" only permitted as part of "::" in $addr');
        }
      }
      partsSkipped = _hextetCount - (partsHi + partsLo);
      if (partsSkipped < 1) {
        throw AddressValueError(
            'Expected at most $_hextetCount other parts with "::" in $addr');
      }
    } else {
      if (parts.length != _hextetCount) {
        throw AddressValueError(
            'Exactly $_hextetCount parts expected without "::" in $addr');
      }
      if (parts[0].isEmpty) {
        throw AddressValueError(
            'Leading ":" only permitted as part of "::" in $addr');
      }
      if (parts[parts.length - 1].isEmpty) {
        throw AddressValueError(
            'Trailing ":" only permitted as part of "::" in $addr');
      }
      partsHi = parts.length;
      partsLo = 0;
      partsSkipped = 0;
    }
    try {
      var ipInt = BigInt.zero;
      range(0, partsHi).forEach((x) {
        ipInt <<= 16;
        ipInt |= _parseHextet(parts[x]);
      });
      ipInt <<= 16 * partsSkipped;
      range(-partsLo, 0).forEach((x) {
        ipInt <<= 16;
        ipInt |= _parseHextet(parts[parts.length + x]);
      });
      return ipInt;
    } catch (e) {
      throw AddressValueError('$e in $addr');
    }
  }

  String _stringFromIpInt(BigInt ipInt) {
    if (ipInt > _allOne) {
      throw ValueError('IPv6 address is too large');
    }
    var hexString = ipInt.toRadixString(16).padLeft(32, '0');
    var hextets = stepRange(0, 32, 4)
        .map((x) => int.parse(hexString.substring(x, x + 4), radix: 16)
            .toRadixString(16))
        .toList();
    hextets = _compressHextets(hextets);
    return hextets.join(':');
  }

  List<String> _compressHextets(List<String> hextets) {
    var best_doublecolon_start = -1;
    var best_doublecolon_len = 0;
    var doublecolon_start = -1;
    var doublecolon_len = 0;
    hextets.asMap().forEach((index, hextet) {
      if (hextet == '0') {
        doublecolon_len += 1;
        if (doublecolon_start == -1) {
          doublecolon_start = index;
        }
        if (doublecolon_len > best_doublecolon_len) {
          best_doublecolon_len = doublecolon_len;
          best_doublecolon_start = doublecolon_start;
        }
      } else {
        doublecolon_len = 0;
        doublecolon_start = -1;
      }
    });
    if (best_doublecolon_len > 1) {
      var best_doublecolon_end = best_doublecolon_start + best_doublecolon_len;
      if (best_doublecolon_end == hextets.length) {
        hextets += [''];
      }
      hextets.removeRange(best_doublecolon_start, best_doublecolon_end);
      hextets.insert(best_doublecolon_start, '');
      if (best_doublecolon_start == 0) {
        hextets = [''] + hextets;
      }
    }
    return hextets;
  }
}

class _BaseIPv4Address = _BaseAddress with _BaseV4;
class _BaseIPv4Network = _BaseNetwork with _BaseV4;
class _BaseIPv4Interface = _BaseAddress with _BaseV4;
class _BaseIPv6Address = _BaseAddress with _BaseV6;
class _BaseIPv6Network = _BaseNetwork with _BaseV6;
class _BaseIPv6Interface = _BaseAddress with _BaseV6;

/// A class for representing and manipulating single IPv4 Addresses.
class IPv4Address extends _BaseIPv4Address implements _Address {
  /// Creates a new IPv4Address.
  IPv4Address(String addr) {
    if (addr == null) {
      throw AddressValueError('Address cannot be empty');
    }
    if (addr.contains('/')) {
      throw AddressValueError('Unexpected \'/\' in ${addr}');
    }
    _ip = BigInt.from(_ipIntFromString(addr));
  }

  /// Crates a new IPv4Address from integer.
  IPv4Address.fromInt(int addr) {
    if (addr == null) {
      throw AddressValueError('Address cannot be empty');
    }
    _checkIntAddress(addr);
    _ip = BigInt.from(addr);
  }

  @override
  String toString() => _stringFromIpInt(_ip.toInt());

  @override
  IPv4Address operator +(dynamic other) {
    if (other is int) {
      return IPv4Address.fromInt((_ip + BigInt.from(other)).toInt());
    } else if (other is BigInt) {
      return IPv4Address.fromInt((_ip + other).toInt());
    } else {
      throw ValueError('Other is int or BigInt only');
    }
  }

  @override
  IPv4Address operator -(dynamic other) {
    if (other is int) {
      return IPv4Address.fromInt((_ip - BigInt.from(other)).toInt());
    } else if (other is BigInt) {
      return IPv4Address.fromInt((_ip - other).toInt());
    } else {
      throw ValueError('Other is int or BigInt only');
    }
  }
}

/// A class for representing and manipulating 32-bit IPv4 network + addresses.
class IPv4Network extends _BaseIPv4Network implements _Network {
  @override
  IPv4Address get networkAddress => IPv4Address.fromInt(_ip.toInt());
  @override
  IPv4Address get netmask => _makeNetmask(_prefixlen);
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
  int get prefixlen => _prefixlen;
  @override
  int get numAddresses => broadcastAddress.toInt() - networkAddress.toInt() + 1;
  @override
  String get withPrefixlen => '${networkAddress}/${prefixlen}';
  @override
  String get withNetmask => '${networkAddress}/${netmask}';
  @override
  String get withHostmask => '${networkAddress}/${hostmask}';

  /// Creates a new IPv4Network.
  /// Throw ValueError when strict opstion is true and network address is not supplied.
  IPv4Network(String addr, {bool strict = true}) {
    var ap = _splitAddrPrefix(addr);
    _ip = BigInt.from(_ipIntFromString(ap[0]));
    _prefixlen = _makePrefix(ap[1]);
    var packed = networkAddress.toInt();
    if (packed & netmask.toInt() != packed) {
      if (strict) {
        throw ValueError('${addr} has host bits set.');
      } else {
        _ip = BigInt.from(packed & netmask.toInt());
      }
    }
  }

  @override
  String toString() => withPrefixlen;
}

/// A class for representing and manipulating single IPv4 Addresses + Networks.
class IPv4Interface extends _BaseIPv4Interface implements _Interface {
  String _address;
  int _prefixlen;
  @override
  IPv4Address get ip => IPv4Address.fromInt(_ip.toInt());
  @override
  IPv4Network get network =>
      IPv4Network('${_address}/${_prefixlen}', strict: false);
  @override
  String get withHostmask => '${ip}/${network.hostmask}';
  @override
  String get withNetmask => '${ip}/${network.netmask}';
  @override
  String get withPrefixlen => '${ip}/${_prefixlen}';

  /// Creates a new IPv4Interface.
  IPv4Interface(String addr) {
    var ap = _splitAddrPrefix(addr);
    _ip = BigInt.from(_ipIntFromString(ap[0]));
    _address = _stringFromIpInt(_ip.toInt());
    _prefixlen = _makePrefix(ap[1]);
  }

  @override
  String toString() => withPrefixlen;
}

/// A class for representing and manipulating single IPv6 Addresses.
class IPv6Address extends _BaseIPv6Address implements _Address {
  /// Creates a new IPv6Address.
  IPv6Address(String addr) {
    if (addr == null) {
      throw AddressValueError('Address cannot be empty');
    }
    _ip = _ipIntFromString(addr);
  }

  /// Crates a new IPv6Address from BigInt.
  IPv6Address.fromInt(BigInt addr) {
    if (addr == null) {
      throw AddressValueError('Address cannot be empty');
    }
    _checkIntAddress(addr);
    _ip = addr;
  }

  @override
  String toString() => _stringFromIpInt(_ip);

  @override
  IPv6Address operator +(dynamic other) {
    if (other is int) {
      return IPv6Address.fromInt(_ip + BigInt.from(other));
    } else if (other is BigInt) {
      return IPv6Address.fromInt(_ip + other);
    } else {
      throw ValueError('Other is int or BigInt only');
    }
  }

  @override
  IPv6Address operator -(dynamic other) {
    if (other is int) {
      return IPv6Address.fromInt(_ip - BigInt.from(other));
    } else if (other is BigInt) {
      return IPv6Address.fromInt(_ip - other);
    } else {
      throw ValueError('Other is int or BigInt only');
    }
  }
}

/// A class for representing and manipulating 128-bit IPv6 network + addresses.
class IPv6Network extends _BaseIPv6Network implements _Network {
  @override
  IPv6Address get networkAddress => IPv6Address.fromInt(_ip);
  @override
  IPv6Address get netmask => _makeNetmask(_prefixlen);
  @override
  IPv6Address get hostmask => IPv6Address.fromInt(netmask.toBigInt() ^ _allOne);
  @override
  IPv6Address get broadcastAddress =>
      IPv6Address.fromInt(networkAddress.toBigInt() | hostmask.toBigInt());
  @override
  Iterable<IPv6Address> get hosts => bigIntRange(
          networkAddress.toBigInt() + BigInt.one, broadcastAddress.toBigInt())
      .map((x) => IPv6Address.fromInt(x))
      .toList();
  @override
  Iterable<IPv6Address> get addresses => bigIntRange(
          networkAddress.toBigInt(), broadcastAddress.toBigInt() + BigInt.one)
      .map((x) => IPv6Address.fromInt(x))
      .toList();
  @override
  int get prefixlen => _prefixlen;
  @override
  BigInt get numAddresses =>
      broadcastAddress.toBigInt() - networkAddress.toBigInt() + BigInt.one;
  @override
  String get withPrefixlen => '${networkAddress}/${prefixlen}';
  @override
  String get withNetmask => '${networkAddress}/${netmask}';
  @override
  String get withHostmask => '${networkAddress}/${hostmask}';

  /// Creates a new IPv6Network.
  /// Throw ValueError when strict opstion is true and network address is not supplied.
  IPv6Network(String addr, {bool strict = true}) {
    var ap = _splitAddrPrefix(addr);
    _ip = _ipIntFromString(ap[0]);
    _prefixlen = _makePrefix(ap[1]);
    var packed = networkAddress.toBigInt();
    if (packed & netmask.toBigInt() != packed) {
      if (strict) {
        throw ValueError('${addr} has host bits set.');
      } else {
        _ip = packed & netmask.toBigInt();
      }
    }
  }

  @override
  String toString() => withPrefixlen;
}

/// A class for representing and manipulating single IPv6 Addresses + Networks.
class IPv6Interface extends _BaseIPv6Interface implements _Interface {
  String _address;
  int _prefixlen;
  @override
  IPv6Address get ip => IPv6Address.fromInt(_ip);
  @override
  IPv6Network get network =>
      IPv6Network('${_address}/${_prefixlen}', strict: false);
  @override
  String get withHostmask => '${ip}/${network.hostmask}';
  @override
  String get withNetmask => '${ip}/${network.netmask}';
  @override
  String get withPrefixlen => '${ip}/${_prefixlen}';

  /// Creates a new IPv6Interface.
  IPv6Interface(String addr) {
    var ap = _splitAddrPrefix(addr);
    _ip = _ipIntFromString(ap[0]);
    _address = _stringFromIpInt(_ip);
    _prefixlen = _makePrefix(ap[1]);
  }

  @override
  String toString() => withPrefixlen;
}
