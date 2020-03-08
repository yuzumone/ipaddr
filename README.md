# ipaddress
## Usage

```dart
import 'package:ipaddress/ipaddress.dart' as ipaddress;

main() {
  var address = ipaddress.IPv4Address('192.168.10.10');
  var network = ipaddress.IPv4Network('192.168.10.0/24');
  if (network.addresses.contains(address)) {
    print('${address} is included ${network}'); // 192.168.10.10 is included 192.168.10.0/24
  }
}
```

## Thanks
Inspired by python ipaddress lib.

## License
MIT