# ipaddr
[![test and lint](https://github.com/yuzumone/ipaddr/actions/workflows/test.yml/badge.svg)](https://github.com/yuzumone/ipaddr/actions/workflows/test.yml)
[![pub](https://img.shields.io/pub/v/ipaddr.svg)](https://pub.dev/packages/ipaddr)
[![doc](https://img.shields.io/badge/dartdocs-latest-blue.svg)](https://pub.dev/documentation/ipaddr/latest)
## Usage

```dart
import 'package:ipaddr/ipaddr.dart' as ipaddr;

main() {
  var address = ipaddr.IPv4Address('192.168.10.10');
  var network = ipaddr.IPv4Network('192.168.10.0/24');
  if (network.addresses.contains(address)) {
    print('$address is included $network'); // 192.168.10.10 is included 192.168.10.0/24
  }
}
```

## Thanks
Inspired by python ipaddress lib.

## License
MIT
