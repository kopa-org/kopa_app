enum KopaEventType {
  match,
  training,
}

extension KopaEventTypeX on KopaEventType {
  String get apiValue => name;

  bool get isTraining => this == KopaEventType.training;
}

KopaEventType kopaEventTypeFromApi(String? value) {
  return value?.toLowerCase() == KopaEventType.training.apiValue
      ? KopaEventType.training
      : KopaEventType.match;
}
