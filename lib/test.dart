class TokenDto {
  TokenDto({
    UserDto? user,
    String? access,
    String? refresh,
    int? accessLifetime,
    int? refreshLife,
    String? next,
  });

  factory TokenDto.fromJson(Map<String, dynamic> json) => TokenDto(
    user: json['user'] != null ? UserDto.fromJson(json['user'] as Map<String, dynamic>) : null,
    access: json['access'] != null ? json['access'] as String : null,
    refresh: json['refresh'] != null ? json['refresh'] as String : null,
    accessLifetime: json['access_lifetime'] != null ? json['access_lifetime'] as int : null,
    refreshLife: json['refresh_life'] != null ? json['refresh_life'] as int : null,
    next: json['next'] != null ? json['next'] as String : null,
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'user': user,
      'access': access,
      'refresh': refresh,
      'access_lifetime': accessLifetime,
      'refresh_life': refreshLife,
      'next': next,
    };
  }


  UserDto? user;
  String? access;
  String? refresh;
  int? accessLifetime;
  int? refreshLife;
  String? next;
}

class UserDto {
  UserDto({
    int? id,
    String? phoneNumber,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json['id'] != null ? json['id'] as int : null,
    phoneNumber: json['phone_number'] != null ? json['phone_number'] as String : null,
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'phone_number': phoneNumber,
    };
  }


  int? id;
  String? phoneNumber;
}



