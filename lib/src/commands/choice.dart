class CommandChoice<T> {
  final String name;
  final Map<String, String>? nameLocalizations;
  final T value;

  const new(this.name, this.value, {this.nameLocalizations});

  factory parse(Map data) {
    return .new(data["name"], data["value"], nameLocalizations: data["localizations"]);
  }

  Map<String, Object?> build() {
    return {
      "name": name,
      "localizations": nameLocalizations,
      "value": value,
    };
  }
}