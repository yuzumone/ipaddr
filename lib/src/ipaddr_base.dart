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
  int _ip;

  @override
  bool operator ==(other) => _ip == other._ip;

  @override
  int get hashCode => _ip;

  bool operator >(other) => _ip > other._ip;

  bool operator <(other) => _ip < other._ip;

  bool operator >=(other) => _ip >= other._ip;

  bool operator <=(other) => _ip >= other._ip;

  /// Returns an integer representation of an IP address.
  int toInt() => _ip;
}

class _BaseNetwork extends _BaseIPAddress {
  int _ip;
  int _prefixlen;

  @override
  bool operator ==(other) => _ip == other._ip && _prefixlen == other.prefixlen;

  @override
  int get hashCode => _ip ^ _prefixlen;
}

abstract class _Address {
  @override
  String toString();

  _BaseAddress operator +(int other);
  _BaseAddress operator -(int other);
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
  int get numAddresses;

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

class _BaseIPv4Address = _BaseAddress with _BaseV4;
class _BaseIPv4Network = _BaseNetwork with _BaseV4;
class _BaseIPv4Interface = _BaseAddress with _BaseV4;

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
    _ip = _ipIntFromString(addr);
  }

  /// Crates a new IPv4Address from integer.
  IPv4Address.fromInt(int addr) {
    if (addr == null) {
      throw AddressValueError('Address cannot be empty');
    }
    _checkIntAddress(addr);
    _ip = addr;
  }

  @override
  String toString() => _stringFromIpInt(_ip);

  @override
  IPv4Address operator +(int other) => IPv4Address.fromInt(_ip + other);

  @override
  IPv4Address operator -(int other) => IPv4Address.fromInt(_ip - other);
}

/// A class for representing and manipulating 32-bit IPv4 network + addresses.
class IPv4Network extends _BaseIPv4Network implements _Network {
  @override
  IPv4Address get networkAddress => IPv4Address.fromInt(_ip);
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
    _ip = _ipIntFromString(ap[0]);
    _prefixlen = _makePrefix(ap[1]);
    var packed = networkAddress.toInt();
    if (packed & netmask.toInt() != packed) {
      if (strict) {
        throw ValueError('${addr} has host bits set.');
      } else {
        _ip = packed & netmask.toInt();
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
  IPv4Address get ip => IPv4Address.fromInt(_ip);
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
    _ip = _ipIntFromString(ap[0]);
    _address = _stringFromIpInt(_ip);
    _prefixlen = _makePrefix(ap[1]);
  }

  @override
  String toString() => withPrefixlen;
}
