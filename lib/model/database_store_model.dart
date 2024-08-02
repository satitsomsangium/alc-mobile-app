enum DatabaseStore {
  dataMain,
  dataMutation,
  dataMainBarcode,
  aisleBay,
  bayDetail
}

extension DatabaseStoreExtension on DatabaseStore {
  String get asString {
    return toString().split('.').last;
  }
}