class AddressValueError implements Exception {
  final String msg;
  const AddressValueError(this.msg);
  @override
  String toString() => 'AddressValueError: $msg';
}

class NetmaskValueError implements Exception {
  final String msg;
  const NetmaskValueError(this.msg);
  @override
  String toString() => 'NetmaskValueError: $msg';
}

class ValueError implements Exception {
  final String msg;
  const ValueError(this.msg);
  @override
  String toString() => 'ValueError: $msg';
}
