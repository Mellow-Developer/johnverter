class TestReqDto {
  TestReqDto({
    this.names,
    this.id,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'names': names?.map((e) => e?.toJson()).toList(),
      'id': id?.toJson(),
      'phone_number': phoneNumber,
    };
  }

  final List<NamesReqDto?>? names;
  final IdReqDto? id;
  final String? phoneNumber;
}

class NamesReqDto {
  NamesReqDto({
    this.names,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'names': names,
    };
  }

  final String? names;
}

class IdReqDto {
  IdReqDto({
    this.name,
    this.lastName,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'last_name': lastName,
    };
  }

  final String? name;
  final String? lastName;
}
