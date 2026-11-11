// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FarmsTableTable extends FarmsTable
    with TableInfo<$FarmsTableTable, Farm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Ghana'),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalAreaMeta = const VerificationMeta(
    'totalArea',
  );
  @override
  late final GeneratedColumn<double> totalArea = GeneratedColumn<double>(
    'total_area',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaUnitMeta = const VerificationMeta(
    'areaUnit',
  );
  @override
  late final GeneratedColumn<String> areaUnit = GeneratedColumn<String>(
    'area_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Acres'),
  );
  static const VerificationMeta _ownershipTypeMeta = const VerificationMeta(
    'ownershipType',
  );
  @override
  late final GeneratedColumn<String> ownershipType = GeneratedColumn<String>(
    'ownership_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    name,
    location,
    district,
    region,
    country,
    latitude,
    longitude,
    totalArea,
    areaUnit,
    ownershipType,
    notes,
    photoPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Farm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    } else if (isInserting) {
      context.missing(_regionMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('total_area')) {
      context.handle(
        _totalAreaMeta,
        totalArea.isAcceptableOrUnknown(data['total_area']!, _totalAreaMeta),
      );
    } else if (isInserting) {
      context.missing(_totalAreaMeta);
    }
    if (data.containsKey('area_unit')) {
      context.handle(
        _areaUnitMeta,
        areaUnit.isAcceptableOrUnknown(data['area_unit']!, _areaUnitMeta),
      );
    }
    if (data.containsKey('ownership_type')) {
      context.handle(
        _ownershipTypeMeta,
        ownershipType.isAcceptableOrUnknown(
          data['ownership_type']!,
          _ownershipTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownershipTypeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Farm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Farm(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      ),
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      totalArea: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_area'],
      )!,
      areaUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_unit'],
      )!,
      ownershipType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ownership_type'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
    );
  }

  @override
  $FarmsTableTable createAlias(String alias) {
    return $FarmsTableTable(attachedDatabase, alias);
  }
}

class Farm extends DataClass implements Insertable<Farm> {
  /// Unique client-generated UUID v4 identifier.
  final String id;

  /// Creation timestamp in milliseconds since epoch (UTC).
  final int createdAt;

  /// Last modification timestamp in milliseconds since epoch (UTC).
  final int updatedAt;

  /// Whether this record has been confirmed and synchronized with cloud.
  final bool isSynced;

  /// Soft deletion tombstone for cloud replication.
  final bool isDeleted;
  final String name;
  final String location;
  final String? district;
  final String region;
  final String country;
  final double? latitude;
  final double? longitude;
  final double totalArea;
  final String areaUnit;
  final String ownershipType;
  final String? notes;
  final String? photoPath;
  const Farm({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.isDeleted,
    required this.name,
    required this.location,
    this.district,
    required this.region,
    required this.country,
    this.latitude,
    this.longitude,
    required this.totalArea,
    required this.areaUnit,
    required this.ownershipType,
    this.notes,
    this.photoPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['name'] = Variable<String>(name);
    map['location'] = Variable<String>(location);
    if (!nullToAbsent || district != null) {
      map['district'] = Variable<String>(district);
    }
    map['region'] = Variable<String>(region);
    map['country'] = Variable<String>(country);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['total_area'] = Variable<double>(totalArea);
    map['area_unit'] = Variable<String>(areaUnit);
    map['ownership_type'] = Variable<String>(ownershipType);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    return map;
  }

  FarmsTableCompanion toCompanion(bool nullToAbsent) {
    return FarmsTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      name: Value(name),
      location: Value(location),
      district: district == null && nullToAbsent
          ? const Value.absent()
          : Value(district),
      region: Value(region),
      country: Value(country),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      totalArea: Value(totalArea),
      areaUnit: Value(areaUnit),
      ownershipType: Value(ownershipType),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
    );
  }

  factory Farm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Farm(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String>(json['location']),
      district: serializer.fromJson<String?>(json['district']),
      region: serializer.fromJson<String>(json['region']),
      country: serializer.fromJson<String>(json['country']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      totalArea: serializer.fromJson<double>(json['totalArea']),
      areaUnit: serializer.fromJson<String>(json['areaUnit']),
      ownershipType: serializer.fromJson<String>(json['ownershipType']),
      notes: serializer.fromJson<String?>(json['notes']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String>(location),
      'district': serializer.toJson<String?>(district),
      'region': serializer.toJson<String>(region),
      'country': serializer.toJson<String>(country),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'totalArea': serializer.toJson<double>(totalArea),
      'areaUnit': serializer.toJson<String>(areaUnit),
      'ownershipType': serializer.toJson<String>(ownershipType),
      'notes': serializer.toJson<String?>(notes),
      'photoPath': serializer.toJson<String?>(photoPath),
    };
  }

  Farm copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    String? name,
    String? location,
    Value<String?> district = const Value.absent(),
    String? region,
    String? country,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    double? totalArea,
    String? areaUnit,
    String? ownershipType,
    Value<String?> notes = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
  }) => Farm(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
    name: name ?? this.name,
    location: location ?? this.location,
    district: district.present ? district.value : this.district,
    region: region ?? this.region,
    country: country ?? this.country,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    totalArea: totalArea ?? this.totalArea,
    areaUnit: areaUnit ?? this.areaUnit,
    ownershipType: ownershipType ?? this.ownershipType,
    notes: notes.present ? notes.value : this.notes,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
  );
  Farm copyWithCompanion(FarmsTableCompanion data) {
    return Farm(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      district: data.district.present ? data.district.value : this.district,
      region: data.region.present ? data.region.value : this.region,
      country: data.country.present ? data.country.value : this.country,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      totalArea: data.totalArea.present ? data.totalArea.value : this.totalArea,
      areaUnit: data.areaUnit.present ? data.areaUnit.value : this.areaUnit,
      ownershipType: data.ownershipType.present
          ? data.ownershipType.value
          : this.ownershipType,
      notes: data.notes.present ? data.notes.value : this.notes,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Farm(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('district: $district, ')
          ..write('region: $region, ')
          ..write('country: $country, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('totalArea: $totalArea, ')
          ..write('areaUnit: $areaUnit, ')
          ..write('ownershipType: $ownershipType, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    name,
    location,
    district,
    region,
    country,
    latitude,
    longitude,
    totalArea,
    areaUnit,
    ownershipType,
    notes,
    photoPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Farm &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.name == this.name &&
          other.location == this.location &&
          other.district == this.district &&
          other.region == this.region &&
          other.country == this.country &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.totalArea == this.totalArea &&
          other.areaUnit == this.areaUnit &&
          other.ownershipType == this.ownershipType &&
          other.notes == this.notes &&
          other.photoPath == this.photoPath);
}

class FarmsTableCompanion extends UpdateCompanion<Farm> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> name;
  final Value<String> location;
  final Value<String?> district;
  final Value<String> region;
  final Value<String> country;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double> totalArea;
  final Value<String> areaUnit;
  final Value<String> ownershipType;
  final Value<String?> notes;
  final Value<String?> photoPath;
  final Value<int> rowid;
  const FarmsTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.district = const Value.absent(),
    this.region = const Value.absent(),
    this.country = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.totalArea = const Value.absent(),
    this.areaUnit = const Value.absent(),
    this.ownershipType = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmsTableCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String name,
    required String location,
    this.district = const Value.absent(),
    required String region,
    this.country = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required double totalArea,
    this.areaUnit = const Value.absent(),
    required String ownershipType,
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       location = Value(location),
       region = Value(region),
       totalArea = Value(totalArea),
       ownershipType = Value(ownershipType);
  static Insertable<Farm> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? name,
    Expression<String>? location,
    Expression<String>? district,
    Expression<String>? region,
    Expression<String>? country,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? totalArea,
    Expression<String>? areaUnit,
    Expression<String>? ownershipType,
    Expression<String>? notes,
    Expression<String>? photoPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (district != null) 'district': district,
      if (region != null) 'region': region,
      if (country != null) 'country': country,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (totalArea != null) 'total_area': totalArea,
      if (areaUnit != null) 'area_unit': areaUnit,
      if (ownershipType != null) 'ownership_type': ownershipType,
      if (notes != null) 'notes': notes,
      if (photoPath != null) 'photo_path': photoPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmsTableCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
    Value<String>? name,
    Value<String>? location,
    Value<String?>? district,
    Value<String>? region,
    Value<String>? country,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double>? totalArea,
    Value<String>? areaUnit,
    Value<String>? ownershipType,
    Value<String?>? notes,
    Value<String?>? photoPath,
    Value<int>? rowid,
  }) {
    return FarmsTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      name: name ?? this.name,
      location: location ?? this.location,
      district: district ?? this.district,
      region: region ?? this.region,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalArea: totalArea ?? this.totalArea,
      areaUnit: areaUnit ?? this.areaUnit,
      ownershipType: ownershipType ?? this.ownershipType,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (totalArea.present) {
      map['total_area'] = Variable<double>(totalArea.value);
    }
    if (areaUnit.present) {
      map['area_unit'] = Variable<String>(areaUnit.value);
    }
    if (ownershipType.present) {
      map['ownership_type'] = Variable<String>(ownershipType.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmsTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('district: $district, ')
          ..write('region: $region, ')
          ..write('country: $country, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('totalArea: $totalArea, ')
          ..write('areaUnit: $areaUnit, ')
          ..write('ownershipType: $ownershipType, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTableTable extends ProjectsTable
    with TableInfo<$ProjectsTableTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES farms (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectTypeMeta = const VerificationMeta(
    'projectType',
  );
  @override
  late final GeneratedColumn<String> projectType = GeneratedColumn<String>(
    'project_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commodityMeta = const VerificationMeta(
    'commodity',
  );
  @override
  late final GeneratedColumn<String> commodity = GeneratedColumn<String>(
    'commodity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _varietyMeta = const VerificationMeta(
    'variety',
  );
  @override
  late final GeneratedColumn<String> variety = GeneratedColumn<String>(
    'variety',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _landSizeMeta = const VerificationMeta(
    'landSize',
  );
  @override
  late final GeneratedColumn<double> landSize = GeneratedColumn<double>(
    'land_size',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _landUnitMeta = const VerificationMeta(
    'landUnit',
  );
  @override
  late final GeneratedColumn<String> landUnit = GeneratedColumn<String>(
    'land_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Acres'),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<int> startDate = GeneratedColumn<int>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedCompletionDateMeta =
      const VerificationMeta('expectedCompletionDate');
  @override
  late final GeneratedColumn<int> expectedCompletionDate = GeneratedColumn<int>(
    'expected_completion_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expectedFirstHarvestDateMeta =
      const VerificationMeta('expectedFirstHarvestDate');
  @override
  late final GeneratedColumn<int> expectedFirstHarvestDate =
      GeneratedColumn<int>(
        'expected_first_harvest_date',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GHS'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PLANNING'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    farmId,
    name,
    projectType,
    commodity,
    variety,
    landSize,
    landUnit,
    startDate,
    expectedCompletionDate,
    expectedFirstHarvestDate,
    currency,
    status,
    description,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('project_type')) {
      context.handle(
        _projectTypeMeta,
        projectType.isAcceptableOrUnknown(
          data['project_type']!,
          _projectTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_projectTypeMeta);
    }
    if (data.containsKey('commodity')) {
      context.handle(
        _commodityMeta,
        commodity.isAcceptableOrUnknown(data['commodity']!, _commodityMeta),
      );
    } else if (isInserting) {
      context.missing(_commodityMeta);
    }
    if (data.containsKey('variety')) {
      context.handle(
        _varietyMeta,
        variety.isAcceptableOrUnknown(data['variety']!, _varietyMeta),
      );
    }
    if (data.containsKey('land_size')) {
      context.handle(
        _landSizeMeta,
        landSize.isAcceptableOrUnknown(data['land_size']!, _landSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_landSizeMeta);
    }
    if (data.containsKey('land_unit')) {
      context.handle(
        _landUnitMeta,
        landUnit.isAcceptableOrUnknown(data['land_unit']!, _landUnitMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('expected_completion_date')) {
      context.handle(
        _expectedCompletionDateMeta,
        expectedCompletionDate.isAcceptableOrUnknown(
          data['expected_completion_date']!,
          _expectedCompletionDateMeta,
        ),
      );
    }
    if (data.containsKey('expected_first_harvest_date')) {
      context.handle(
        _expectedFirstHarvestDateMeta,
        expectedFirstHarvestDate.isAcceptableOrUnknown(
          data['expected_first_harvest_date']!,
          _expectedFirstHarvestDateMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      projectType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_type'],
      )!,
      commodity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commodity'],
      )!,
      variety: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variety'],
      ),
      landSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}land_size'],
      )!,
      landUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}land_unit'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_date'],
      )!,
      expectedCompletionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_completion_date'],
      ),
      expectedFirstHarvestDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_first_harvest_date'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ProjectsTableTable createAlias(String alias) {
    return $ProjectsTableTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  /// Unique client-generated UUID v4 identifier.
  final String id;

  /// Creation timestamp in milliseconds since epoch (UTC).
  final int createdAt;

  /// Last modification timestamp in milliseconds since epoch (UTC).
  final int updatedAt;

  /// Whether this record has been confirmed and synchronized with cloud.
  final bool isSynced;

  /// Soft deletion tombstone for cloud replication.
  final bool isDeleted;
  final String farmId;
  final String name;
  final String projectType;
  final String commodity;
  final String? variety;
  final double landSize;
  final String landUnit;
  final int startDate;
  final int? expectedCompletionDate;
  final int? expectedFirstHarvestDate;
  final String currency;
  final String status;
  final String? description;
  final String? notes;
  const Project({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.isDeleted,
    required this.farmId,
    required this.name,
    required this.projectType,
    required this.commodity,
    this.variety,
    required this.landSize,
    required this.landUnit,
    required this.startDate,
    this.expectedCompletionDate,
    this.expectedFirstHarvestDate,
    required this.currency,
    required this.status,
    this.description,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['farm_id'] = Variable<String>(farmId);
    map['name'] = Variable<String>(name);
    map['project_type'] = Variable<String>(projectType);
    map['commodity'] = Variable<String>(commodity);
    if (!nullToAbsent || variety != null) {
      map['variety'] = Variable<String>(variety);
    }
    map['land_size'] = Variable<double>(landSize);
    map['land_unit'] = Variable<String>(landUnit);
    map['start_date'] = Variable<int>(startDate);
    if (!nullToAbsent || expectedCompletionDate != null) {
      map['expected_completion_date'] = Variable<int>(expectedCompletionDate);
    }
    if (!nullToAbsent || expectedFirstHarvestDate != null) {
      map['expected_first_harvest_date'] = Variable<int>(
        expectedFirstHarvestDate,
      );
    }
    map['currency'] = Variable<String>(currency);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ProjectsTableCompanion toCompanion(bool nullToAbsent) {
    return ProjectsTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      farmId: Value(farmId),
      name: Value(name),
      projectType: Value(projectType),
      commodity: Value(commodity),
      variety: variety == null && nullToAbsent
          ? const Value.absent()
          : Value(variety),
      landSize: Value(landSize),
      landUnit: Value(landUnit),
      startDate: Value(startDate),
      expectedCompletionDate: expectedCompletionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedCompletionDate),
      expectedFirstHarvestDate: expectedFirstHarvestDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedFirstHarvestDate),
      currency: Value(currency),
      status: Value(status),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      farmId: serializer.fromJson<String>(json['farmId']),
      name: serializer.fromJson<String>(json['name']),
      projectType: serializer.fromJson<String>(json['projectType']),
      commodity: serializer.fromJson<String>(json['commodity']),
      variety: serializer.fromJson<String?>(json['variety']),
      landSize: serializer.fromJson<double>(json['landSize']),
      landUnit: serializer.fromJson<String>(json['landUnit']),
      startDate: serializer.fromJson<int>(json['startDate']),
      expectedCompletionDate: serializer.fromJson<int?>(
        json['expectedCompletionDate'],
      ),
      expectedFirstHarvestDate: serializer.fromJson<int?>(
        json['expectedFirstHarvestDate'],
      ),
      currency: serializer.fromJson<String>(json['currency']),
      status: serializer.fromJson<String>(json['status']),
      description: serializer.fromJson<String?>(json['description']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'farmId': serializer.toJson<String>(farmId),
      'name': serializer.toJson<String>(name),
      'projectType': serializer.toJson<String>(projectType),
      'commodity': serializer.toJson<String>(commodity),
      'variety': serializer.toJson<String?>(variety),
      'landSize': serializer.toJson<double>(landSize),
      'landUnit': serializer.toJson<String>(landUnit),
      'startDate': serializer.toJson<int>(startDate),
      'expectedCompletionDate': serializer.toJson<int?>(expectedCompletionDate),
      'expectedFirstHarvestDate': serializer.toJson<int?>(
        expectedFirstHarvestDate,
      ),
      'currency': serializer.toJson<String>(currency),
      'status': serializer.toJson<String>(status),
      'description': serializer.toJson<String?>(description),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Project copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    String? farmId,
    String? name,
    String? projectType,
    String? commodity,
    Value<String?> variety = const Value.absent(),
    double? landSize,
    String? landUnit,
    int? startDate,
    Value<int?> expectedCompletionDate = const Value.absent(),
    Value<int?> expectedFirstHarvestDate = const Value.absent(),
    String? currency,
    String? status,
    Value<String?> description = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => Project(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
    farmId: farmId ?? this.farmId,
    name: name ?? this.name,
    projectType: projectType ?? this.projectType,
    commodity: commodity ?? this.commodity,
    variety: variety.present ? variety.value : this.variety,
    landSize: landSize ?? this.landSize,
    landUnit: landUnit ?? this.landUnit,
    startDate: startDate ?? this.startDate,
    expectedCompletionDate: expectedCompletionDate.present
        ? expectedCompletionDate.value
        : this.expectedCompletionDate,
    expectedFirstHarvestDate: expectedFirstHarvestDate.present
        ? expectedFirstHarvestDate.value
        : this.expectedFirstHarvestDate,
    currency: currency ?? this.currency,
    status: status ?? this.status,
    description: description.present ? description.value : this.description,
    notes: notes.present ? notes.value : this.notes,
  );
  Project copyWithCompanion(ProjectsTableCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      name: data.name.present ? data.name.value : this.name,
      projectType: data.projectType.present
          ? data.projectType.value
          : this.projectType,
      commodity: data.commodity.present ? data.commodity.value : this.commodity,
      variety: data.variety.present ? data.variety.value : this.variety,
      landSize: data.landSize.present ? data.landSize.value : this.landSize,
      landUnit: data.landUnit.present ? data.landUnit.value : this.landUnit,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      expectedCompletionDate: data.expectedCompletionDate.present
          ? data.expectedCompletionDate.value
          : this.expectedCompletionDate,
      expectedFirstHarvestDate: data.expectedFirstHarvestDate.present
          ? data.expectedFirstHarvestDate.value
          : this.expectedFirstHarvestDate,
      currency: data.currency.present ? data.currency.value : this.currency,
      status: data.status.present ? data.status.value : this.status,
      description: data.description.present
          ? data.description.value
          : this.description,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('projectType: $projectType, ')
          ..write('commodity: $commodity, ')
          ..write('variety: $variety, ')
          ..write('landSize: $landSize, ')
          ..write('landUnit: $landUnit, ')
          ..write('startDate: $startDate, ')
          ..write('expectedCompletionDate: $expectedCompletionDate, ')
          ..write('expectedFirstHarvestDate: $expectedFirstHarvestDate, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    farmId,
    name,
    projectType,
    commodity,
    variety,
    landSize,
    landUnit,
    startDate,
    expectedCompletionDate,
    expectedFirstHarvestDate,
    currency,
    status,
    description,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.farmId == this.farmId &&
          other.name == this.name &&
          other.projectType == this.projectType &&
          other.commodity == this.commodity &&
          other.variety == this.variety &&
          other.landSize == this.landSize &&
          other.landUnit == this.landUnit &&
          other.startDate == this.startDate &&
          other.expectedCompletionDate == this.expectedCompletionDate &&
          other.expectedFirstHarvestDate == this.expectedFirstHarvestDate &&
          other.currency == this.currency &&
          other.status == this.status &&
          other.description == this.description &&
          other.notes == this.notes);
}

class ProjectsTableCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> farmId;
  final Value<String> name;
  final Value<String> projectType;
  final Value<String> commodity;
  final Value<String?> variety;
  final Value<double> landSize;
  final Value<String> landUnit;
  final Value<int> startDate;
  final Value<int?> expectedCompletionDate;
  final Value<int?> expectedFirstHarvestDate;
  final Value<String> currency;
  final Value<String> status;
  final Value<String?> description;
  final Value<String?> notes;
  final Value<int> rowid;
  const ProjectsTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.farmId = const Value.absent(),
    this.name = const Value.absent(),
    this.projectType = const Value.absent(),
    this.commodity = const Value.absent(),
    this.variety = const Value.absent(),
    this.landSize = const Value.absent(),
    this.landUnit = const Value.absent(),
    this.startDate = const Value.absent(),
    this.expectedCompletionDate = const Value.absent(),
    this.expectedFirstHarvestDate = const Value.absent(),
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsTableCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String farmId,
    required String name,
    required String projectType,
    required String commodity,
    this.variety = const Value.absent(),
    required double landSize,
    this.landUnit = const Value.absent(),
    required int startDate,
    this.expectedCompletionDate = const Value.absent(),
    this.expectedFirstHarvestDate = const Value.absent(),
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       farmId = Value(farmId),
       name = Value(name),
       projectType = Value(projectType),
       commodity = Value(commodity),
       landSize = Value(landSize),
       startDate = Value(startDate);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? farmId,
    Expression<String>? name,
    Expression<String>? projectType,
    Expression<String>? commodity,
    Expression<String>? variety,
    Expression<double>? landSize,
    Expression<String>? landUnit,
    Expression<int>? startDate,
    Expression<int>? expectedCompletionDate,
    Expression<int>? expectedFirstHarvestDate,
    Expression<String>? currency,
    Expression<String>? status,
    Expression<String>? description,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (farmId != null) 'farm_id': farmId,
      if (name != null) 'name': name,
      if (projectType != null) 'project_type': projectType,
      if (commodity != null) 'commodity': commodity,
      if (variety != null) 'variety': variety,
      if (landSize != null) 'land_size': landSize,
      if (landUnit != null) 'land_unit': landUnit,
      if (startDate != null) 'start_date': startDate,
      if (expectedCompletionDate != null)
        'expected_completion_date': expectedCompletionDate,
      if (expectedFirstHarvestDate != null)
        'expected_first_harvest_date': expectedFirstHarvestDate,
      if (currency != null) 'currency': currency,
      if (status != null) 'status': status,
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsTableCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
    Value<String>? farmId,
    Value<String>? name,
    Value<String>? projectType,
    Value<String>? commodity,
    Value<String?>? variety,
    Value<double>? landSize,
    Value<String>? landUnit,
    Value<int>? startDate,
    Value<int?>? expectedCompletionDate,
    Value<int?>? expectedFirstHarvestDate,
    Value<String>? currency,
    Value<String>? status,
    Value<String?>? description,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return ProjectsTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      projectType: projectType ?? this.projectType,
      commodity: commodity ?? this.commodity,
      variety: variety ?? this.variety,
      landSize: landSize ?? this.landSize,
      landUnit: landUnit ?? this.landUnit,
      startDate: startDate ?? this.startDate,
      expectedCompletionDate:
          expectedCompletionDate ?? this.expectedCompletionDate,
      expectedFirstHarvestDate:
          expectedFirstHarvestDate ?? this.expectedFirstHarvestDate,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (projectType.present) {
      map['project_type'] = Variable<String>(projectType.value);
    }
    if (commodity.present) {
      map['commodity'] = Variable<String>(commodity.value);
    }
    if (variety.present) {
      map['variety'] = Variable<String>(variety.value);
    }
    if (landSize.present) {
      map['land_size'] = Variable<double>(landSize.value);
    }
    if (landUnit.present) {
      map['land_unit'] = Variable<String>(landUnit.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<int>(startDate.value);
    }
    if (expectedCompletionDate.present) {
      map['expected_completion_date'] = Variable<int>(
        expectedCompletionDate.value,
      );
    }
    if (expectedFirstHarvestDate.present) {
      map['expected_first_harvest_date'] = Variable<int>(
        expectedFirstHarvestDate.value,
      );
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('projectType: $projectType, ')
          ..write('commodity: $commodity, ')
          ..write('variety: $variety, ')
          ..write('landSize: $landSize, ')
          ..write('landUnit: $landUnit, ')
          ..write('startDate: $startDate, ')
          ..write('expectedCompletionDate: $expectedCompletionDate, ')
          ..write('expectedFirstHarvestDate: $expectedFirstHarvestDate, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetCategoriesTableTable extends BudgetCategoriesTable
    with TableInfo<$BudgetCategoriesTableTable, BudgetCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetCategoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSystemDefaultMeta = const VerificationMeta(
    'isSystemDefault',
  );
  @override
  late final GeneratedColumn<bool> isSystemDefault = GeneratedColumn<bool>(
    'is_system_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    name,
    description,
    iconName,
    isSystemDefault,
    displayOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('is_system_default')) {
      context.handle(
        _isSystemDefaultMeta,
        isSystemDefault.isAcceptableOrUnknown(
          data['is_system_default']!,
          _isSystemDefaultMeta,
        ),
      );
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      ),
      isSystemDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system_default'],
      )!,
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
    );
  }

  @override
  $BudgetCategoriesTableTable createAlias(String alias) {
    return $BudgetCategoriesTableTable(attachedDatabase, alias);
  }
}

class BudgetCategory extends DataClass implements Insertable<BudgetCategory> {
  /// Unique client-generated UUID v4 identifier.
  final String id;

  /// Creation timestamp in milliseconds since epoch (UTC).
  final int createdAt;

  /// Last modification timestamp in milliseconds since epoch (UTC).
  final int updatedAt;

  /// Whether this record has been confirmed and synchronized with cloud.
  final bool isSynced;

  /// Soft deletion tombstone for cloud replication.
  final bool isDeleted;
  final String name;
  final String? description;
  final String? iconName;
  final bool isSystemDefault;
  final int displayOrder;
  const BudgetCategory({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.isDeleted,
    required this.name,
    this.description,
    this.iconName,
    required this.isSystemDefault,
    required this.displayOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    map['is_system_default'] = Variable<bool>(isSystemDefault);
    map['display_order'] = Variable<int>(displayOrder);
    return map;
  }

  BudgetCategoriesTableCompanion toCompanion(bool nullToAbsent) {
    return BudgetCategoriesTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      isSystemDefault: Value(isSystemDefault),
      displayOrder: Value(displayOrder),
    );
  }

  factory BudgetCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetCategory(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      isSystemDefault: serializer.fromJson<bool>(json['isSystemDefault']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'iconName': serializer.toJson<String?>(iconName),
      'isSystemDefault': serializer.toJson<bool>(isSystemDefault),
      'displayOrder': serializer.toJson<int>(displayOrder),
    };
  }

  BudgetCategory copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> iconName = const Value.absent(),
    bool? isSystemDefault,
    int? displayOrder,
  }) => BudgetCategory(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    iconName: iconName.present ? iconName.value : this.iconName,
    isSystemDefault: isSystemDefault ?? this.isSystemDefault,
    displayOrder: displayOrder ?? this.displayOrder,
  );
  BudgetCategory copyWithCompanion(BudgetCategoriesTableCompanion data) {
    return BudgetCategory(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      isSystemDefault: data.isSystemDefault.present
          ? data.isSystemDefault.value
          : this.isSystemDefault,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetCategory(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('iconName: $iconName, ')
          ..write('isSystemDefault: $isSystemDefault, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    name,
    description,
    iconName,
    isSystemDefault,
    displayOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetCategory &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.name == this.name &&
          other.description == this.description &&
          other.iconName == this.iconName &&
          other.isSystemDefault == this.isSystemDefault &&
          other.displayOrder == this.displayOrder);
}

class BudgetCategoriesTableCompanion extends UpdateCompanion<BudgetCategory> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> iconName;
  final Value<bool> isSystemDefault;
  final Value<int> displayOrder;
  final Value<int> rowid;
  const BudgetCategoriesTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.iconName = const Value.absent(),
    this.isSystemDefault = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetCategoriesTableCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.iconName = const Value.absent(),
    this.isSystemDefault = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<BudgetCategory> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? iconName,
    Expression<bool>? isSystemDefault,
    Expression<int>? displayOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (iconName != null) 'icon_name': iconName,
      if (isSystemDefault != null) 'is_system_default': isSystemDefault,
      if (displayOrder != null) 'display_order': displayOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetCategoriesTableCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? iconName,
    Value<bool>? isSystemDefault,
    Value<int>? displayOrder,
    Value<int>? rowid,
  }) {
    return BudgetCategoriesTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      isSystemDefault: isSystemDefault ?? this.isSystemDefault,
      displayOrder: displayOrder ?? this.displayOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (isSystemDefault.present) {
      map['is_system_default'] = Variable<bool>(isSystemDefault.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetCategoriesTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('iconName: $iconName, ')
          ..write('isSystemDefault: $isSystemDefault, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetItemsTableTable extends BudgetItemsTable
    with TableInfo<$BudgetItemsTableTable, BudgetItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES budget_categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMinorMeta = const VerificationMeta(
    'unitCostMinor',
  );
  @override
  late final GeneratedColumn<int> unitCostMinor = GeneratedColumn<int>(
    'unit_cost_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedAmountMinorMeta =
      const VerificationMeta('plannedAmountMinor');
  @override
  late final GeneratedColumn<int> plannedAmountMinor = GeneratedColumn<int>(
    'planned_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GHS'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PLANNED'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    categoryId,
    name,
    description,
    quantity,
    unit,
    unitCostMinor,
    plannedAmountMinor,
    currency,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('unit_cost_minor')) {
      context.handle(
        _unitCostMinorMeta,
        unitCostMinor.isAcceptableOrUnknown(
          data['unit_cost_minor']!,
          _unitCostMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitCostMinorMeta);
    }
    if (data.containsKey('planned_amount_minor')) {
      context.handle(
        _plannedAmountMinorMeta,
        plannedAmountMinor.isAcceptableOrUnknown(
          data['planned_amount_minor']!,
          _plannedAmountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedAmountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      unitCostMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost_minor'],
      )!,
      plannedAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $BudgetItemsTableTable createAlias(String alias) {
    return $BudgetItemsTableTable(attachedDatabase, alias);
  }
}

class BudgetItem extends DataClass implements Insertable<BudgetItem> {
  /// Unique client-generated UUID v4 identifier.
  final String id;

  /// Creation timestamp in milliseconds since epoch (UTC).
  final int createdAt;

  /// Last modification timestamp in milliseconds since epoch (UTC).
  final int updatedAt;

  /// Whether this record has been confirmed and synchronized with cloud.
  final bool isSynced;

  /// Soft deletion tombstone for cloud replication.
  final bool isDeleted;
  final String projectId;
  final String categoryId;
  final String name;
  final String? description;
  final double quantity;
  final String unit;

  /// Stored as 64-bit integer minor currency units (Pesewas for GHS).
  final int unitCostMinor;

  /// quantity * unitCostMinor in minor units.
  final int plannedAmountMinor;
  final String currency;
  final String status;
  const BudgetItem({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.isDeleted,
    required this.projectId,
    required this.categoryId,
    required this.name,
    this.description,
    required this.quantity,
    required this.unit,
    required this.unitCostMinor,
    required this.plannedAmountMinor,
    required this.currency,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['project_id'] = Variable<String>(projectId);
    map['category_id'] = Variable<String>(categoryId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    map['unit_cost_minor'] = Variable<int>(unitCostMinor);
    map['planned_amount_minor'] = Variable<int>(plannedAmountMinor);
    map['currency'] = Variable<String>(currency);
    map['status'] = Variable<String>(status);
    return map;
  }

  BudgetItemsTableCompanion toCompanion(bool nullToAbsent) {
    return BudgetItemsTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      projectId: Value(projectId),
      categoryId: Value(categoryId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      quantity: Value(quantity),
      unit: Value(unit),
      unitCostMinor: Value(unitCostMinor),
      plannedAmountMinor: Value(plannedAmountMinor),
      currency: Value(currency),
      status: Value(status),
    );
  }

  factory BudgetItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetItem(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      projectId: serializer.fromJson<String>(json['projectId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      unitCostMinor: serializer.fromJson<int>(json['unitCostMinor']),
      plannedAmountMinor: serializer.fromJson<int>(json['plannedAmountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'projectId': serializer.toJson<String>(projectId),
      'categoryId': serializer.toJson<String>(categoryId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'unitCostMinor': serializer.toJson<int>(unitCostMinor),
      'plannedAmountMinor': serializer.toJson<int>(plannedAmountMinor),
      'currency': serializer.toJson<String>(currency),
      'status': serializer.toJson<String>(status),
    };
  }

  BudgetItem copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    String? projectId,
    String? categoryId,
    String? name,
    Value<String?> description = const Value.absent(),
    double? quantity,
    String? unit,
    int? unitCostMinor,
    int? plannedAmountMinor,
    String? currency,
    String? status,
  }) => BudgetItem(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
    projectId: projectId ?? this.projectId,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    unitCostMinor: unitCostMinor ?? this.unitCostMinor,
    plannedAmountMinor: plannedAmountMinor ?? this.plannedAmountMinor,
    currency: currency ?? this.currency,
    status: status ?? this.status,
  );
  BudgetItem copyWithCompanion(BudgetItemsTableCompanion data) {
    return BudgetItem(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      unitCostMinor: data.unitCostMinor.present
          ? data.unitCostMinor.value
          : this.unitCostMinor,
      plannedAmountMinor: data.plannedAmountMinor.present
          ? data.plannedAmountMinor.value
          : this.plannedAmountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetItem(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitCostMinor: $unitCostMinor, ')
          ..write('plannedAmountMinor: $plannedAmountMinor, ')
          ..write('currency: $currency, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    categoryId,
    name,
    description,
    quantity,
    unit,
    unitCostMinor,
    plannedAmountMinor,
    currency,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetItem &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.projectId == this.projectId &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.description == this.description &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.unitCostMinor == this.unitCostMinor &&
          other.plannedAmountMinor == this.plannedAmountMinor &&
          other.currency == this.currency &&
          other.status == this.status);
}

class BudgetItemsTableCompanion extends UpdateCompanion<BudgetItem> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> projectId;
  final Value<String> categoryId;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<int> unitCostMinor;
  final Value<int> plannedAmountMinor;
  final Value<String> currency;
  final Value<String> status;
  final Value<int> rowid;
  const BudgetItemsTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.projectId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitCostMinor = const Value.absent(),
    this.plannedAmountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetItemsTableCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String projectId,
    required String categoryId,
    required String name,
    this.description = const Value.absent(),
    required double quantity,
    required String unit,
    required int unitCostMinor,
    required int plannedAmountMinor,
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       projectId = Value(projectId),
       categoryId = Value(categoryId),
       name = Value(name),
       quantity = Value(quantity),
       unit = Value(unit),
       unitCostMinor = Value(unitCostMinor),
       plannedAmountMinor = Value(plannedAmountMinor);
  static Insertable<BudgetItem> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? projectId,
    Expression<String>? categoryId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<int>? unitCostMinor,
    Expression<int>? plannedAmountMinor,
    Expression<String>? currency,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (projectId != null) 'project_id': projectId,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (unitCostMinor != null) 'unit_cost_minor': unitCostMinor,
      if (plannedAmountMinor != null)
        'planned_amount_minor': plannedAmountMinor,
      if (currency != null) 'currency': currency,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetItemsTableCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
    Value<String>? projectId,
    Value<String>? categoryId,
    Value<String>? name,
    Value<String?>? description,
    Value<double>? quantity,
    Value<String>? unit,
    Value<int>? unitCostMinor,
    Value<int>? plannedAmountMinor,
    Value<String>? currency,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return BudgetItemsTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      projectId: projectId ?? this.projectId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitCostMinor: unitCostMinor ?? this.unitCostMinor,
      plannedAmountMinor: plannedAmountMinor ?? this.plannedAmountMinor,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (unitCostMinor.present) {
      map['unit_cost_minor'] = Variable<int>(unitCostMinor.value);
    }
    if (plannedAmountMinor.present) {
      map['planned_amount_minor'] = Variable<int>(plannedAmountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitCostMinor: $unitCostMinor, ')
          ..write('plannedAmountMinor: $plannedAmountMinor, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTableTable extends ExpensesTable
    with TableInfo<$ExpensesTableTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES budget_categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _budgetItemIdMeta = const VerificationMeta(
    'budgetItemId',
  );
  @override
  late final GeneratedColumn<String> budgetItemId = GeneratedColumn<String>(
    'budget_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES budget_items (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<int> transactionDate = GeneratedColumn<int>(
    'transaction_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitCostMinorMeta = const VerificationMeta(
    'unitCostMinor',
  );
  @override
  late final GeneratedColumn<int> unitCostMinor = GeneratedColumn<int>(
    'unit_cost_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GHS'),
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vendorNameMeta = const VerificationMeta(
    'vendorName',
  );
  @override
  late final GeneratedColumn<String> vendorName = GeneratedColumn<String>(
    'vendor_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptPhotoPathMeta = const VerificationMeta(
    'receiptPhotoPath',
  );
  @override
  late final GeneratedColumn<String> receiptPhotoPath = GeneratedColumn<String>(
    'receipt_photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isVoidedMeta = const VerificationMeta(
    'isVoided',
  );
  @override
  late final GeneratedColumn<bool> isVoided = GeneratedColumn<bool>(
    'is_voided',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_voided" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _voidedAtMeta = const VerificationMeta(
    'voidedAt',
  );
  @override
  late final GeneratedColumn<int> voidedAt = GeneratedColumn<int>(
    'voided_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    categoryId,
    budgetItemId,
    activityId,
    transactionDate,
    description,
    quantity,
    unit,
    unitCostMinor,
    amountMinor,
    currency,
    paymentMethod,
    vendorName,
    receiptPhotoPath,
    notes,
    isVoided,
    voidedAt,
    voidReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('budget_item_id')) {
      context.handle(
        _budgetItemIdMeta,
        budgetItemId.isAcceptableOrUnknown(
          data['budget_item_id']!,
          _budgetItemIdMeta,
        ),
      );
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('unit_cost_minor')) {
      context.handle(
        _unitCostMinorMeta,
        unitCostMinor.isAcceptableOrUnknown(
          data['unit_cost_minor']!,
          _unitCostMinorMeta,
        ),
      );
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('vendor_name')) {
      context.handle(
        _vendorNameMeta,
        vendorName.isAcceptableOrUnknown(data['vendor_name']!, _vendorNameMeta),
      );
    }
    if (data.containsKey('receipt_photo_path')) {
      context.handle(
        _receiptPhotoPathMeta,
        receiptPhotoPath.isAcceptableOrUnknown(
          data['receipt_photo_path']!,
          _receiptPhotoPathMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_voided')) {
      context.handle(
        _isVoidedMeta,
        isVoided.isAcceptableOrUnknown(data['is_voided']!, _isVoidedMeta),
      );
    }
    if (data.containsKey('voided_at')) {
      context.handle(
        _voidedAtMeta,
        voidedAt.isAcceptableOrUnknown(data['voided_at']!, _voidedAtMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      budgetItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_item_id'],
      ),
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      ),
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_date'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      unitCostMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost_minor'],
      ),
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      vendorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vendor_name'],
      ),
      receiptPhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_photo_path'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isVoided: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_voided'],
      )!,
      voidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}voided_at'],
      ),
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
    );
  }

  @override
  $ExpensesTableTable createAlias(String alias) {
    return $ExpensesTableTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  /// Unique client-generated UUID v4 identifier.
  final String id;

  /// Creation timestamp in milliseconds since epoch (UTC).
  final int createdAt;

  /// Last modification timestamp in milliseconds since epoch (UTC).
  final int updatedAt;

  /// Whether this record has been confirmed and synchronized with cloud.
  final bool isSynced;

  /// Soft deletion tombstone for cloud replication.
  final bool isDeleted;
  final String projectId;
  final String categoryId;
  final String? budgetItemId;
  final String? activityId;
  final int transactionDate;
  final String description;
  final double quantity;
  final String? unit;
  final int? unitCostMinor;

  /// Minor units (Pesewas for GHS).
  final int amountMinor;
  final String currency;
  final String paymentMethod;
  final String? vendorName;
  final String? receiptPhotoPath;
  final String? notes;

  /// Soft voiding flags preserving auditability.
  final bool isVoided;
  final int? voidedAt;
  final String? voidReason;
  const Expense({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.isDeleted,
    required this.projectId,
    required this.categoryId,
    this.budgetItemId,
    this.activityId,
    required this.transactionDate,
    required this.description,
    required this.quantity,
    this.unit,
    this.unitCostMinor,
    required this.amountMinor,
    required this.currency,
    required this.paymentMethod,
    this.vendorName,
    this.receiptPhotoPath,
    this.notes,
    required this.isVoided,
    this.voidedAt,
    this.voidReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['project_id'] = Variable<String>(projectId);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || budgetItemId != null) {
      map['budget_item_id'] = Variable<String>(budgetItemId);
    }
    if (!nullToAbsent || activityId != null) {
      map['activity_id'] = Variable<String>(activityId);
    }
    map['transaction_date'] = Variable<int>(transactionDate);
    map['description'] = Variable<String>(description);
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || unitCostMinor != null) {
      map['unit_cost_minor'] = Variable<int>(unitCostMinor);
    }
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || vendorName != null) {
      map['vendor_name'] = Variable<String>(vendorName);
    }
    if (!nullToAbsent || receiptPhotoPath != null) {
      map['receipt_photo_path'] = Variable<String>(receiptPhotoPath);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_voided'] = Variable<bool>(isVoided);
    if (!nullToAbsent || voidedAt != null) {
      map['voided_at'] = Variable<int>(voidedAt);
    }
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    return map;
  }

  ExpensesTableCompanion toCompanion(bool nullToAbsent) {
    return ExpensesTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      projectId: Value(projectId),
      categoryId: Value(categoryId),
      budgetItemId: budgetItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetItemId),
      activityId: activityId == null && nullToAbsent
          ? const Value.absent()
          : Value(activityId),
      transactionDate: Value(transactionDate),
      description: Value(description),
      quantity: Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      unitCostMinor: unitCostMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(unitCostMinor),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      paymentMethod: Value(paymentMethod),
      vendorName: vendorName == null && nullToAbsent
          ? const Value.absent()
          : Value(vendorName),
      receiptPhotoPath: receiptPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptPhotoPath),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isVoided: Value(isVoided),
      voidedAt: voidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedAt),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      projectId: serializer.fromJson<String>(json['projectId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      budgetItemId: serializer.fromJson<String?>(json['budgetItemId']),
      activityId: serializer.fromJson<String?>(json['activityId']),
      transactionDate: serializer.fromJson<int>(json['transactionDate']),
      description: serializer.fromJson<String>(json['description']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String?>(json['unit']),
      unitCostMinor: serializer.fromJson<int?>(json['unitCostMinor']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      vendorName: serializer.fromJson<String?>(json['vendorName']),
      receiptPhotoPath: serializer.fromJson<String?>(json['receiptPhotoPath']),
      notes: serializer.fromJson<String?>(json['notes']),
      isVoided: serializer.fromJson<bool>(json['isVoided']),
      voidedAt: serializer.fromJson<int?>(json['voidedAt']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'projectId': serializer.toJson<String>(projectId),
      'categoryId': serializer.toJson<String>(categoryId),
      'budgetItemId': serializer.toJson<String?>(budgetItemId),
      'activityId': serializer.toJson<String?>(activityId),
      'transactionDate': serializer.toJson<int>(transactionDate),
      'description': serializer.toJson<String>(description),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String?>(unit),
      'unitCostMinor': serializer.toJson<int?>(unitCostMinor),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'vendorName': serializer.toJson<String?>(vendorName),
      'receiptPhotoPath': serializer.toJson<String?>(receiptPhotoPath),
      'notes': serializer.toJson<String?>(notes),
      'isVoided': serializer.toJson<bool>(isVoided),
      'voidedAt': serializer.toJson<int?>(voidedAt),
      'voidReason': serializer.toJson<String?>(voidReason),
    };
  }

  Expense copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    String? projectId,
    String? categoryId,
    Value<String?> budgetItemId = const Value.absent(),
    Value<String?> activityId = const Value.absent(),
    int? transactionDate,
    String? description,
    double? quantity,
    Value<String?> unit = const Value.absent(),
    Value<int?> unitCostMinor = const Value.absent(),
    int? amountMinor,
    String? currency,
    String? paymentMethod,
    Value<String?> vendorName = const Value.absent(),
    Value<String?> receiptPhotoPath = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isVoided,
    Value<int?> voidedAt = const Value.absent(),
    Value<String?> voidReason = const Value.absent(),
  }) => Expense(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
    projectId: projectId ?? this.projectId,
    categoryId: categoryId ?? this.categoryId,
    budgetItemId: budgetItemId.present ? budgetItemId.value : this.budgetItemId,
    activityId: activityId.present ? activityId.value : this.activityId,
    transactionDate: transactionDate ?? this.transactionDate,
    description: description ?? this.description,
    quantity: quantity ?? this.quantity,
    unit: unit.present ? unit.value : this.unit,
    unitCostMinor: unitCostMinor.present
        ? unitCostMinor.value
        : this.unitCostMinor,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    vendorName: vendorName.present ? vendorName.value : this.vendorName,
    receiptPhotoPath: receiptPhotoPath.present
        ? receiptPhotoPath.value
        : this.receiptPhotoPath,
    notes: notes.present ? notes.value : this.notes,
    isVoided: isVoided ?? this.isVoided,
    voidedAt: voidedAt.present ? voidedAt.value : this.voidedAt,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
  );
  Expense copyWithCompanion(ExpensesTableCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      budgetItemId: data.budgetItemId.present
          ? data.budgetItemId.value
          : this.budgetItemId,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      description: data.description.present
          ? data.description.value
          : this.description,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      unitCostMinor: data.unitCostMinor.present
          ? data.unitCostMinor.value
          : this.unitCostMinor,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      vendorName: data.vendorName.present
          ? data.vendorName.value
          : this.vendorName,
      receiptPhotoPath: data.receiptPhotoPath.present
          ? data.receiptPhotoPath.value
          : this.receiptPhotoPath,
      notes: data.notes.present ? data.notes.value : this.notes,
      isVoided: data.isVoided.present ? data.isVoided.value : this.isVoided,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('categoryId: $categoryId, ')
          ..write('budgetItemId: $budgetItemId, ')
          ..write('activityId: $activityId, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitCostMinor: $unitCostMinor, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('vendorName: $vendorName, ')
          ..write('receiptPhotoPath: $receiptPhotoPath, ')
          ..write('notes: $notes, ')
          ..write('isVoided: $isVoided, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    categoryId,
    budgetItemId,
    activityId,
    transactionDate,
    description,
    quantity,
    unit,
    unitCostMinor,
    amountMinor,
    currency,
    paymentMethod,
    vendorName,
    receiptPhotoPath,
    notes,
    isVoided,
    voidedAt,
    voidReason,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.projectId == this.projectId &&
          other.categoryId == this.categoryId &&
          other.budgetItemId == this.budgetItemId &&
          other.activityId == this.activityId &&
          other.transactionDate == this.transactionDate &&
          other.description == this.description &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.unitCostMinor == this.unitCostMinor &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.paymentMethod == this.paymentMethod &&
          other.vendorName == this.vendorName &&
          other.receiptPhotoPath == this.receiptPhotoPath &&
          other.notes == this.notes &&
          other.isVoided == this.isVoided &&
          other.voidedAt == this.voidedAt &&
          other.voidReason == this.voidReason);
}

class ExpensesTableCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> projectId;
  final Value<String> categoryId;
  final Value<String?> budgetItemId;
  final Value<String?> activityId;
  final Value<int> transactionDate;
  final Value<String> description;
  final Value<double> quantity;
  final Value<String?> unit;
  final Value<int?> unitCostMinor;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String> paymentMethod;
  final Value<String?> vendorName;
  final Value<String?> receiptPhotoPath;
  final Value<String?> notes;
  final Value<bool> isVoided;
  final Value<int?> voidedAt;
  final Value<String?> voidReason;
  final Value<int> rowid;
  const ExpensesTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.projectId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.budgetItemId = const Value.absent(),
    this.activityId = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.description = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitCostMinor = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.vendorName = const Value.absent(),
    this.receiptPhotoPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.isVoided = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesTableCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String projectId,
    required String categoryId,
    this.budgetItemId = const Value.absent(),
    this.activityId = const Value.absent(),
    required int transactionDate,
    required String description,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitCostMinor = const Value.absent(),
    required int amountMinor,
    this.currency = const Value.absent(),
    required String paymentMethod,
    this.vendorName = const Value.absent(),
    this.receiptPhotoPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.isVoided = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       projectId = Value(projectId),
       categoryId = Value(categoryId),
       transactionDate = Value(transactionDate),
       description = Value(description),
       amountMinor = Value(amountMinor),
       paymentMethod = Value(paymentMethod);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? projectId,
    Expression<String>? categoryId,
    Expression<String>? budgetItemId,
    Expression<String>? activityId,
    Expression<int>? transactionDate,
    Expression<String>? description,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<int>? unitCostMinor,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? paymentMethod,
    Expression<String>? vendorName,
    Expression<String>? receiptPhotoPath,
    Expression<String>? notes,
    Expression<bool>? isVoided,
    Expression<int>? voidedAt,
    Expression<String>? voidReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (projectId != null) 'project_id': projectId,
      if (categoryId != null) 'category_id': categoryId,
      if (budgetItemId != null) 'budget_item_id': budgetItemId,
      if (activityId != null) 'activity_id': activityId,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (description != null) 'description': description,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (unitCostMinor != null) 'unit_cost_minor': unitCostMinor,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (vendorName != null) 'vendor_name': vendorName,
      if (receiptPhotoPath != null) 'receipt_photo_path': receiptPhotoPath,
      if (notes != null) 'notes': notes,
      if (isVoided != null) 'is_voided': isVoided,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (voidReason != null) 'void_reason': voidReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesTableCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
    Value<String>? projectId,
    Value<String>? categoryId,
    Value<String?>? budgetItemId,
    Value<String?>? activityId,
    Value<int>? transactionDate,
    Value<String>? description,
    Value<double>? quantity,
    Value<String?>? unit,
    Value<int?>? unitCostMinor,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String>? paymentMethod,
    Value<String?>? vendorName,
    Value<String?>? receiptPhotoPath,
    Value<String?>? notes,
    Value<bool>? isVoided,
    Value<int?>? voidedAt,
    Value<String?>? voidReason,
    Value<int>? rowid,
  }) {
    return ExpensesTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      projectId: projectId ?? this.projectId,
      categoryId: categoryId ?? this.categoryId,
      budgetItemId: budgetItemId ?? this.budgetItemId,
      activityId: activityId ?? this.activityId,
      transactionDate: transactionDate ?? this.transactionDate,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitCostMinor: unitCostMinor ?? this.unitCostMinor,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      vendorName: vendorName ?? this.vendorName,
      receiptPhotoPath: receiptPhotoPath ?? this.receiptPhotoPath,
      notes: notes ?? this.notes,
      isVoided: isVoided ?? this.isVoided,
      voidedAt: voidedAt ?? this.voidedAt,
      voidReason: voidReason ?? this.voidReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (budgetItemId.present) {
      map['budget_item_id'] = Variable<String>(budgetItemId.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<int>(transactionDate.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (unitCostMinor.present) {
      map['unit_cost_minor'] = Variable<int>(unitCostMinor.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (vendorName.present) {
      map['vendor_name'] = Variable<String>(vendorName.value);
    }
    if (receiptPhotoPath.present) {
      map['receipt_photo_path'] = Variable<String>(receiptPhotoPath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isVoided.present) {
      map['is_voided'] = Variable<bool>(isVoided.value);
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<int>(voidedAt.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('categoryId: $categoryId, ')
          ..write('budgetItemId: $budgetItemId, ')
          ..write('activityId: $activityId, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitCostMinor: $unitCostMinor, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('vendorName: $vendorName, ')
          ..write('receiptPhotoPath: $receiptPhotoPath, ')
          ..write('notes: $notes, ')
          ..write('isVoided: $isVoided, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTableTable extends ActivitiesTable
    with TableInfo<$ActivitiesTableTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _activityTypeMeta = const VerificationMeta(
    'activityType',
  );
  @override
  late final GeneratedColumn<String> activityType = GeneratedColumn<String>(
    'activity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityDateMeta = const VerificationMeta(
    'activityDate',
  );
  @override
  late final GeneratedColumn<int> activityDate = GeneratedColumn<int>(
    'activity_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labourCountMeta = const VerificationMeta(
    'labourCount',
  );
  @override
  late final GeneratedColumn<int> labourCount = GeneratedColumn<int>(
    'labour_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationHoursMeta = const VerificationMeta(
    'durationHours',
  );
  @override
  late final GeneratedColumn<double> durationHours = GeneratedColumn<double>(
    'duration_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costMinorMeta = const VerificationMeta(
    'costMinor',
  );
  @override
  late final GeneratedColumn<int> costMinor = GeneratedColumn<int>(
    'cost_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GHS'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('COMPLETED'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    activityType,
    title,
    activityDate,
    description,
    labourCount,
    durationHours,
    costMinor,
    currency,
    status,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Activity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('activity_type')) {
      context.handle(
        _activityTypeMeta,
        activityType.isAcceptableOrUnknown(
          data['activity_type']!,
          _activityTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('activity_date')) {
      context.handle(
        _activityDateMeta,
        activityDate.isAcceptableOrUnknown(
          data['activity_date']!,
          _activityDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityDateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('labour_count')) {
      context.handle(
        _labourCountMeta,
        labourCount.isAcceptableOrUnknown(
          data['labour_count']!,
          _labourCountMeta,
        ),
      );
    }
    if (data.containsKey('duration_hours')) {
      context.handle(
        _durationHoursMeta,
        durationHours.isAcceptableOrUnknown(
          data['duration_hours']!,
          _durationHoursMeta,
        ),
      );
    }
    if (data.containsKey('cost_minor')) {
      context.handle(
        _costMinorMeta,
        costMinor.isAcceptableOrUnknown(data['cost_minor']!, _costMinorMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      activityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      activityDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activity_date'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      labourCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}labour_count'],
      )!,
      durationHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}duration_hours'],
      ),
      costMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ActivitiesTableTable createAlias(String alias) {
    return $ActivitiesTableTable(attachedDatabase, alias);
  }
}

class Activity extends DataClass implements Insertable<Activity> {
  /// Unique client-generated UUID v4 identifier.
  final String id;

  /// Creation timestamp in milliseconds since epoch (UTC).
  final int createdAt;

  /// Last modification timestamp in milliseconds since epoch (UTC).
  final int updatedAt;

  /// Whether this record has been confirmed and synchronized with cloud.
  final bool isSynced;

  /// Soft deletion tombstone for cloud replication.
  final bool isDeleted;
  final String projectId;
  final String activityType;
  final String title;
  final int activityDate;
  final String? description;
  final int labourCount;
  final double? durationHours;
  final int costMinor;
  final String currency;
  final String status;
  final String? notes;
  const Activity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.isDeleted,
    required this.projectId,
    required this.activityType,
    required this.title,
    required this.activityDate,
    this.description,
    required this.labourCount,
    this.durationHours,
    required this.costMinor,
    required this.currency,
    required this.status,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['project_id'] = Variable<String>(projectId);
    map['activity_type'] = Variable<String>(activityType);
    map['title'] = Variable<String>(title);
    map['activity_date'] = Variable<int>(activityDate);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['labour_count'] = Variable<int>(labourCount);
    if (!nullToAbsent || durationHours != null) {
      map['duration_hours'] = Variable<double>(durationHours);
    }
    map['cost_minor'] = Variable<int>(costMinor);
    map['currency'] = Variable<String>(currency);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ActivitiesTableCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      projectId: Value(projectId),
      activityType: Value(activityType),
      title: Value(title),
      activityDate: Value(activityDate),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      labourCount: Value(labourCount),
      durationHours: durationHours == null && nullToAbsent
          ? const Value.absent()
          : Value(durationHours),
      costMinor: Value(costMinor),
      currency: Value(currency),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Activity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      projectId: serializer.fromJson<String>(json['projectId']),
      activityType: serializer.fromJson<String>(json['activityType']),
      title: serializer.fromJson<String>(json['title']),
      activityDate: serializer.fromJson<int>(json['activityDate']),
      description: serializer.fromJson<String?>(json['description']),
      labourCount: serializer.fromJson<int>(json['labourCount']),
      durationHours: serializer.fromJson<double?>(json['durationHours']),
      costMinor: serializer.fromJson<int>(json['costMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'projectId': serializer.toJson<String>(projectId),
      'activityType': serializer.toJson<String>(activityType),
      'title': serializer.toJson<String>(title),
      'activityDate': serializer.toJson<int>(activityDate),
      'description': serializer.toJson<String?>(description),
      'labourCount': serializer.toJson<int>(labourCount),
      'durationHours': serializer.toJson<double?>(durationHours),
      'costMinor': serializer.toJson<int>(costMinor),
      'currency': serializer.toJson<String>(currency),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Activity copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    String? projectId,
    String? activityType,
    String? title,
    int? activityDate,
    Value<String?> description = const Value.absent(),
    int? labourCount,
    Value<double?> durationHours = const Value.absent(),
    int? costMinor,
    String? currency,
    String? status,
    Value<String?> notes = const Value.absent(),
  }) => Activity(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
    projectId: projectId ?? this.projectId,
    activityType: activityType ?? this.activityType,
    title: title ?? this.title,
    activityDate: activityDate ?? this.activityDate,
    description: description.present ? description.value : this.description,
    labourCount: labourCount ?? this.labourCount,
    durationHours: durationHours.present
        ? durationHours.value
        : this.durationHours,
    costMinor: costMinor ?? this.costMinor,
    currency: currency ?? this.currency,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
  );
  Activity copyWithCompanion(ActivitiesTableCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      title: data.title.present ? data.title.value : this.title,
      activityDate: data.activityDate.present
          ? data.activityDate.value
          : this.activityDate,
      description: data.description.present
          ? data.description.value
          : this.description,
      labourCount: data.labourCount.present
          ? data.labourCount.value
          : this.labourCount,
      durationHours: data.durationHours.present
          ? data.durationHours.value
          : this.durationHours,
      costMinor: data.costMinor.present ? data.costMinor.value : this.costMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('activityType: $activityType, ')
          ..write('title: $title, ')
          ..write('activityDate: $activityDate, ')
          ..write('description: $description, ')
          ..write('labourCount: $labourCount, ')
          ..write('durationHours: $durationHours, ')
          ..write('costMinor: $costMinor, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    activityType,
    title,
    activityDate,
    description,
    labourCount,
    durationHours,
    costMinor,
    currency,
    status,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.projectId == this.projectId &&
          other.activityType == this.activityType &&
          other.title == this.title &&
          other.activityDate == this.activityDate &&
          other.description == this.description &&
          other.labourCount == this.labourCount &&
          other.durationHours == this.durationHours &&
          other.costMinor == this.costMinor &&
          other.currency == this.currency &&
          other.status == this.status &&
          other.notes == this.notes);
}

class ActivitiesTableCompanion extends UpdateCompanion<Activity> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> projectId;
  final Value<String> activityType;
  final Value<String> title;
  final Value<int> activityDate;
  final Value<String?> description;
  final Value<int> labourCount;
  final Value<double?> durationHours;
  final Value<int> costMinor;
  final Value<String> currency;
  final Value<String> status;
  final Value<String?> notes;
  final Value<int> rowid;
  const ActivitiesTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.projectId = const Value.absent(),
    this.activityType = const Value.absent(),
    this.title = const Value.absent(),
    this.activityDate = const Value.absent(),
    this.description = const Value.absent(),
    this.labourCount = const Value.absent(),
    this.durationHours = const Value.absent(),
    this.costMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesTableCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String projectId,
    required String activityType,
    required String title,
    required int activityDate,
    this.description = const Value.absent(),
    this.labourCount = const Value.absent(),
    this.durationHours = const Value.absent(),
    this.costMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       projectId = Value(projectId),
       activityType = Value(activityType),
       title = Value(title),
       activityDate = Value(activityDate);
  static Insertable<Activity> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? projectId,
    Expression<String>? activityType,
    Expression<String>? title,
    Expression<int>? activityDate,
    Expression<String>? description,
    Expression<int>? labourCount,
    Expression<double>? durationHours,
    Expression<int>? costMinor,
    Expression<String>? currency,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (projectId != null) 'project_id': projectId,
      if (activityType != null) 'activity_type': activityType,
      if (title != null) 'title': title,
      if (activityDate != null) 'activity_date': activityDate,
      if (description != null) 'description': description,
      if (labourCount != null) 'labour_count': labourCount,
      if (durationHours != null) 'duration_hours': durationHours,
      if (costMinor != null) 'cost_minor': costMinor,
      if (currency != null) 'currency': currency,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesTableCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
    Value<String>? projectId,
    Value<String>? activityType,
    Value<String>? title,
    Value<int>? activityDate,
    Value<String?>? description,
    Value<int>? labourCount,
    Value<double?>? durationHours,
    Value<int>? costMinor,
    Value<String>? currency,
    Value<String>? status,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return ActivitiesTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      projectId: projectId ?? this.projectId,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      activityDate: activityDate ?? this.activityDate,
      description: description ?? this.description,
      labourCount: labourCount ?? this.labourCount,
      durationHours: durationHours ?? this.durationHours,
      costMinor: costMinor ?? this.costMinor,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(activityType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (activityDate.present) {
      map['activity_date'] = Variable<int>(activityDate.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (labourCount.present) {
      map['labour_count'] = Variable<int>(labourCount.value);
    }
    if (durationHours.present) {
      map['duration_hours'] = Variable<double>(durationHours.value);
    }
    if (costMinor.present) {
      map['cost_minor'] = Variable<int>(costMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('activityType: $activityType, ')
          ..write('title: $title, ')
          ..write('activityDate: $activityDate, ')
          ..write('description: $description, ')
          ..write('labourCount: $labourCount, ')
          ..write('durationHours: $durationHours, ')
          ..write('costMinor: $costMinor, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HarvestsTableTable extends HarvestsTable
    with TableInfo<$HarvestsTableTable, Harvest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HarvestsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _batchNumberMeta = const VerificationMeta(
    'batchNumber',
  );
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
    'batch_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _harvestDateMeta = const VerificationMeta(
    'harvestDate',
  );
  @override
  late final GeneratedColumn<int> harvestDate = GeneratedColumn<int>(
    'harvest_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storageLocationMeta = const VerificationMeta(
    'storageLocation',
  );
  @override
  late final GeneratedColumn<String> storageLocation = GeneratedColumn<String>(
    'storage_location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    batchNumber,
    harvestDate,
    productName,
    quantity,
    unit,
    grade,
    storageLocation,
    notes,
    photoPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'harvests';
  @override
  VerificationContext validateIntegrity(
    Insertable<Harvest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('batch_number')) {
      context.handle(
        _batchNumberMeta,
        batchNumber.isAcceptableOrUnknown(
          data['batch_number']!,
          _batchNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_batchNumberMeta);
    }
    if (data.containsKey('harvest_date')) {
      context.handle(
        _harvestDateMeta,
        harvestDate.isAcceptableOrUnknown(
          data['harvest_date']!,
          _harvestDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_harvestDateMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('storage_location')) {
      context.handle(
        _storageLocationMeta,
        storageLocation.isAcceptableOrUnknown(
          data['storage_location']!,
          _storageLocationMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Harvest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Harvest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      batchNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_number'],
      )!,
      harvestDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}harvest_date'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      ),
      storageLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_location'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
    );
  }

  @override
  $HarvestsTableTable createAlias(String alias) {
    return $HarvestsTableTable(attachedDatabase, alias);
  }
}

class Harvest extends DataClass implements Insertable<Harvest> {
  /// Unique client-generated UUID v4 identifier.
  final String id;

  /// Creation timestamp in milliseconds since epoch (UTC).
  final int createdAt;

  /// Last modification timestamp in milliseconds since epoch (UTC).
  final int updatedAt;

  /// Whether this record has been confirmed and synchronized with cloud.
  final bool isSynced;

  /// Soft deletion tombstone for cloud replication.
  final bool isDeleted;
  final String projectId;
  final String batchNumber;
  final int harvestDate;
  final String productName;
  final double quantity;
  final String unit;
  final String? grade;
  final String? storageLocation;
  final String? notes;
  final String? photoPath;
  const Harvest({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.isDeleted,
    required this.projectId,
    required this.batchNumber,
    required this.harvestDate,
    required this.productName,
    required this.quantity,
    required this.unit,
    this.grade,
    this.storageLocation,
    this.notes,
    this.photoPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['project_id'] = Variable<String>(projectId);
    map['batch_number'] = Variable<String>(batchNumber);
    map['harvest_date'] = Variable<int>(harvestDate);
    map['product_name'] = Variable<String>(productName);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<String>(grade);
    }
    if (!nullToAbsent || storageLocation != null) {
      map['storage_location'] = Variable<String>(storageLocation);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    return map;
  }

  HarvestsTableCompanion toCompanion(bool nullToAbsent) {
    return HarvestsTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      projectId: Value(projectId),
      batchNumber: Value(batchNumber),
      harvestDate: Value(harvestDate),
      productName: Value(productName),
      quantity: Value(quantity),
      unit: Value(unit),
      grade: grade == null && nullToAbsent
          ? const Value.absent()
          : Value(grade),
      storageLocation: storageLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(storageLocation),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
    );
  }

  factory Harvest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Harvest(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      projectId: serializer.fromJson<String>(json['projectId']),
      batchNumber: serializer.fromJson<String>(json['batchNumber']),
      harvestDate: serializer.fromJson<int>(json['harvestDate']),
      productName: serializer.fromJson<String>(json['productName']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      grade: serializer.fromJson<String?>(json['grade']),
      storageLocation: serializer.fromJson<String?>(json['storageLocation']),
      notes: serializer.fromJson<String?>(json['notes']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'projectId': serializer.toJson<String>(projectId),
      'batchNumber': serializer.toJson<String>(batchNumber),
      'harvestDate': serializer.toJson<int>(harvestDate),
      'productName': serializer.toJson<String>(productName),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'grade': serializer.toJson<String?>(grade),
      'storageLocation': serializer.toJson<String?>(storageLocation),
      'notes': serializer.toJson<String?>(notes),
      'photoPath': serializer.toJson<String?>(photoPath),
    };
  }

  Harvest copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    String? projectId,
    String? batchNumber,
    int? harvestDate,
    String? productName,
    double? quantity,
    String? unit,
    Value<String?> grade = const Value.absent(),
    Value<String?> storageLocation = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
  }) => Harvest(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
    projectId: projectId ?? this.projectId,
    batchNumber: batchNumber ?? this.batchNumber,
    harvestDate: harvestDate ?? this.harvestDate,
    productName: productName ?? this.productName,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    grade: grade.present ? grade.value : this.grade,
    storageLocation: storageLocation.present
        ? storageLocation.value
        : this.storageLocation,
    notes: notes.present ? notes.value : this.notes,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
  );
  Harvest copyWithCompanion(HarvestsTableCompanion data) {
    return Harvest(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      batchNumber: data.batchNumber.present
          ? data.batchNumber.value
          : this.batchNumber,
      harvestDate: data.harvestDate.present
          ? data.harvestDate.value
          : this.harvestDate,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      grade: data.grade.present ? data.grade.value : this.grade,
      storageLocation: data.storageLocation.present
          ? data.storageLocation.value
          : this.storageLocation,
      notes: data.notes.present ? data.notes.value : this.notes,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Harvest(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('harvestDate: $harvestDate, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('grade: $grade, ')
          ..write('storageLocation: $storageLocation, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    batchNumber,
    harvestDate,
    productName,
    quantity,
    unit,
    grade,
    storageLocation,
    notes,
    photoPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Harvest &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.projectId == this.projectId &&
          other.batchNumber == this.batchNumber &&
          other.harvestDate == this.harvestDate &&
          other.productName == this.productName &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.grade == this.grade &&
          other.storageLocation == this.storageLocation &&
          other.notes == this.notes &&
          other.photoPath == this.photoPath);
}

class HarvestsTableCompanion extends UpdateCompanion<Harvest> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> projectId;
  final Value<String> batchNumber;
  final Value<int> harvestDate;
  final Value<String> productName;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<String?> grade;
  final Value<String?> storageLocation;
  final Value<String?> notes;
  final Value<String?> photoPath;
  final Value<int> rowid;
  const HarvestsTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.projectId = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.harvestDate = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.grade = const Value.absent(),
    this.storageLocation = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HarvestsTableCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String projectId,
    required String batchNumber,
    required int harvestDate,
    required String productName,
    required double quantity,
    required String unit,
    this.grade = const Value.absent(),
    this.storageLocation = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       projectId = Value(projectId),
       batchNumber = Value(batchNumber),
       harvestDate = Value(harvestDate),
       productName = Value(productName),
       quantity = Value(quantity),
       unit = Value(unit);
  static Insertable<Harvest> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? projectId,
    Expression<String>? batchNumber,
    Expression<int>? harvestDate,
    Expression<String>? productName,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<String>? grade,
    Expression<String>? storageLocation,
    Expression<String>? notes,
    Expression<String>? photoPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (projectId != null) 'project_id': projectId,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (harvestDate != null) 'harvest_date': harvestDate,
      if (productName != null) 'product_name': productName,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (grade != null) 'grade': grade,
      if (storageLocation != null) 'storage_location': storageLocation,
      if (notes != null) 'notes': notes,
      if (photoPath != null) 'photo_path': photoPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HarvestsTableCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
    Value<String>? projectId,
    Value<String>? batchNumber,
    Value<int>? harvestDate,
    Value<String>? productName,
    Value<double>? quantity,
    Value<String>? unit,
    Value<String?>? grade,
    Value<String?>? storageLocation,
    Value<String?>? notes,
    Value<String?>? photoPath,
    Value<int>? rowid,
  }) {
    return HarvestsTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      projectId: projectId ?? this.projectId,
      batchNumber: batchNumber ?? this.batchNumber,
      harvestDate: harvestDate ?? this.harvestDate,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      grade: grade ?? this.grade,
      storageLocation: storageLocation ?? this.storageLocation,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (harvestDate.present) {
      map['harvest_date'] = Variable<int>(harvestDate.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (storageLocation.present) {
      map['storage_location'] = Variable<String>(storageLocation.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HarvestsTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('harvestDate: $harvestDate, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('grade: $grade, ')
          ..write('storageLocation: $storageLocation, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BuyersTableTable extends BuyersTable
    with TableInfo<$BuyersTableTable, Buyer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuyersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _businessNameMeta = const VerificationMeta(
    'businessName',
  );
  @override
  late final GeneratedColumn<String> businessName = GeneratedColumn<String>(
    'business_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    name,
    phone,
    businessName,
    location,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'buyers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Buyer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('business_name')) {
      context.handle(
        _businessNameMeta,
        businessName.isAcceptableOrUnknown(
          data['business_name']!,
          _businessNameMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Buyer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Buyer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      businessName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_name'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $BuyersTableTable createAlias(String alias) {
    return $BuyersTableTable(attachedDatabase, alias);
  }
}

class Buyer extends DataClass implements Insertable<Buyer> {
  /// Unique client-generated UUID v4 identifier.
  final String id;

  /// Creation timestamp in milliseconds since epoch (UTC).
  final int createdAt;

  /// Last modification timestamp in milliseconds since epoch (UTC).
  final int updatedAt;

  /// Whether this record has been confirmed and synchronized with cloud.
  final bool isSynced;

  /// Soft deletion tombstone for cloud replication.
  final bool isDeleted;
  final String name;
  final String? phone;
  final String? businessName;
  final String? location;
  final String? notes;
  const Buyer({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.isDeleted,
    required this.name,
    this.phone,
    this.businessName,
    this.location,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || businessName != null) {
      map['business_name'] = Variable<String>(businessName);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  BuyersTableCompanion toCompanion(bool nullToAbsent) {
    return BuyersTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      businessName: businessName == null && nullToAbsent
          ? const Value.absent()
          : Value(businessName),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Buyer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Buyer(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      businessName: serializer.fromJson<String?>(json['businessName']),
      location: serializer.fromJson<String?>(json['location']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'businessName': serializer.toJson<String?>(businessName),
      'location': serializer.toJson<String?>(location),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Buyer copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> businessName = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => Buyer(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    businessName: businessName.present ? businessName.value : this.businessName,
    location: location.present ? location.value : this.location,
    notes: notes.present ? notes.value : this.notes,
  );
  Buyer copyWithCompanion(BuyersTableCompanion data) {
    return Buyer(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      businessName: data.businessName.present
          ? data.businessName.value
          : this.businessName,
      location: data.location.present ? data.location.value : this.location,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Buyer(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('businessName: $businessName, ')
          ..write('location: $location, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    name,
    phone,
    businessName,
    location,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Buyer &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.businessName == this.businessName &&
          other.location == this.location &&
          other.notes == this.notes);
}

class BuyersTableCompanion extends UpdateCompanion<Buyer> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> businessName;
  final Value<String?> location;
  final Value<String?> notes;
  final Value<int> rowid;
  const BuyersTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.businessName = const Value.absent(),
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BuyersTableCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.businessName = const Value.absent(),
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<Buyer> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? businessName,
    Expression<String>? location,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (businessName != null) 'business_name': businessName,
      if (location != null) 'location': location,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BuyersTableCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? businessName,
    Value<String?>? location,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return BuyersTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (businessName.present) {
      map['business_name'] = Variable<String>(businessName.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuyersTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('businessName: $businessName, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTableTable extends SalesTable
    with TableInfo<$SalesTableTable, Sale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _buyerIdMeta = const VerificationMeta(
    'buyerId',
  );
  @override
  late final GeneratedColumn<String> buyerId = GeneratedColumn<String>(
    'buyer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES buyers (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _harvestIdMeta = const VerificationMeta(
    'harvestId',
  );
  @override
  late final GeneratedColumn<String> harvestId = GeneratedColumn<String>(
    'harvest_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES harvests (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _saleDateMeta = const VerificationMeta(
    'saleDate',
  );
  @override
  late final GeneratedColumn<int> saleDate = GeneratedColumn<int>(
    'sale_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMinorMeta = const VerificationMeta(
    'unitPriceMinor',
  );
  @override
  late final GeneratedColumn<int> unitPriceMinor = GeneratedColumn<int>(
    'unit_price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMinorMeta = const VerificationMeta(
    'totalAmountMinor',
  );
  @override
  late final GeneratedColumn<int> totalAmountMinor = GeneratedColumn<int>(
    'total_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GHS'),
  );
  static const VerificationMeta _paymentStatusMeta = const VerificationMeta(
    'paymentStatus',
  );
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
    'payment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UNPAID'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isVoidedMeta = const VerificationMeta(
    'isVoided',
  );
  @override
  late final GeneratedColumn<bool> isVoided = GeneratedColumn<bool>(
    'is_voided',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_voided" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _voidedAtMeta = const VerificationMeta(
    'voidedAt',
  );
  @override
  late final GeneratedColumn<int> voidedAt = GeneratedColumn<int>(
    'voided_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    buyerId,
    harvestId,
    saleDate,
    productName,
    quantity,
    unit,
    unitPriceMinor,
    totalAmountMinor,
    currency,
    paymentStatus,
    notes,
    isVoided,
    voidedAt,
    voidReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('buyer_id')) {
      context.handle(
        _buyerIdMeta,
        buyerId.isAcceptableOrUnknown(data['buyer_id']!, _buyerIdMeta),
      );
    }
    if (data.containsKey('harvest_id')) {
      context.handle(
        _harvestIdMeta,
        harvestId.isAcceptableOrUnknown(data['harvest_id']!, _harvestIdMeta),
      );
    }
    if (data.containsKey('sale_date')) {
      context.handle(
        _saleDateMeta,
        saleDate.isAcceptableOrUnknown(data['sale_date']!, _saleDateMeta),
      );
    } else if (isInserting) {
      context.missing(_saleDateMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('unit_price_minor')) {
      context.handle(
        _unitPriceMinorMeta,
        unitPriceMinor.isAcceptableOrUnknown(
          data['unit_price_minor']!,
          _unitPriceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMinorMeta);
    }
    if (data.containsKey('total_amount_minor')) {
      context.handle(
        _totalAmountMinorMeta,
        totalAmountMinor.isAcceptableOrUnknown(
          data['total_amount_minor']!,
          _totalAmountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('payment_status')) {
      context.handle(
        _paymentStatusMeta,
        paymentStatus.isAcceptableOrUnknown(
          data['payment_status']!,
          _paymentStatusMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_voided')) {
      context.handle(
        _isVoidedMeta,
        isVoided.isAcceptableOrUnknown(data['is_voided']!, _isVoidedMeta),
      );
    }
    if (data.containsKey('voided_at')) {
      context.handle(
        _voidedAtMeta,
        voidedAt.isAcceptableOrUnknown(data['voided_at']!, _voidedAtMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      buyerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buyer_id'],
      ),
      harvestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}harvest_id'],
      ),
      saleDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sale_date'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      unitPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_minor'],
      )!,
      totalAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      paymentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isVoided: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_voided'],
      )!,
      voidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}voided_at'],
      ),
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
    );
  }

  @override
  $SalesTableTable createAlias(String alias) {
    return $SalesTableTable(attachedDatabase, alias);
  }
}

class Sale extends DataClass implements Insertable<Sale> {
  /// Unique client-generated UUID v4 identifier.
  final String id;

  /// Creation timestamp in milliseconds since epoch (UTC).
  final int createdAt;

  /// Last modification timestamp in milliseconds since epoch (UTC).
  final int updatedAt;

  /// Whether this record has been confirmed and synchronized with cloud.
  final bool isSynced;

  /// Soft deletion tombstone for cloud replication.
  final bool isDeleted;
  final String projectId;
  final String? buyerId;
  final String? harvestId;
  final int saleDate;
  final String productName;
  final double quantity;
  final String unit;

  /// Minor units (Pesewas for GHS).
  final int unitPriceMinor;

  /// Minor units (quantity * unitPriceMinor).
  final int totalAmountMinor;
  final String currency;
  final String paymentStatus;
  final String? notes;

  /// Soft voiding flags.
  final bool isVoided;
  final int? voidedAt;
  final String? voidReason;
  const Sale({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.isDeleted,
    required this.projectId,
    this.buyerId,
    this.harvestId,
    required this.saleDate,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.unitPriceMinor,
    required this.totalAmountMinor,
    required this.currency,
    required this.paymentStatus,
    this.notes,
    required this.isVoided,
    this.voidedAt,
    this.voidReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['project_id'] = Variable<String>(projectId);
    if (!nullToAbsent || buyerId != null) {
      map['buyer_id'] = Variable<String>(buyerId);
    }
    if (!nullToAbsent || harvestId != null) {
      map['harvest_id'] = Variable<String>(harvestId);
    }
    map['sale_date'] = Variable<int>(saleDate);
    map['product_name'] = Variable<String>(productName);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    map['unit_price_minor'] = Variable<int>(unitPriceMinor);
    map['total_amount_minor'] = Variable<int>(totalAmountMinor);
    map['currency'] = Variable<String>(currency);
    map['payment_status'] = Variable<String>(paymentStatus);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_voided'] = Variable<bool>(isVoided);
    if (!nullToAbsent || voidedAt != null) {
      map['voided_at'] = Variable<int>(voidedAt);
    }
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    return map;
  }

  SalesTableCompanion toCompanion(bool nullToAbsent) {
    return SalesTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      projectId: Value(projectId),
      buyerId: buyerId == null && nullToAbsent
          ? const Value.absent()
          : Value(buyerId),
      harvestId: harvestId == null && nullToAbsent
          ? const Value.absent()
          : Value(harvestId),
      saleDate: Value(saleDate),
      productName: Value(productName),
      quantity: Value(quantity),
      unit: Value(unit),
      unitPriceMinor: Value(unitPriceMinor),
      totalAmountMinor: Value(totalAmountMinor),
      currency: Value(currency),
      paymentStatus: Value(paymentStatus),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isVoided: Value(isVoided),
      voidedAt: voidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedAt),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
    );
  }

  factory Sale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      projectId: serializer.fromJson<String>(json['projectId']),
      buyerId: serializer.fromJson<String?>(json['buyerId']),
      harvestId: serializer.fromJson<String?>(json['harvestId']),
      saleDate: serializer.fromJson<int>(json['saleDate']),
      productName: serializer.fromJson<String>(json['productName']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      unitPriceMinor: serializer.fromJson<int>(json['unitPriceMinor']),
      totalAmountMinor: serializer.fromJson<int>(json['totalAmountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      notes: serializer.fromJson<String?>(json['notes']),
      isVoided: serializer.fromJson<bool>(json['isVoided']),
      voidedAt: serializer.fromJson<int?>(json['voidedAt']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'projectId': serializer.toJson<String>(projectId),
      'buyerId': serializer.toJson<String?>(buyerId),
      'harvestId': serializer.toJson<String?>(harvestId),
      'saleDate': serializer.toJson<int>(saleDate),
      'productName': serializer.toJson<String>(productName),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'unitPriceMinor': serializer.toJson<int>(unitPriceMinor),
      'totalAmountMinor': serializer.toJson<int>(totalAmountMinor),
      'currency': serializer.toJson<String>(currency),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'notes': serializer.toJson<String?>(notes),
      'isVoided': serializer.toJson<bool>(isVoided),
      'voidedAt': serializer.toJson<int?>(voidedAt),
      'voidReason': serializer.toJson<String?>(voidReason),
    };
  }

  Sale copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    String? projectId,
    Value<String?> buyerId = const Value.absent(),
    Value<String?> harvestId = const Value.absent(),
    int? saleDate,
    String? productName,
    double? quantity,
    String? unit,
    int? unitPriceMinor,
    int? totalAmountMinor,
    String? currency,
    String? paymentStatus,
    Value<String?> notes = const Value.absent(),
    bool? isVoided,
    Value<int?> voidedAt = const Value.absent(),
    Value<String?> voidReason = const Value.absent(),
  }) => Sale(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
    projectId: projectId ?? this.projectId,
    buyerId: buyerId.present ? buyerId.value : this.buyerId,
    harvestId: harvestId.present ? harvestId.value : this.harvestId,
    saleDate: saleDate ?? this.saleDate,
    productName: productName ?? this.productName,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
    totalAmountMinor: totalAmountMinor ?? this.totalAmountMinor,
    currency: currency ?? this.currency,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    notes: notes.present ? notes.value : this.notes,
    isVoided: isVoided ?? this.isVoided,
    voidedAt: voidedAt.present ? voidedAt.value : this.voidedAt,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
  );
  Sale copyWithCompanion(SalesTableCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      buyerId: data.buyerId.present ? data.buyerId.value : this.buyerId,
      harvestId: data.harvestId.present ? data.harvestId.value : this.harvestId,
      saleDate: data.saleDate.present ? data.saleDate.value : this.saleDate,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      unitPriceMinor: data.unitPriceMinor.present
          ? data.unitPriceMinor.value
          : this.unitPriceMinor,
      totalAmountMinor: data.totalAmountMinor.present
          ? data.totalAmountMinor.value
          : this.totalAmountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      notes: data.notes.present ? data.notes.value : this.notes,
      isVoided: data.isVoided.present ? data.isVoided.value : this.isVoided,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('buyerId: $buyerId, ')
          ..write('harvestId: $harvestId, ')
          ..write('saleDate: $saleDate, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('totalAmountMinor: $totalAmountMinor, ')
          ..write('currency: $currency, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('notes: $notes, ')
          ..write('isVoided: $isVoided, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    buyerId,
    harvestId,
    saleDate,
    productName,
    quantity,
    unit,
    unitPriceMinor,
    totalAmountMinor,
    currency,
    paymentStatus,
    notes,
    isVoided,
    voidedAt,
    voidReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.projectId == this.projectId &&
          other.buyerId == this.buyerId &&
          other.harvestId == this.harvestId &&
          other.saleDate == this.saleDate &&
          other.productName == this.productName &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.unitPriceMinor == this.unitPriceMinor &&
          other.totalAmountMinor == this.totalAmountMinor &&
          other.currency == this.currency &&
          other.paymentStatus == this.paymentStatus &&
          other.notes == this.notes &&
          other.isVoided == this.isVoided &&
          other.voidedAt == this.voidedAt &&
          other.voidReason == this.voidReason);
}

class SalesTableCompanion extends UpdateCompanion<Sale> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> projectId;
  final Value<String?> buyerId;
  final Value<String?> harvestId;
  final Value<int> saleDate;
  final Value<String> productName;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<int> unitPriceMinor;
  final Value<int> totalAmountMinor;
  final Value<String> currency;
  final Value<String> paymentStatus;
  final Value<String?> notes;
  final Value<bool> isVoided;
  final Value<int?> voidedAt;
  final Value<String?> voidReason;
  final Value<int> rowid;
  const SalesTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.projectId = const Value.absent(),
    this.buyerId = const Value.absent(),
    this.harvestId = const Value.absent(),
    this.saleDate = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitPriceMinor = const Value.absent(),
    this.totalAmountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.notes = const Value.absent(),
    this.isVoided = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesTableCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String projectId,
    this.buyerId = const Value.absent(),
    this.harvestId = const Value.absent(),
    required int saleDate,
    required String productName,
    required double quantity,
    required String unit,
    required int unitPriceMinor,
    required int totalAmountMinor,
    this.currency = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.notes = const Value.absent(),
    this.isVoided = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       projectId = Value(projectId),
       saleDate = Value(saleDate),
       productName = Value(productName),
       quantity = Value(quantity),
       unit = Value(unit),
       unitPriceMinor = Value(unitPriceMinor),
       totalAmountMinor = Value(totalAmountMinor);
  static Insertable<Sale> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? projectId,
    Expression<String>? buyerId,
    Expression<String>? harvestId,
    Expression<int>? saleDate,
    Expression<String>? productName,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<int>? unitPriceMinor,
    Expression<int>? totalAmountMinor,
    Expression<String>? currency,
    Expression<String>? paymentStatus,
    Expression<String>? notes,
    Expression<bool>? isVoided,
    Expression<int>? voidedAt,
    Expression<String>? voidReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (projectId != null) 'project_id': projectId,
      if (buyerId != null) 'buyer_id': buyerId,
      if (harvestId != null) 'harvest_id': harvestId,
      if (saleDate != null) 'sale_date': saleDate,
      if (productName != null) 'product_name': productName,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (unitPriceMinor != null) 'unit_price_minor': unitPriceMinor,
      if (totalAmountMinor != null) 'total_amount_minor': totalAmountMinor,
      if (currency != null) 'currency': currency,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (notes != null) 'notes': notes,
      if (isVoided != null) 'is_voided': isVoided,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (voidReason != null) 'void_reason': voidReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesTableCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
    Value<String>? projectId,
    Value<String?>? buyerId,
    Value<String?>? harvestId,
    Value<int>? saleDate,
    Value<String>? productName,
    Value<double>? quantity,
    Value<String>? unit,
    Value<int>? unitPriceMinor,
    Value<int>? totalAmountMinor,
    Value<String>? currency,
    Value<String>? paymentStatus,
    Value<String?>? notes,
    Value<bool>? isVoided,
    Value<int?>? voidedAt,
    Value<String?>? voidReason,
    Value<int>? rowid,
  }) {
    return SalesTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      projectId: projectId ?? this.projectId,
      buyerId: buyerId ?? this.buyerId,
      harvestId: harvestId ?? this.harvestId,
      saleDate: saleDate ?? this.saleDate,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
      totalAmountMinor: totalAmountMinor ?? this.totalAmountMinor,
      currency: currency ?? this.currency,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      isVoided: isVoided ?? this.isVoided,
      voidedAt: voidedAt ?? this.voidedAt,
      voidReason: voidReason ?? this.voidReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (buyerId.present) {
      map['buyer_id'] = Variable<String>(buyerId.value);
    }
    if (harvestId.present) {
      map['harvest_id'] = Variable<String>(harvestId.value);
    }
    if (saleDate.present) {
      map['sale_date'] = Variable<int>(saleDate.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (unitPriceMinor.present) {
      map['unit_price_minor'] = Variable<int>(unitPriceMinor.value);
    }
    if (totalAmountMinor.present) {
      map['total_amount_minor'] = Variable<int>(totalAmountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isVoided.present) {
      map['is_voided'] = Variable<bool>(isVoided.value);
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<int>(voidedAt.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('buyerId: $buyerId, ')
          ..write('harvestId: $harvestId, ')
          ..write('saleDate: $saleDate, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('totalAmountMinor: $totalAmountMinor, ')
          ..write('currency: $currency, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('notes: $notes, ')
          ..write('isVoided: $isVoided, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTableTable extends PaymentsTable
    with TableInfo<$PaymentsTableTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<int> paymentDate = GeneratedColumn<int>(
    'payment_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GHS'),
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceNumberMeta = const VerificationMeta(
    'referenceNumber',
  );
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
    'reference_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isVoidedMeta = const VerificationMeta(
    'isVoided',
  );
  @override
  late final GeneratedColumn<bool> isVoided = GeneratedColumn<bool>(
    'is_voided',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_voided" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _voidedAtMeta = const VerificationMeta(
    'voidedAt',
  );
  @override
  late final GeneratedColumn<int> voidedAt = GeneratedColumn<int>(
    'voided_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    saleId,
    paymentDate,
    amountMinor,
    currency,
    paymentMethod,
    referenceNumber,
    notes,
    isVoided,
    voidedAt,
    voidReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('reference_number')) {
      context.handle(
        _referenceNumberMeta,
        referenceNumber.isAcceptableOrUnknown(
          data['reference_number']!,
          _referenceNumberMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_voided')) {
      context.handle(
        _isVoidedMeta,
        isVoided.isAcceptableOrUnknown(data['is_voided']!, _isVoidedMeta),
      );
    }
    if (data.containsKey('voided_at')) {
      context.handle(
        _voidedAtMeta,
        voidedAt.isAcceptableOrUnknown(data['voided_at']!, _voidedAtMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_date'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      referenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_number'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isVoided: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_voided'],
      )!,
      voidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}voided_at'],
      ),
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
    );
  }

  @override
  $PaymentsTableTable createAlias(String alias) {
    return $PaymentsTableTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  /// Unique client-generated UUID v4 identifier.
  final String id;

  /// Creation timestamp in milliseconds since epoch (UTC).
  final int createdAt;

  /// Last modification timestamp in milliseconds since epoch (UTC).
  final int updatedAt;

  /// Whether this record has been confirmed and synchronized with cloud.
  final bool isSynced;

  /// Soft deletion tombstone for cloud replication.
  final bool isDeleted;
  final String saleId;
  final int paymentDate;

  /// Minor units (Pesewas for GHS).
  final int amountMinor;
  final String currency;
  final String paymentMethod;
  final String? referenceNumber;
  final String? notes;

  /// Soft voiding flags.
  final bool isVoided;
  final int? voidedAt;
  final String? voidReason;
  const Payment({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.isDeleted,
    required this.saleId,
    required this.paymentDate,
    required this.amountMinor,
    required this.currency,
    required this.paymentMethod,
    this.referenceNumber,
    this.notes,
    required this.isVoided,
    this.voidedAt,
    this.voidReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['sale_id'] = Variable<String>(saleId);
    map['payment_date'] = Variable<int>(paymentDate);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_voided'] = Variable<bool>(isVoided);
    if (!nullToAbsent || voidedAt != null) {
      map['voided_at'] = Variable<int>(voidedAt);
    }
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    return map;
  }

  PaymentsTableCompanion toCompanion(bool nullToAbsent) {
    return PaymentsTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      saleId: Value(saleId),
      paymentDate: Value(paymentDate),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      paymentMethod: Value(paymentMethod),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isVoided: Value(isVoided),
      voidedAt: voidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedAt),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      saleId: serializer.fromJson<String>(json['saleId']),
      paymentDate: serializer.fromJson<int>(json['paymentDate']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      referenceNumber: serializer.fromJson<String?>(json['referenceNumber']),
      notes: serializer.fromJson<String?>(json['notes']),
      isVoided: serializer.fromJson<bool>(json['isVoided']),
      voidedAt: serializer.fromJson<int?>(json['voidedAt']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'saleId': serializer.toJson<String>(saleId),
      'paymentDate': serializer.toJson<int>(paymentDate),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'referenceNumber': serializer.toJson<String?>(referenceNumber),
      'notes': serializer.toJson<String?>(notes),
      'isVoided': serializer.toJson<bool>(isVoided),
      'voidedAt': serializer.toJson<int?>(voidedAt),
      'voidReason': serializer.toJson<String?>(voidReason),
    };
  }

  Payment copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    String? saleId,
    int? paymentDate,
    int? amountMinor,
    String? currency,
    String? paymentMethod,
    Value<String?> referenceNumber = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isVoided,
    Value<int?> voidedAt = const Value.absent(),
    Value<String?> voidReason = const Value.absent(),
  }) => Payment(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
    saleId: saleId ?? this.saleId,
    paymentDate: paymentDate ?? this.paymentDate,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    referenceNumber: referenceNumber.present
        ? referenceNumber.value
        : this.referenceNumber,
    notes: notes.present ? notes.value : this.notes,
    isVoided: isVoided ?? this.isVoided,
    voidedAt: voidedAt.present ? voidedAt.value : this.voidedAt,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
  );
  Payment copyWithCompanion(PaymentsTableCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      notes: data.notes.present ? data.notes.value : this.notes,
      isVoided: data.isVoided.present ? data.isVoided.value : this.isVoided,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('saleId: $saleId, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('notes: $notes, ')
          ..write('isVoided: $isVoided, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    saleId,
    paymentDate,
    amountMinor,
    currency,
    paymentMethod,
    referenceNumber,
    notes,
    isVoided,
    voidedAt,
    voidReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.saleId == this.saleId &&
          other.paymentDate == this.paymentDate &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.paymentMethod == this.paymentMethod &&
          other.referenceNumber == this.referenceNumber &&
          other.notes == this.notes &&
          other.isVoided == this.isVoided &&
          other.voidedAt == this.voidedAt &&
          other.voidReason == this.voidReason);
}

class PaymentsTableCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> saleId;
  final Value<int> paymentDate;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String> paymentMethod;
  final Value<String?> referenceNumber;
  final Value<String?> notes;
  final Value<bool> isVoided;
  final Value<int?> voidedAt;
  final Value<String?> voidReason;
  final Value<int> rowid;
  const PaymentsTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.saleId = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.notes = const Value.absent(),
    this.isVoided = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsTableCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String saleId,
    required int paymentDate,
    required int amountMinor,
    this.currency = const Value.absent(),
    required String paymentMethod,
    this.referenceNumber = const Value.absent(),
    this.notes = const Value.absent(),
    this.isVoided = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       saleId = Value(saleId),
       paymentDate = Value(paymentDate),
       amountMinor = Value(amountMinor),
       paymentMethod = Value(paymentMethod);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? saleId,
    Expression<int>? paymentDate,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? paymentMethod,
    Expression<String>? referenceNumber,
    Expression<String>? notes,
    Expression<bool>? isVoided,
    Expression<int>? voidedAt,
    Expression<String>? voidReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (saleId != null) 'sale_id': saleId,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (notes != null) 'notes': notes,
      if (isVoided != null) 'is_voided': isVoided,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (voidReason != null) 'void_reason': voidReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsTableCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
    Value<String>? saleId,
    Value<int>? paymentDate,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String>? paymentMethod,
    Value<String?>? referenceNumber,
    Value<String?>? notes,
    Value<bool>? isVoided,
    Value<int?>? voidedAt,
    Value<String?>? voidReason,
    Value<int>? rowid,
  }) {
    return PaymentsTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      saleId: saleId ?? this.saleId,
      paymentDate: paymentDate ?? this.paymentDate,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      isVoided: isVoided ?? this.isVoided,
      voidedAt: voidedAt ?? this.voidedAt,
      voidReason: voidReason ?? this.voidReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<int>(paymentDate.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isVoided.present) {
      map['is_voided'] = Variable<bool>(isVoided.value);
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<int>(voidedAt.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('saleId: $saleId, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('notes: $notes, ')
          ..write('isVoided: $isVoided, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashTransactionsTableTable extends CashTransactionsTable
    with TableInfo<$CashTransactionsTableTable, CashTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashTransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<int> transactionDate = GeneratedColumn<int>(
    'transaction_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GHS'),
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
    'reference_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    transactionType,
    category,
    transactionDate,
    amountMinor,
    currency,
    referenceId,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_date'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $CashTransactionsTableTable createAlias(String alias) {
    return $CashTransactionsTableTable(attachedDatabase, alias);
  }
}

class CashTransaction extends DataClass implements Insertable<CashTransaction> {
  /// Unique client-generated UUID v4 identifier.
  final String id;

  /// Creation timestamp in milliseconds since epoch (UTC).
  final int createdAt;

  /// Last modification timestamp in milliseconds since epoch (UTC).
  final int updatedAt;

  /// Whether this record has been confirmed and synchronized with cloud.
  final bool isSynced;

  /// Soft deletion tombstone for cloud replication.
  final bool isDeleted;
  final String? projectId;
  final String transactionType;
  final String category;
  final int transactionDate;
  final int amountMinor;
  final String currency;
  final String? referenceId;
  final String? notes;
  const CashTransaction({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.isDeleted,
    this.projectId,
    required this.transactionType,
    required this.category,
    required this.transactionDate,
    required this.amountMinor,
    required this.currency,
    this.referenceId,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['transaction_type'] = Variable<String>(transactionType);
    map['category'] = Variable<String>(category);
    map['transaction_date'] = Variable<int>(transactionDate);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CashTransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return CashTransactionsTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      transactionType: Value(transactionType),
      category: Value(category),
      transactionDate: Value(transactionDate),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory CashTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashTransaction(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      category: serializer.fromJson<String>(json['category']),
      transactionDate: serializer.fromJson<int>(json['transactionDate']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'projectId': serializer.toJson<String?>(projectId),
      'transactionType': serializer.toJson<String>(transactionType),
      'category': serializer.toJson<String>(category),
      'transactionDate': serializer.toJson<int>(transactionDate),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'referenceId': serializer.toJson<String?>(referenceId),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CashTransaction copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    Value<String?> projectId = const Value.absent(),
    String? transactionType,
    String? category,
    int? transactionDate,
    int? amountMinor,
    String? currency,
    Value<String?> referenceId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => CashTransaction(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
    projectId: projectId.present ? projectId.value : this.projectId,
    transactionType: transactionType ?? this.transactionType,
    category: category ?? this.category,
    transactionDate: transactionDate ?? this.transactionDate,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    referenceId: referenceId.present ? referenceId.value : this.referenceId,
    notes: notes.present ? notes.value : this.notes,
  );
  CashTransaction copyWithCompanion(CashTransactionsTableCompanion data) {
    return CashTransaction(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      category: data.category.present ? data.category.value : this.category,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashTransaction(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('transactionType: $transactionType, ')
          ..write('category: $category, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('referenceId: $referenceId, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    transactionType,
    category,
    transactionDate,
    amountMinor,
    currency,
    referenceId,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashTransaction &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.projectId == this.projectId &&
          other.transactionType == this.transactionType &&
          other.category == this.category &&
          other.transactionDate == this.transactionDate &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.referenceId == this.referenceId &&
          other.notes == this.notes);
}

class CashTransactionsTableCompanion extends UpdateCompanion<CashTransaction> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String?> projectId;
  final Value<String> transactionType;
  final Value<String> category;
  final Value<int> transactionDate;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String?> referenceId;
  final Value<String?> notes;
  final Value<int> rowid;
  const CashTransactionsTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.projectId = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.category = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashTransactionsTableCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.projectId = const Value.absent(),
    required String transactionType,
    required String category,
    required int transactionDate,
    required int amountMinor,
    this.currency = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       transactionType = Value(transactionType),
       category = Value(category),
       transactionDate = Value(transactionDate),
       amountMinor = Value(amountMinor);
  static Insertable<CashTransaction> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? projectId,
    Expression<String>? transactionType,
    Expression<String>? category,
    Expression<int>? transactionDate,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? referenceId,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (projectId != null) 'project_id': projectId,
      if (transactionType != null) 'transaction_type': transactionType,
      if (category != null) 'category': category,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (referenceId != null) 'reference_id': referenceId,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashTransactionsTableCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
    Value<String?>? projectId,
    Value<String>? transactionType,
    Value<String>? category,
    Value<int>? transactionDate,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String?>? referenceId,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return CashTransactionsTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      projectId: projectId ?? this.projectId,
      transactionType: transactionType ?? this.transactionType,
      category: category ?? this.category,
      transactionDate: transactionDate ?? this.transactionDate,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      referenceId: referenceId ?? this.referenceId,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<int>(transactionDate.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashTransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('transactionType: $transactionType, ')
          ..write('category: $category, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('referenceId: $referenceId, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScenariosTableTable extends ScenariosTable
    with TableInfo<$ScenariosTableTable, Scenario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScenariosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _scenarioTypeMeta = const VerificationMeta(
    'scenarioType',
  );
  @override
  late final GeneratedColumn<String> scenarioType = GeneratedColumn<String>(
    'scenario_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedYieldMeta = const VerificationMeta(
    'expectedYield',
  );
  @override
  late final GeneratedColumn<double> expectedYield = GeneratedColumn<double>(
    'expected_yield',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yieldUnitMeta = const VerificationMeta(
    'yieldUnit',
  );
  @override
  late final GeneratedColumn<String> yieldUnit = GeneratedColumn<String>(
    'yield_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedUnitPriceMinorMeta =
      const VerificationMeta('expectedUnitPriceMinor');
  @override
  late final GeneratedColumn<int> expectedUnitPriceMinor = GeneratedColumn<int>(
    'expected_unit_price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectedRevenueMinorMeta =
      const VerificationMeta('projectedRevenueMinor');
  @override
  late final GeneratedColumn<int> projectedRevenueMinor = GeneratedColumn<int>(
    'projected_revenue_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectedCostMinorMeta =
      const VerificationMeta('projectedCostMinor');
  @override
  late final GeneratedColumn<int> projectedCostMinor = GeneratedColumn<int>(
    'projected_cost_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectedProfitMinorMeta =
      const VerificationMeta('projectedProfitMinor');
  @override
  late final GeneratedColumn<int> projectedProfitMinor = GeneratedColumn<int>(
    'projected_profit_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectedRoiPercentMeta =
      const VerificationMeta('projectedRoiPercent');
  @override
  late final GeneratedColumn<double> projectedRoiPercent =
      GeneratedColumn<double>(
        'projected_roi_percent',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    scenarioType,
    expectedYield,
    yieldUnit,
    expectedUnitPriceMinor,
    projectedRevenueMinor,
    projectedCostMinor,
    projectedProfitMinor,
    projectedRoiPercent,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scenarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<Scenario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('scenario_type')) {
      context.handle(
        _scenarioTypeMeta,
        scenarioType.isAcceptableOrUnknown(
          data['scenario_type']!,
          _scenarioTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scenarioTypeMeta);
    }
    if (data.containsKey('expected_yield')) {
      context.handle(
        _expectedYieldMeta,
        expectedYield.isAcceptableOrUnknown(
          data['expected_yield']!,
          _expectedYieldMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedYieldMeta);
    }
    if (data.containsKey('yield_unit')) {
      context.handle(
        _yieldUnitMeta,
        yieldUnit.isAcceptableOrUnknown(data['yield_unit']!, _yieldUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_yieldUnitMeta);
    }
    if (data.containsKey('expected_unit_price_minor')) {
      context.handle(
        _expectedUnitPriceMinorMeta,
        expectedUnitPriceMinor.isAcceptableOrUnknown(
          data['expected_unit_price_minor']!,
          _expectedUnitPriceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedUnitPriceMinorMeta);
    }
    if (data.containsKey('projected_revenue_minor')) {
      context.handle(
        _projectedRevenueMinorMeta,
        projectedRevenueMinor.isAcceptableOrUnknown(
          data['projected_revenue_minor']!,
          _projectedRevenueMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_projectedRevenueMinorMeta);
    }
    if (data.containsKey('projected_cost_minor')) {
      context.handle(
        _projectedCostMinorMeta,
        projectedCostMinor.isAcceptableOrUnknown(
          data['projected_cost_minor']!,
          _projectedCostMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_projectedCostMinorMeta);
    }
    if (data.containsKey('projected_profit_minor')) {
      context.handle(
        _projectedProfitMinorMeta,
        projectedProfitMinor.isAcceptableOrUnknown(
          data['projected_profit_minor']!,
          _projectedProfitMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_projectedProfitMinorMeta);
    }
    if (data.containsKey('projected_roi_percent')) {
      context.handle(
        _projectedRoiPercentMeta,
        projectedRoiPercent.isAcceptableOrUnknown(
          data['projected_roi_percent']!,
          _projectedRoiPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_projectedRoiPercentMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Scenario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Scenario(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      scenarioType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scenario_type'],
      )!,
      expectedYield: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}expected_yield'],
      )!,
      yieldUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}yield_unit'],
      )!,
      expectedUnitPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_unit_price_minor'],
      )!,
      projectedRevenueMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}projected_revenue_minor'],
      )!,
      projectedCostMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}projected_cost_minor'],
      )!,
      projectedProfitMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}projected_profit_minor'],
      )!,
      projectedRoiPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}projected_roi_percent'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ScenariosTableTable createAlias(String alias) {
    return $ScenariosTableTable(attachedDatabase, alias);
  }
}

class Scenario extends DataClass implements Insertable<Scenario> {
  /// Unique client-generated UUID v4 identifier.
  final String id;

  /// Creation timestamp in milliseconds since epoch (UTC).
  final int createdAt;

  /// Last modification timestamp in milliseconds since epoch (UTC).
  final int updatedAt;

  /// Whether this record has been confirmed and synchronized with cloud.
  final bool isSynced;

  /// Soft deletion tombstone for cloud replication.
  final bool isDeleted;
  final String projectId;
  final String scenarioType;
  final double expectedYield;
  final String yieldUnit;
  final int expectedUnitPriceMinor;
  final int projectedRevenueMinor;
  final int projectedCostMinor;
  final int projectedProfitMinor;
  final double projectedRoiPercent;
  final String? notes;
  const Scenario({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.isDeleted,
    required this.projectId,
    required this.scenarioType,
    required this.expectedYield,
    required this.yieldUnit,
    required this.expectedUnitPriceMinor,
    required this.projectedRevenueMinor,
    required this.projectedCostMinor,
    required this.projectedProfitMinor,
    required this.projectedRoiPercent,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['project_id'] = Variable<String>(projectId);
    map['scenario_type'] = Variable<String>(scenarioType);
    map['expected_yield'] = Variable<double>(expectedYield);
    map['yield_unit'] = Variable<String>(yieldUnit);
    map['expected_unit_price_minor'] = Variable<int>(expectedUnitPriceMinor);
    map['projected_revenue_minor'] = Variable<int>(projectedRevenueMinor);
    map['projected_cost_minor'] = Variable<int>(projectedCostMinor);
    map['projected_profit_minor'] = Variable<int>(projectedProfitMinor);
    map['projected_roi_percent'] = Variable<double>(projectedRoiPercent);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ScenariosTableCompanion toCompanion(bool nullToAbsent) {
    return ScenariosTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      projectId: Value(projectId),
      scenarioType: Value(scenarioType),
      expectedYield: Value(expectedYield),
      yieldUnit: Value(yieldUnit),
      expectedUnitPriceMinor: Value(expectedUnitPriceMinor),
      projectedRevenueMinor: Value(projectedRevenueMinor),
      projectedCostMinor: Value(projectedCostMinor),
      projectedProfitMinor: Value(projectedProfitMinor),
      projectedRoiPercent: Value(projectedRoiPercent),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Scenario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Scenario(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      projectId: serializer.fromJson<String>(json['projectId']),
      scenarioType: serializer.fromJson<String>(json['scenarioType']),
      expectedYield: serializer.fromJson<double>(json['expectedYield']),
      yieldUnit: serializer.fromJson<String>(json['yieldUnit']),
      expectedUnitPriceMinor: serializer.fromJson<int>(
        json['expectedUnitPriceMinor'],
      ),
      projectedRevenueMinor: serializer.fromJson<int>(
        json['projectedRevenueMinor'],
      ),
      projectedCostMinor: serializer.fromJson<int>(json['projectedCostMinor']),
      projectedProfitMinor: serializer.fromJson<int>(
        json['projectedProfitMinor'],
      ),
      projectedRoiPercent: serializer.fromJson<double>(
        json['projectedRoiPercent'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'projectId': serializer.toJson<String>(projectId),
      'scenarioType': serializer.toJson<String>(scenarioType),
      'expectedYield': serializer.toJson<double>(expectedYield),
      'yieldUnit': serializer.toJson<String>(yieldUnit),
      'expectedUnitPriceMinor': serializer.toJson<int>(expectedUnitPriceMinor),
      'projectedRevenueMinor': serializer.toJson<int>(projectedRevenueMinor),
      'projectedCostMinor': serializer.toJson<int>(projectedCostMinor),
      'projectedProfitMinor': serializer.toJson<int>(projectedProfitMinor),
      'projectedRoiPercent': serializer.toJson<double>(projectedRoiPercent),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Scenario copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    String? projectId,
    String? scenarioType,
    double? expectedYield,
    String? yieldUnit,
    int? expectedUnitPriceMinor,
    int? projectedRevenueMinor,
    int? projectedCostMinor,
    int? projectedProfitMinor,
    double? projectedRoiPercent,
    Value<String?> notes = const Value.absent(),
  }) => Scenario(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
    projectId: projectId ?? this.projectId,
    scenarioType: scenarioType ?? this.scenarioType,
    expectedYield: expectedYield ?? this.expectedYield,
    yieldUnit: yieldUnit ?? this.yieldUnit,
    expectedUnitPriceMinor:
        expectedUnitPriceMinor ?? this.expectedUnitPriceMinor,
    projectedRevenueMinor: projectedRevenueMinor ?? this.projectedRevenueMinor,
    projectedCostMinor: projectedCostMinor ?? this.projectedCostMinor,
    projectedProfitMinor: projectedProfitMinor ?? this.projectedProfitMinor,
    projectedRoiPercent: projectedRoiPercent ?? this.projectedRoiPercent,
    notes: notes.present ? notes.value : this.notes,
  );
  Scenario copyWithCompanion(ScenariosTableCompanion data) {
    return Scenario(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      scenarioType: data.scenarioType.present
          ? data.scenarioType.value
          : this.scenarioType,
      expectedYield: data.expectedYield.present
          ? data.expectedYield.value
          : this.expectedYield,
      yieldUnit: data.yieldUnit.present ? data.yieldUnit.value : this.yieldUnit,
      expectedUnitPriceMinor: data.expectedUnitPriceMinor.present
          ? data.expectedUnitPriceMinor.value
          : this.expectedUnitPriceMinor,
      projectedRevenueMinor: data.projectedRevenueMinor.present
          ? data.projectedRevenueMinor.value
          : this.projectedRevenueMinor,
      projectedCostMinor: data.projectedCostMinor.present
          ? data.projectedCostMinor.value
          : this.projectedCostMinor,
      projectedProfitMinor: data.projectedProfitMinor.present
          ? data.projectedProfitMinor.value
          : this.projectedProfitMinor,
      projectedRoiPercent: data.projectedRoiPercent.present
          ? data.projectedRoiPercent.value
          : this.projectedRoiPercent,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Scenario(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('scenarioType: $scenarioType, ')
          ..write('expectedYield: $expectedYield, ')
          ..write('yieldUnit: $yieldUnit, ')
          ..write('expectedUnitPriceMinor: $expectedUnitPriceMinor, ')
          ..write('projectedRevenueMinor: $projectedRevenueMinor, ')
          ..write('projectedCostMinor: $projectedCostMinor, ')
          ..write('projectedProfitMinor: $projectedProfitMinor, ')
          ..write('projectedRoiPercent: $projectedRoiPercent, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    scenarioType,
    expectedYield,
    yieldUnit,
    expectedUnitPriceMinor,
    projectedRevenueMinor,
    projectedCostMinor,
    projectedProfitMinor,
    projectedRoiPercent,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Scenario &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.projectId == this.projectId &&
          other.scenarioType == this.scenarioType &&
          other.expectedYield == this.expectedYield &&
          other.yieldUnit == this.yieldUnit &&
          other.expectedUnitPriceMinor == this.expectedUnitPriceMinor &&
          other.projectedRevenueMinor == this.projectedRevenueMinor &&
          other.projectedCostMinor == this.projectedCostMinor &&
          other.projectedProfitMinor == this.projectedProfitMinor &&
          other.projectedRoiPercent == this.projectedRoiPercent &&
          other.notes == this.notes);
}

class ScenariosTableCompanion extends UpdateCompanion<Scenario> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> projectId;
  final Value<String> scenarioType;
  final Value<double> expectedYield;
  final Value<String> yieldUnit;
  final Value<int> expectedUnitPriceMinor;
  final Value<int> projectedRevenueMinor;
  final Value<int> projectedCostMinor;
  final Value<int> projectedProfitMinor;
  final Value<double> projectedRoiPercent;
  final Value<String?> notes;
  final Value<int> rowid;
  const ScenariosTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.projectId = const Value.absent(),
    this.scenarioType = const Value.absent(),
    this.expectedYield = const Value.absent(),
    this.yieldUnit = const Value.absent(),
    this.expectedUnitPriceMinor = const Value.absent(),
    this.projectedRevenueMinor = const Value.absent(),
    this.projectedCostMinor = const Value.absent(),
    this.projectedProfitMinor = const Value.absent(),
    this.projectedRoiPercent = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScenariosTableCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String projectId,
    required String scenarioType,
    required double expectedYield,
    required String yieldUnit,
    required int expectedUnitPriceMinor,
    required int projectedRevenueMinor,
    required int projectedCostMinor,
    required int projectedProfitMinor,
    required double projectedRoiPercent,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       projectId = Value(projectId),
       scenarioType = Value(scenarioType),
       expectedYield = Value(expectedYield),
       yieldUnit = Value(yieldUnit),
       expectedUnitPriceMinor = Value(expectedUnitPriceMinor),
       projectedRevenueMinor = Value(projectedRevenueMinor),
       projectedCostMinor = Value(projectedCostMinor),
       projectedProfitMinor = Value(projectedProfitMinor),
       projectedRoiPercent = Value(projectedRoiPercent);
  static Insertable<Scenario> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? projectId,
    Expression<String>? scenarioType,
    Expression<double>? expectedYield,
    Expression<String>? yieldUnit,
    Expression<int>? expectedUnitPriceMinor,
    Expression<int>? projectedRevenueMinor,
    Expression<int>? projectedCostMinor,
    Expression<int>? projectedProfitMinor,
    Expression<double>? projectedRoiPercent,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (projectId != null) 'project_id': projectId,
      if (scenarioType != null) 'scenario_type': scenarioType,
      if (expectedYield != null) 'expected_yield': expectedYield,
      if (yieldUnit != null) 'yield_unit': yieldUnit,
      if (expectedUnitPriceMinor != null)
        'expected_unit_price_minor': expectedUnitPriceMinor,
      if (projectedRevenueMinor != null)
        'projected_revenue_minor': projectedRevenueMinor,
      if (projectedCostMinor != null)
        'projected_cost_minor': projectedCostMinor,
      if (projectedProfitMinor != null)
        'projected_profit_minor': projectedProfitMinor,
      if (projectedRoiPercent != null)
        'projected_roi_percent': projectedRoiPercent,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScenariosTableCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
    Value<String>? projectId,
    Value<String>? scenarioType,
    Value<double>? expectedYield,
    Value<String>? yieldUnit,
    Value<int>? expectedUnitPriceMinor,
    Value<int>? projectedRevenueMinor,
    Value<int>? projectedCostMinor,
    Value<int>? projectedProfitMinor,
    Value<double>? projectedRoiPercent,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return ScenariosTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      projectId: projectId ?? this.projectId,
      scenarioType: scenarioType ?? this.scenarioType,
      expectedYield: expectedYield ?? this.expectedYield,
      yieldUnit: yieldUnit ?? this.yieldUnit,
      expectedUnitPriceMinor:
          expectedUnitPriceMinor ?? this.expectedUnitPriceMinor,
      projectedRevenueMinor:
          projectedRevenueMinor ?? this.projectedRevenueMinor,
      projectedCostMinor: projectedCostMinor ?? this.projectedCostMinor,
      projectedProfitMinor: projectedProfitMinor ?? this.projectedProfitMinor,
      projectedRoiPercent: projectedRoiPercent ?? this.projectedRoiPercent,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (scenarioType.present) {
      map['scenario_type'] = Variable<String>(scenarioType.value);
    }
    if (expectedYield.present) {
      map['expected_yield'] = Variable<double>(expectedYield.value);
    }
    if (yieldUnit.present) {
      map['yield_unit'] = Variable<String>(yieldUnit.value);
    }
    if (expectedUnitPriceMinor.present) {
      map['expected_unit_price_minor'] = Variable<int>(
        expectedUnitPriceMinor.value,
      );
    }
    if (projectedRevenueMinor.present) {
      map['projected_revenue_minor'] = Variable<int>(
        projectedRevenueMinor.value,
      );
    }
    if (projectedCostMinor.present) {
      map['projected_cost_minor'] = Variable<int>(projectedCostMinor.value);
    }
    if (projectedProfitMinor.present) {
      map['projected_profit_minor'] = Variable<int>(projectedProfitMinor.value);
    }
    if (projectedRoiPercent.present) {
      map['projected_roi_percent'] = Variable<double>(
        projectedRoiPercent.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScenariosTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('scenarioType: $scenarioType, ')
          ..write('expectedYield: $expectedYield, ')
          ..write('yieldUnit: $yieldUnit, ')
          ..write('expectedUnitPriceMinor: $expectedUnitPriceMinor, ')
          ..write('projectedRevenueMinor: $projectedRevenueMinor, ')
          ..write('projectedCostMinor: $projectedCostMinor, ')
          ..write('projectedProfitMinor: $projectedProfitMinor, ')
          ..write('projectedRoiPercent: $projectedRoiPercent, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RisksTableTable extends RisksTable
    with TableInfo<$RisksTableTable, Risk> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RisksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _riskTitleMeta = const VerificationMeta(
    'riskTitle',
  );
  @override
  late final GeneratedColumn<String> riskTitle = GeneratedColumn<String>(
    'risk_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _probabilityMeta = const VerificationMeta(
    'probability',
  );
  @override
  late final GeneratedColumn<int> probability = GeneratedColumn<int>(
    'probability',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _impactMeta = const VerificationMeta('impact');
  @override
  late final GeneratedColumn<int> impact = GeneratedColumn<int>(
    'impact',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _riskScoreMeta = const VerificationMeta(
    'riskScore',
  );
  @override
  late final GeneratedColumn<int> riskScore = GeneratedColumn<int>(
    'risk_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mitigationStrategyMeta =
      const VerificationMeta('mitigationStrategy');
  @override
  late final GeneratedColumn<String> mitigationStrategy =
      GeneratedColumn<String>(
        'mitigation_strategy',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('IDENTIFIED'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    riskTitle,
    category,
    probability,
    impact,
    riskScore,
    mitigationStrategy,
    status,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'risks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Risk> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('risk_title')) {
      context.handle(
        _riskTitleMeta,
        riskTitle.isAcceptableOrUnknown(data['risk_title']!, _riskTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_riskTitleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('probability')) {
      context.handle(
        _probabilityMeta,
        probability.isAcceptableOrUnknown(
          data['probability']!,
          _probabilityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_probabilityMeta);
    }
    if (data.containsKey('impact')) {
      context.handle(
        _impactMeta,
        impact.isAcceptableOrUnknown(data['impact']!, _impactMeta),
      );
    } else if (isInserting) {
      context.missing(_impactMeta);
    }
    if (data.containsKey('risk_score')) {
      context.handle(
        _riskScoreMeta,
        riskScore.isAcceptableOrUnknown(data['risk_score']!, _riskScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_riskScoreMeta);
    }
    if (data.containsKey('mitigation_strategy')) {
      context.handle(
        _mitigationStrategyMeta,
        mitigationStrategy.isAcceptableOrUnknown(
          data['mitigation_strategy']!,
          _mitigationStrategyMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Risk map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Risk(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      riskTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}risk_title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      probability: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}probability'],
      )!,
      impact: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}impact'],
      )!,
      riskScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}risk_score'],
      )!,
      mitigationStrategy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mitigation_strategy'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $RisksTableTable createAlias(String alias) {
    return $RisksTableTable(attachedDatabase, alias);
  }
}

class Risk extends DataClass implements Insertable<Risk> {
  /// Unique client-generated UUID v4 identifier.
  final String id;

  /// Creation timestamp in milliseconds since epoch (UTC).
  final int createdAt;

  /// Last modification timestamp in milliseconds since epoch (UTC).
  final int updatedAt;

  /// Whether this record has been confirmed and synchronized with cloud.
  final bool isSynced;

  /// Soft deletion tombstone for cloud replication.
  final bool isDeleted;
  final String projectId;
  final String riskTitle;
  final String category;
  final int probability;
  final int impact;
  final int riskScore;
  final String? mitigationStrategy;
  final String status;
  final String? notes;
  const Risk({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.isDeleted,
    required this.projectId,
    required this.riskTitle,
    required this.category,
    required this.probability,
    required this.impact,
    required this.riskScore,
    this.mitigationStrategy,
    required this.status,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['project_id'] = Variable<String>(projectId);
    map['risk_title'] = Variable<String>(riskTitle);
    map['category'] = Variable<String>(category);
    map['probability'] = Variable<int>(probability);
    map['impact'] = Variable<int>(impact);
    map['risk_score'] = Variable<int>(riskScore);
    if (!nullToAbsent || mitigationStrategy != null) {
      map['mitigation_strategy'] = Variable<String>(mitigationStrategy);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  RisksTableCompanion toCompanion(bool nullToAbsent) {
    return RisksTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      projectId: Value(projectId),
      riskTitle: Value(riskTitle),
      category: Value(category),
      probability: Value(probability),
      impact: Value(impact),
      riskScore: Value(riskScore),
      mitigationStrategy: mitigationStrategy == null && nullToAbsent
          ? const Value.absent()
          : Value(mitigationStrategy),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Risk.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Risk(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      projectId: serializer.fromJson<String>(json['projectId']),
      riskTitle: serializer.fromJson<String>(json['riskTitle']),
      category: serializer.fromJson<String>(json['category']),
      probability: serializer.fromJson<int>(json['probability']),
      impact: serializer.fromJson<int>(json['impact']),
      riskScore: serializer.fromJson<int>(json['riskScore']),
      mitigationStrategy: serializer.fromJson<String?>(
        json['mitigationStrategy'],
      ),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'projectId': serializer.toJson<String>(projectId),
      'riskTitle': serializer.toJson<String>(riskTitle),
      'category': serializer.toJson<String>(category),
      'probability': serializer.toJson<int>(probability),
      'impact': serializer.toJson<int>(impact),
      'riskScore': serializer.toJson<int>(riskScore),
      'mitigationStrategy': serializer.toJson<String?>(mitigationStrategy),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Risk copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    String? projectId,
    String? riskTitle,
    String? category,
    int? probability,
    int? impact,
    int? riskScore,
    Value<String?> mitigationStrategy = const Value.absent(),
    String? status,
    Value<String?> notes = const Value.absent(),
  }) => Risk(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
    projectId: projectId ?? this.projectId,
    riskTitle: riskTitle ?? this.riskTitle,
    category: category ?? this.category,
    probability: probability ?? this.probability,
    impact: impact ?? this.impact,
    riskScore: riskScore ?? this.riskScore,
    mitigationStrategy: mitigationStrategy.present
        ? mitigationStrategy.value
        : this.mitigationStrategy,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
  );
  Risk copyWithCompanion(RisksTableCompanion data) {
    return Risk(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      riskTitle: data.riskTitle.present ? data.riskTitle.value : this.riskTitle,
      category: data.category.present ? data.category.value : this.category,
      probability: data.probability.present
          ? data.probability.value
          : this.probability,
      impact: data.impact.present ? data.impact.value : this.impact,
      riskScore: data.riskScore.present ? data.riskScore.value : this.riskScore,
      mitigationStrategy: data.mitigationStrategy.present
          ? data.mitigationStrategy.value
          : this.mitigationStrategy,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Risk(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('riskTitle: $riskTitle, ')
          ..write('category: $category, ')
          ..write('probability: $probability, ')
          ..write('impact: $impact, ')
          ..write('riskScore: $riskScore, ')
          ..write('mitigationStrategy: $mitigationStrategy, ')
          ..write('status: $status, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
    projectId,
    riskTitle,
    category,
    probability,
    impact,
    riskScore,
    mitigationStrategy,
    status,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Risk &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.projectId == this.projectId &&
          other.riskTitle == this.riskTitle &&
          other.category == this.category &&
          other.probability == this.probability &&
          other.impact == this.impact &&
          other.riskScore == this.riskScore &&
          other.mitigationStrategy == this.mitigationStrategy &&
          other.status == this.status &&
          other.notes == this.notes);
}

class RisksTableCompanion extends UpdateCompanion<Risk> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> projectId;
  final Value<String> riskTitle;
  final Value<String> category;
  final Value<int> probability;
  final Value<int> impact;
  final Value<int> riskScore;
  final Value<String?> mitigationStrategy;
  final Value<String> status;
  final Value<String?> notes;
  final Value<int> rowid;
  const RisksTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.projectId = const Value.absent(),
    this.riskTitle = const Value.absent(),
    this.category = const Value.absent(),
    this.probability = const Value.absent(),
    this.impact = const Value.absent(),
    this.riskScore = const Value.absent(),
    this.mitigationStrategy = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RisksTableCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String projectId,
    required String riskTitle,
    required String category,
    required int probability,
    required int impact,
    required int riskScore,
    this.mitigationStrategy = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       projectId = Value(projectId),
       riskTitle = Value(riskTitle),
       category = Value(category),
       probability = Value(probability),
       impact = Value(impact),
       riskScore = Value(riskScore);
  static Insertable<Risk> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? projectId,
    Expression<String>? riskTitle,
    Expression<String>? category,
    Expression<int>? probability,
    Expression<int>? impact,
    Expression<int>? riskScore,
    Expression<String>? mitigationStrategy,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (projectId != null) 'project_id': projectId,
      if (riskTitle != null) 'risk_title': riskTitle,
      if (category != null) 'category': category,
      if (probability != null) 'probability': probability,
      if (impact != null) 'impact': impact,
      if (riskScore != null) 'risk_score': riskScore,
      if (mitigationStrategy != null) 'mitigation_strategy': mitigationStrategy,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RisksTableCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
    Value<String>? projectId,
    Value<String>? riskTitle,
    Value<String>? category,
    Value<int>? probability,
    Value<int>? impact,
    Value<int>? riskScore,
    Value<String?>? mitigationStrategy,
    Value<String>? status,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return RisksTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      projectId: projectId ?? this.projectId,
      riskTitle: riskTitle ?? this.riskTitle,
      category: category ?? this.category,
      probability: probability ?? this.probability,
      impact: impact ?? this.impact,
      riskScore: riskScore ?? this.riskScore,
      mitigationStrategy: mitigationStrategy ?? this.mitigationStrategy,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (riskTitle.present) {
      map['risk_title'] = Variable<String>(riskTitle.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (probability.present) {
      map['probability'] = Variable<int>(probability.value);
    }
    if (impact.present) {
      map['impact'] = Variable<int>(impact.value);
    }
    if (riskScore.present) {
      map['risk_score'] = Variable<int>(riskScore.value);
    }
    if (mitigationStrategy.present) {
      map['mitigation_strategy'] = Variable<String>(mitigationStrategy.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RisksTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('projectId: $projectId, ')
          ..write('riskTitle: $riskTitle, ')
          ..write('category: $category, ')
          ..write('probability: $probability, ')
          ..write('impact: $impact, ')
          ..write('riskScore: $riskScore, ')
          ..write('mitigationStrategy: $mitigationStrategy, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTableTable extends AuditLogsTable
    with TableInfo<$AuditLogsTableTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousStateJsonMeta = const VerificationMeta(
    'previousStateJson',
  );
  @override
  late final GeneratedColumn<String> previousStateJson =
      GeneratedColumn<String>(
        'previous_state_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _newStateJsonMeta = const VerificationMeta(
    'newStateJson',
  );
  @override
  late final GeneratedColumn<String> newStateJson = GeneratedColumn<String>(
    'new_state_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _performedByMeta = const VerificationMeta(
    'performedBy',
  );
  @override
  late final GeneratedColumn<String> performedBy = GeneratedColumn<String>(
    'performed_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_user'),
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityTable,
    entityId,
    action,
    previousStateJson,
    newStateJson,
    performedBy,
    reason,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('previous_state_json')) {
      context.handle(
        _previousStateJsonMeta,
        previousStateJson.isAcceptableOrUnknown(
          data['previous_state_json']!,
          _previousStateJsonMeta,
        ),
      );
    }
    if (data.containsKey('new_state_json')) {
      context.handle(
        _newStateJsonMeta,
        newStateJson.isAcceptableOrUnknown(
          data['new_state_json']!,
          _newStateJsonMeta,
        ),
      );
    }
    if (data.containsKey('performed_by')) {
      context.handle(
        _performedByMeta,
        performedBy.isAcceptableOrUnknown(
          data['performed_by']!,
          _performedByMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      previousStateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_state_json'],
      ),
      newStateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_state_json'],
      ),
      performedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}performed_by'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $AuditLogsTableTable createAlias(String alias) {
    return $AuditLogsTableTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final String entityTable;
  final String entityId;
  final String action;
  final String? previousStateJson;
  final String? newStateJson;
  final String performedBy;
  final String? reason;
  final int timestamp;
  const AuditLog({
    required this.id,
    required this.entityTable,
    required this.entityId,
    required this.action,
    this.previousStateJson,
    this.newStateJson,
    required this.performedBy,
    this.reason,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_table'] = Variable<String>(entityTable);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || previousStateJson != null) {
      map['previous_state_json'] = Variable<String>(previousStateJson);
    }
    if (!nullToAbsent || newStateJson != null) {
      map['new_state_json'] = Variable<String>(newStateJson);
    }
    map['performed_by'] = Variable<String>(performedBy);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['timestamp'] = Variable<int>(timestamp);
    return map;
  }

  AuditLogsTableCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsTableCompanion(
      id: Value(id),
      entityTable: Value(entityTable),
      entityId: Value(entityId),
      action: Value(action),
      previousStateJson: previousStateJson == null && nullToAbsent
          ? const Value.absent()
          : Value(previousStateJson),
      newStateJson: newStateJson == null && nullToAbsent
          ? const Value.absent()
          : Value(newStateJson),
      performedBy: Value(performedBy),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      timestamp: Value(timestamp),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      previousStateJson: serializer.fromJson<String?>(
        json['previousStateJson'],
      ),
      newStateJson: serializer.fromJson<String?>(json['newStateJson']),
      performedBy: serializer.fromJson<String>(json['performedBy']),
      reason: serializer.fromJson<String?>(json['reason']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityTable': serializer.toJson<String>(entityTable),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'previousStateJson': serializer.toJson<String?>(previousStateJson),
      'newStateJson': serializer.toJson<String?>(newStateJson),
      'performedBy': serializer.toJson<String>(performedBy),
      'reason': serializer.toJson<String?>(reason),
      'timestamp': serializer.toJson<int>(timestamp),
    };
  }

  AuditLog copyWith({
    String? id,
    String? entityTable,
    String? entityId,
    String? action,
    Value<String?> previousStateJson = const Value.absent(),
    Value<String?> newStateJson = const Value.absent(),
    String? performedBy,
    Value<String?> reason = const Value.absent(),
    int? timestamp,
  }) => AuditLog(
    id: id ?? this.id,
    entityTable: entityTable ?? this.entityTable,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    previousStateJson: previousStateJson.present
        ? previousStateJson.value
        : this.previousStateJson,
    newStateJson: newStateJson.present ? newStateJson.value : this.newStateJson,
    performedBy: performedBy ?? this.performedBy,
    reason: reason.present ? reason.value : this.reason,
    timestamp: timestamp ?? this.timestamp,
  );
  AuditLog copyWithCompanion(AuditLogsTableCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      previousStateJson: data.previousStateJson.present
          ? data.previousStateJson.value
          : this.previousStateJson,
      newStateJson: data.newStateJson.present
          ? data.newStateJson.value
          : this.newStateJson,
      performedBy: data.performedBy.present
          ? data.performedBy.value
          : this.performedBy,
      reason: data.reason.present ? data.reason.value : this.reason,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('previousStateJson: $previousStateJson, ')
          ..write('newStateJson: $newStateJson, ')
          ..write('performedBy: $performedBy, ')
          ..write('reason: $reason, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityTable,
    entityId,
    action,
    previousStateJson,
    newStateJson,
    performedBy,
    reason,
    timestamp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.entityTable == this.entityTable &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.previousStateJson == this.previousStateJson &&
          other.newStateJson == this.newStateJson &&
          other.performedBy == this.performedBy &&
          other.reason == this.reason &&
          other.timestamp == this.timestamp);
}

class AuditLogsTableCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<String> entityTable;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String?> previousStateJson;
  final Value<String?> newStateJson;
  final Value<String> performedBy;
  final Value<String?> reason;
  final Value<int> timestamp;
  final Value<int> rowid;
  const AuditLogsTableCompanion({
    this.id = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.previousStateJson = const Value.absent(),
    this.newStateJson = const Value.absent(),
    this.performedBy = const Value.absent(),
    this.reason = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsTableCompanion.insert({
    required String id,
    required String entityTable,
    required String entityId,
    required String action,
    this.previousStateJson = const Value.absent(),
    this.newStateJson = const Value.absent(),
    this.performedBy = const Value.absent(),
    this.reason = const Value.absent(),
    required int timestamp,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityTable = Value(entityTable),
       entityId = Value(entityId),
       action = Value(action),
       timestamp = Value(timestamp);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<String>? entityTable,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? previousStateJson,
    Expression<String>? newStateJson,
    Expression<String>? performedBy,
    Expression<String>? reason,
    Expression<int>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityTable != null) 'entity_table': entityTable,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (previousStateJson != null) 'previous_state_json': previousStateJson,
      if (newStateJson != null) 'new_state_json': newStateJson,
      if (performedBy != null) 'performed_by': performedBy,
      if (reason != null) 'reason': reason,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? entityTable,
    Value<String>? entityId,
    Value<String>? action,
    Value<String?>? previousStateJson,
    Value<String?>? newStateJson,
    Value<String>? performedBy,
    Value<String?>? reason,
    Value<int>? timestamp,
    Value<int>? rowid,
  }) {
    return AuditLogsTableCompanion(
      id: id ?? this.id,
      entityTable: entityTable ?? this.entityTable,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      previousStateJson: previousStateJson ?? this.previousStateJson,
      newStateJson: newStateJson ?? this.newStateJson,
      performedBy: performedBy ?? this.performedBy,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (previousStateJson.present) {
      map['previous_state_json'] = Variable<String>(previousStateJson.value);
    }
    if (newStateJson.present) {
      map['new_state_json'] = Variable<String>(newStateJson.value);
    }
    if (performedBy.present) {
      map['performed_by'] = Variable<String>(performedBy.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('previousStateJson: $previousStateJson, ')
          ..write('newStateJson: $newStateJson, ')
          ..write('performedBy: $performedBy, ')
          ..write('reason: $reason, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTableTable extends SyncQueueTable
    with TableInfo<$SyncQueueTableTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _queuedAtMeta = const VerificationMeta(
    'queuedAt',
  );
  @override
  late final GeneratedColumn<int> queuedAt = GeneratedColumn<int>(
    'queued_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityTable,
    entityId,
    operation,
    payloadJson,
    retryCount,
    lastError,
    queuedAt,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('queued_at')) {
      context.handle(
        _queuedAtMeta,
        queuedAt.isAcceptableOrUnknown(data['queued_at']!, _queuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_queuedAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      queuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queued_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $SyncQueueTableTable createAlias(String alias) {
    return $SyncQueueTableTable(attachedDatabase, alias);
  }
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  final String id;
  final String entityTable;
  final String entityId;
  final String operation;
  final String payloadJson;
  final int retryCount;
  final String? lastError;
  final int queuedAt;
  final String status;
  const SyncQueueEntry({
    required this.id,
    required this.entityTable,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    required this.retryCount,
    this.lastError,
    required this.queuedAt,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_table'] = Variable<String>(entityTable);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['queued_at'] = Variable<int>(queuedAt);
    map['status'] = Variable<String>(status);
    return map;
  }

  SyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueTableCompanion(
      id: Value(id),
      entityTable: Value(entityTable),
      entityId: Value(entityId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      queuedAt: Value(queuedAt),
      status: Value(status),
    );
  }

  factory SyncQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      id: serializer.fromJson<String>(json['id']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      queuedAt: serializer.fromJson<int>(json['queuedAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityTable': serializer.toJson<String>(entityTable),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'queuedAt': serializer.toJson<int>(queuedAt),
      'status': serializer.toJson<String>(status),
    };
  }

  SyncQueueEntry copyWith({
    String? id,
    String? entityTable,
    String? entityId,
    String? operation,
    String? payloadJson,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    int? queuedAt,
    String? status,
  }) => SyncQueueEntry(
    id: id ?? this.id,
    entityTable: entityTable ?? this.entityTable,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    queuedAt: queuedAt ?? this.queuedAt,
    status: status ?? this.status,
  );
  SyncQueueEntry copyWithCompanion(SyncQueueTableCompanion data) {
    return SyncQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      queuedAt: data.queuedAt.present ? data.queuedAt.value : this.queuedAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityTable,
    entityId,
    operation,
    payloadJson,
    retryCount,
    lastError,
    queuedAt,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.id == this.id &&
          other.entityTable == this.entityTable &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.queuedAt == this.queuedAt &&
          other.status == this.status);
}

class SyncQueueTableCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<String> id;
  final Value<String> entityTable;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<int> queuedAt;
  final Value<String> status;
  final Value<int> rowid;
  const SyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.queuedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueTableCompanion.insert({
    required String id,
    required String entityTable,
    required String entityId,
    required String operation,
    required String payloadJson,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required int queuedAt,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityTable = Value(entityTable),
       entityId = Value(entityId),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       queuedAt = Value(queuedAt);
  static Insertable<SyncQueueEntry> custom({
    Expression<String>? id,
    Expression<String>? entityTable,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<int>? queuedAt,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityTable != null) 'entity_table': entityTable,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (queuedAt != null) 'queued_at': queuedAt,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueTableCompanion copyWith({
    Value<String>? id,
    Value<String>? entityTable,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<int>? queuedAt,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return SyncQueueTableCompanion(
      id: id ?? this.id,
      entityTable: entityTable ?? this.entityTable,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      queuedAt: queuedAt ?? this.queuedAt,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (queuedAt.present) {
      map['queued_at'] = Variable<int>(queuedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settingKeyMeta = const VerificationMeta(
    'settingKey',
  );
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
    'setting_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settingValueMeta = const VerificationMeta(
    'settingValue',
  );
  @override
  late final GeneratedColumn<String> settingValue = GeneratedColumn<String>(
    'setting_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [settingKey, settingValue, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('setting_key')) {
      context.handle(
        _settingKeyMeta,
        settingKey.isAcceptableOrUnknown(data['setting_key']!, _settingKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('setting_value')) {
      context.handle(
        _settingValueMeta,
        settingValue.isAcceptableOrUnknown(
          data['setting_value']!,
          _settingValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settingValueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settingKey};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      settingKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_key'],
      )!,
      settingValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String settingKey;
  final String settingValue;
  final int updatedAt;
  const AppSetting({
    required this.settingKey,
    required this.settingValue,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['setting_key'] = Variable<String>(settingKey);
    map['setting_value'] = Variable<String>(settingValue);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      settingKey: Value(settingKey),
      settingValue: Value(settingValue),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      settingKey: serializer.fromJson<String>(json['settingKey']),
      settingValue: serializer.fromJson<String>(json['settingValue']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settingKey': serializer.toJson<String>(settingKey),
      'settingValue': serializer.toJson<String>(settingValue),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AppSetting copyWith({
    String? settingKey,
    String? settingValue,
    int? updatedAt,
  }) => AppSetting(
    settingKey: settingKey ?? this.settingKey,
    settingValue: settingValue ?? this.settingValue,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSetting copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSetting(
      settingKey: data.settingKey.present
          ? data.settingKey.value
          : this.settingKey,
      settingValue: data.settingValue.present
          ? data.settingValue.value
          : this.settingValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(settingKey, settingValue, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.settingKey == this.settingKey &&
          other.settingValue == this.settingValue &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> settingKey;
  final Value<String> settingValue;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AppSettingsTableCompanion({
    this.settingKey = const Value.absent(),
    this.settingValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    required String settingKey,
    required String settingValue,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : settingKey = Value(settingKey),
       settingValue = Value(settingValue),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? settingKey,
    Expression<String>? settingValue,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (settingKey != null) 'setting_key': settingKey,
      if (settingValue != null) 'setting_value': settingValue,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<String>? settingKey,
    Value<String>? settingValue,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsTableCompanion(
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (settingValue.present) {
      map['setting_value'] = Variable<String>(settingValue.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FarmsTableTable farmsTable = $FarmsTableTable(this);
  late final $ProjectsTableTable projectsTable = $ProjectsTableTable(this);
  late final $BudgetCategoriesTableTable budgetCategoriesTable =
      $BudgetCategoriesTableTable(this);
  late final $BudgetItemsTableTable budgetItemsTable = $BudgetItemsTableTable(
    this,
  );
  late final $ExpensesTableTable expensesTable = $ExpensesTableTable(this);
  late final $ActivitiesTableTable activitiesTable = $ActivitiesTableTable(
    this,
  );
  late final $HarvestsTableTable harvestsTable = $HarvestsTableTable(this);
  late final $BuyersTableTable buyersTable = $BuyersTableTable(this);
  late final $SalesTableTable salesTable = $SalesTableTable(this);
  late final $PaymentsTableTable paymentsTable = $PaymentsTableTable(this);
  late final $CashTransactionsTableTable cashTransactionsTable =
      $CashTransactionsTableTable(this);
  late final $ScenariosTableTable scenariosTable = $ScenariosTableTable(this);
  late final $RisksTableTable risksTable = $RisksTableTable(this);
  late final $AuditLogsTableTable auditLogsTable = $AuditLogsTableTable(this);
  late final $SyncQueueTableTable syncQueueTable = $SyncQueueTableTable(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    farmsTable,
    projectsTable,
    budgetCategoriesTable,
    budgetItemsTable,
    expensesTable,
    activitiesTable,
    harvestsTable,
    buyersTable,
    salesTable,
    paymentsTable,
    cashTransactionsTable,
    scenariosTable,
    risksTable,
    auditLogsTable,
    syncQueueTable,
    appSettingsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('budget_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'budget_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expenses', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('activities', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'buyers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sales', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'harvests',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sales', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cash_transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scenarios', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('risks', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$FarmsTableTableCreateCompanionBuilder =
    FarmsTableCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      required String name,
      required String location,
      Value<String?> district,
      required String region,
      Value<String> country,
      Value<double?> latitude,
      Value<double?> longitude,
      required double totalArea,
      Value<String> areaUnit,
      required String ownershipType,
      Value<String?> notes,
      Value<String?> photoPath,
      Value<int> rowid,
    });
typedef $$FarmsTableTableUpdateCompanionBuilder =
    FarmsTableCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<String> name,
      Value<String> location,
      Value<String?> district,
      Value<String> region,
      Value<String> country,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double> totalArea,
      Value<String> areaUnit,
      Value<String> ownershipType,
      Value<String?> notes,
      Value<String?> photoPath,
      Value<int> rowid,
    });

final class $$FarmsTableTableReferences
    extends BaseReferences<_$AppDatabase, $FarmsTableTable, Farm> {
  $$FarmsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProjectsTableTable, List<Project>>
  _projectsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.projectsTable,
    aliasName: $_aliasNameGenerator(db.farmsTable.id, db.projectsTable.farmId),
  );

  $$ProjectsTableTableProcessedTableManager get projectsTableRefs {
    final manager = $$ProjectsTableTableTableManager(
      $_db,
      $_db.projectsTable,
    ).filter((f) => f.farmId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FarmsTableTableFilterComposer
    extends Composer<_$AppDatabase, $FarmsTableTable> {
  $$FarmsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalArea => $composableBuilder(
    column: $table.totalArea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaUnit => $composableBuilder(
    column: $table.areaUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownershipType => $composableBuilder(
    column: $table.ownershipType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> projectsTableRefs(
    Expression<bool> Function($$ProjectsTableTableFilterComposer f) f,
  ) {
    final $$ProjectsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.farmId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableFilterComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FarmsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmsTableTable> {
  $$FarmsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalArea => $composableBuilder(
    column: $table.totalArea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaUnit => $composableBuilder(
    column: $table.areaUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownershipType => $composableBuilder(
    column: $table.ownershipType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FarmsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmsTableTable> {
  $$FarmsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get totalArea =>
      $composableBuilder(column: $table.totalArea, builder: (column) => column);

  GeneratedColumn<String> get areaUnit =>
      $composableBuilder(column: $table.areaUnit, builder: (column) => column);

  GeneratedColumn<String> get ownershipType => $composableBuilder(
    column: $table.ownershipType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  Expression<T> projectsTableRefs<T extends Object>(
    Expression<T> Function($$ProjectsTableTableAnnotationComposer a) f,
  ) {
    final $$ProjectsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.farmId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FarmsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmsTableTable,
          Farm,
          $$FarmsTableTableFilterComposer,
          $$FarmsTableTableOrderingComposer,
          $$FarmsTableTableAnnotationComposer,
          $$FarmsTableTableCreateCompanionBuilder,
          $$FarmsTableTableUpdateCompanionBuilder,
          (Farm, $$FarmsTableTableReferences),
          Farm,
          PrefetchHooks Function({bool projectsTableRefs})
        > {
  $$FarmsTableTableTableManager(_$AppDatabase db, $FarmsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double> totalArea = const Value.absent(),
                Value<String> areaUnit = const Value.absent(),
                Value<String> ownershipType = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmsTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                name: name,
                location: location,
                district: district,
                region: region,
                country: country,
                latitude: latitude,
                longitude: longitude,
                totalArea: totalArea,
                areaUnit: areaUnit,
                ownershipType: ownershipType,
                notes: notes,
                photoPath: photoPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String name,
                required String location,
                Value<String?> district = const Value.absent(),
                required String region,
                Value<String> country = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                required double totalArea,
                Value<String> areaUnit = const Value.absent(),
                required String ownershipType,
                Value<String?> notes = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmsTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                name: name,
                location: location,
                district: district,
                region: region,
                country: country,
                latitude: latitude,
                longitude: longitude,
                totalArea: totalArea,
                areaUnit: areaUnit,
                ownershipType: ownershipType,
                notes: notes,
                photoPath: photoPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FarmsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (projectsTableRefs) db.projectsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (projectsTableRefs)
                    await $_getPrefetchedData<Farm, $FarmsTableTable, Project>(
                      currentTable: table,
                      referencedTable: $$FarmsTableTableReferences
                          ._projectsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FarmsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).projectsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.farmId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FarmsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmsTableTable,
      Farm,
      $$FarmsTableTableFilterComposer,
      $$FarmsTableTableOrderingComposer,
      $$FarmsTableTableAnnotationComposer,
      $$FarmsTableTableCreateCompanionBuilder,
      $$FarmsTableTableUpdateCompanionBuilder,
      (Farm, $$FarmsTableTableReferences),
      Farm,
      PrefetchHooks Function({bool projectsTableRefs})
    >;
typedef $$ProjectsTableTableCreateCompanionBuilder =
    ProjectsTableCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      required String farmId,
      required String name,
      required String projectType,
      required String commodity,
      Value<String?> variety,
      required double landSize,
      Value<String> landUnit,
      required int startDate,
      Value<int?> expectedCompletionDate,
      Value<int?> expectedFirstHarvestDate,
      Value<String> currency,
      Value<String> status,
      Value<String?> description,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$ProjectsTableTableUpdateCompanionBuilder =
    ProjectsTableCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<String> farmId,
      Value<String> name,
      Value<String> projectType,
      Value<String> commodity,
      Value<String?> variety,
      Value<double> landSize,
      Value<String> landUnit,
      Value<int> startDate,
      Value<int?> expectedCompletionDate,
      Value<int?> expectedFirstHarvestDate,
      Value<String> currency,
      Value<String> status,
      Value<String?> description,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$ProjectsTableTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTableTable, Project> {
  $$ProjectsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FarmsTableTable _farmIdTable(_$AppDatabase db) =>
      db.farmsTable.createAlias(
        $_aliasNameGenerator(db.projectsTable.farmId, db.farmsTable.id),
      );

  $$FarmsTableTableProcessedTableManager get farmId {
    final $_column = $_itemColumn<String>('farm_id')!;

    final manager = $$FarmsTableTableTableManager(
      $_db,
      $_db.farmsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_farmIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BudgetItemsTableTable, List<BudgetItem>>
  _budgetItemsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.budgetItemsTable,
    aliasName: $_aliasNameGenerator(
      db.projectsTable.id,
      db.budgetItemsTable.projectId,
    ),
  );

  $$BudgetItemsTableTableProcessedTableManager get budgetItemsTableRefs {
    final manager = $$BudgetItemsTableTableTableManager(
      $_db,
      $_db.budgetItemsTable,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _budgetItemsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTableTable, List<Expense>>
  _expensesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expensesTable,
    aliasName: $_aliasNameGenerator(
      db.projectsTable.id,
      db.expensesTable.projectId,
    ),
  );

  $$ExpensesTableTableProcessedTableManager get expensesTableRefs {
    final manager = $$ExpensesTableTableTableManager(
      $_db,
      $_db.expensesTable,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActivitiesTableTable, List<Activity>>
  _activitiesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activitiesTable,
    aliasName: $_aliasNameGenerator(
      db.projectsTable.id,
      db.activitiesTable.projectId,
    ),
  );

  $$ActivitiesTableTableProcessedTableManager get activitiesTableRefs {
    final manager = $$ActivitiesTableTableTableManager(
      $_db,
      $_db.activitiesTable,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _activitiesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HarvestsTableTable, List<Harvest>>
  _harvestsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.harvestsTable,
    aliasName: $_aliasNameGenerator(
      db.projectsTable.id,
      db.harvestsTable.projectId,
    ),
  );

  $$HarvestsTableTableProcessedTableManager get harvestsTableRefs {
    final manager = $$HarvestsTableTableTableManager(
      $_db,
      $_db.harvestsTable,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_harvestsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SalesTableTable, List<Sale>> _salesTableRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.salesTable,
    aliasName: $_aliasNameGenerator(
      db.projectsTable.id,
      db.salesTable.projectId,
    ),
  );

  $$SalesTableTableProcessedTableManager get salesTableRefs {
    final manager = $$SalesTableTableTableManager(
      $_db,
      $_db.salesTable,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_salesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CashTransactionsTableTable, List<CashTransaction>>
  _cashTransactionsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.cashTransactionsTable,
        aliasName: $_aliasNameGenerator(
          db.projectsTable.id,
          db.cashTransactionsTable.projectId,
        ),
      );

  $$CashTransactionsTableTableProcessedTableManager
  get cashTransactionsTableRefs {
    final manager = $$CashTransactionsTableTableTableManager(
      $_db,
      $_db.cashTransactionsTable,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cashTransactionsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScenariosTableTable, List<Scenario>>
  _scenariosTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scenariosTable,
    aliasName: $_aliasNameGenerator(
      db.projectsTable.id,
      db.scenariosTable.projectId,
    ),
  );

  $$ScenariosTableTableProcessedTableManager get scenariosTableRefs {
    final manager = $$ScenariosTableTableTableManager(
      $_db,
      $_db.scenariosTable,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_scenariosTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RisksTableTable, List<Risk>> _risksTableRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.risksTable,
    aliasName: $_aliasNameGenerator(
      db.projectsTable.id,
      db.risksTable.projectId,
    ),
  );

  $$RisksTableTableProcessedTableManager get risksTableRefs {
    final manager = $$RisksTableTableTableManager(
      $_db,
      $_db.risksTable,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_risksTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTableTable> {
  $$ProjectsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectType => $composableBuilder(
    column: $table.projectType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commodity => $composableBuilder(
    column: $table.commodity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variety => $composableBuilder(
    column: $table.variety,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get landSize => $composableBuilder(
    column: $table.landSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get landUnit => $composableBuilder(
    column: $table.landUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedCompletionDate => $composableBuilder(
    column: $table.expectedCompletionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedFirstHarvestDate => $composableBuilder(
    column: $table.expectedFirstHarvestDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$FarmsTableTableFilterComposer get farmId {
    final $$FarmsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.farmId,
      referencedTable: $db.farmsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmsTableTableFilterComposer(
            $db: $db,
            $table: $db.farmsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> budgetItemsTableRefs(
    Expression<bool> Function($$BudgetItemsTableTableFilterComposer f) f,
  ) {
    final $$BudgetItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetItemsTable,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.budgetItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesTableRefs(
    Expression<bool> Function($$ExpensesTableTableFilterComposer f) f,
  ) {
    final $$ExpensesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expensesTable,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableTableFilterComposer(
            $db: $db,
            $table: $db.expensesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activitiesTableRefs(
    Expression<bool> Function($$ActivitiesTableTableFilterComposer f) f,
  ) {
    final $$ActivitiesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activitiesTable,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableTableFilterComposer(
            $db: $db,
            $table: $db.activitiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> harvestsTableRefs(
    Expression<bool> Function($$HarvestsTableTableFilterComposer f) f,
  ) {
    final $$HarvestsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.harvestsTable,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HarvestsTableTableFilterComposer(
            $db: $db,
            $table: $db.harvestsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> salesTableRefs(
    Expression<bool> Function($$SalesTableTableFilterComposer f) f,
  ) {
    final $$SalesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableFilterComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cashTransactionsTableRefs(
    Expression<bool> Function($$CashTransactionsTableTableFilterComposer f) f,
  ) {
    final $$CashTransactionsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.cashTransactionsTable,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CashTransactionsTableTableFilterComposer(
                $db: $db,
                $table: $db.cashTransactionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> scenariosTableRefs(
    Expression<bool> Function($$ScenariosTableTableFilterComposer f) f,
  ) {
    final $$ScenariosTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scenariosTable,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenariosTableTableFilterComposer(
            $db: $db,
            $table: $db.scenariosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> risksTableRefs(
    Expression<bool> Function($$RisksTableTableFilterComposer f) f,
  ) {
    final $$RisksTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.risksTable,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RisksTableTableFilterComposer(
            $db: $db,
            $table: $db.risksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTableTable> {
  $$ProjectsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectType => $composableBuilder(
    column: $table.projectType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commodity => $composableBuilder(
    column: $table.commodity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variety => $composableBuilder(
    column: $table.variety,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get landSize => $composableBuilder(
    column: $table.landSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get landUnit => $composableBuilder(
    column: $table.landUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedCompletionDate => $composableBuilder(
    column: $table.expectedCompletionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedFirstHarvestDate => $composableBuilder(
    column: $table.expectedFirstHarvestDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$FarmsTableTableOrderingComposer get farmId {
    final $$FarmsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.farmId,
      referencedTable: $db.farmsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmsTableTableOrderingComposer(
            $db: $db,
            $table: $db.farmsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTableTable> {
  $$ProjectsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get projectType => $composableBuilder(
    column: $table.projectType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commodity =>
      $composableBuilder(column: $table.commodity, builder: (column) => column);

  GeneratedColumn<String> get variety =>
      $composableBuilder(column: $table.variety, builder: (column) => column);

  GeneratedColumn<double> get landSize =>
      $composableBuilder(column: $table.landSize, builder: (column) => column);

  GeneratedColumn<String> get landUnit =>
      $composableBuilder(column: $table.landUnit, builder: (column) => column);

  GeneratedColumn<int> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get expectedCompletionDate => $composableBuilder(
    column: $table.expectedCompletionDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedFirstHarvestDate => $composableBuilder(
    column: $table.expectedFirstHarvestDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$FarmsTableTableAnnotationComposer get farmId {
    final $$FarmsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.farmId,
      referencedTable: $db.farmsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.farmsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> budgetItemsTableRefs<T extends Object>(
    Expression<T> Function($$BudgetItemsTableTableAnnotationComposer a) f,
  ) {
    final $$BudgetItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetItemsTable,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.budgetItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesTableRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expensesTable,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.expensesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activitiesTableRefs<T extends Object>(
    Expression<T> Function($$ActivitiesTableTableAnnotationComposer a) f,
  ) {
    final $$ActivitiesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activitiesTable,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.activitiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> harvestsTableRefs<T extends Object>(
    Expression<T> Function($$HarvestsTableTableAnnotationComposer a) f,
  ) {
    final $$HarvestsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.harvestsTable,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HarvestsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.harvestsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> salesTableRefs<T extends Object>(
    Expression<T> Function($$SalesTableTableAnnotationComposer a) f,
  ) {
    final $$SalesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cashTransactionsTableRefs<T extends Object>(
    Expression<T> Function($$CashTransactionsTableTableAnnotationComposer a) f,
  ) {
    final $$CashTransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.cashTransactionsTable,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CashTransactionsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.cashTransactionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> scenariosTableRefs<T extends Object>(
    Expression<T> Function($$ScenariosTableTableAnnotationComposer a) f,
  ) {
    final $$ScenariosTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scenariosTable,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenariosTableTableAnnotationComposer(
            $db: $db,
            $table: $db.scenariosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> risksTableRefs<T extends Object>(
    Expression<T> Function($$RisksTableTableAnnotationComposer a) f,
  ) {
    final $$RisksTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.risksTable,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RisksTableTableAnnotationComposer(
            $db: $db,
            $table: $db.risksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTableTable,
          Project,
          $$ProjectsTableTableFilterComposer,
          $$ProjectsTableTableOrderingComposer,
          $$ProjectsTableTableAnnotationComposer,
          $$ProjectsTableTableCreateCompanionBuilder,
          $$ProjectsTableTableUpdateCompanionBuilder,
          (Project, $$ProjectsTableTableReferences),
          Project,
          PrefetchHooks Function({
            bool farmId,
            bool budgetItemsTableRefs,
            bool expensesTableRefs,
            bool activitiesTableRefs,
            bool harvestsTableRefs,
            bool salesTableRefs,
            bool cashTransactionsTableRefs,
            bool scenariosTableRefs,
            bool risksTableRefs,
          })
        > {
  $$ProjectsTableTableTableManager(_$AppDatabase db, $ProjectsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> projectType = const Value.absent(),
                Value<String> commodity = const Value.absent(),
                Value<String?> variety = const Value.absent(),
                Value<double> landSize = const Value.absent(),
                Value<String> landUnit = const Value.absent(),
                Value<int> startDate = const Value.absent(),
                Value<int?> expectedCompletionDate = const Value.absent(),
                Value<int?> expectedFirstHarvestDate = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                farmId: farmId,
                name: name,
                projectType: projectType,
                commodity: commodity,
                variety: variety,
                landSize: landSize,
                landUnit: landUnit,
                startDate: startDate,
                expectedCompletionDate: expectedCompletionDate,
                expectedFirstHarvestDate: expectedFirstHarvestDate,
                currency: currency,
                status: status,
                description: description,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String farmId,
                required String name,
                required String projectType,
                required String commodity,
                Value<String?> variety = const Value.absent(),
                required double landSize,
                Value<String> landUnit = const Value.absent(),
                required int startDate,
                Value<int?> expectedCompletionDate = const Value.absent(),
                Value<int?> expectedFirstHarvestDate = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                farmId: farmId,
                name: name,
                projectType: projectType,
                commodity: commodity,
                variety: variety,
                landSize: landSize,
                landUnit: landUnit,
                startDate: startDate,
                expectedCompletionDate: expectedCompletionDate,
                expectedFirstHarvestDate: expectedFirstHarvestDate,
                currency: currency,
                status: status,
                description: description,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                farmId = false,
                budgetItemsTableRefs = false,
                expensesTableRefs = false,
                activitiesTableRefs = false,
                harvestsTableRefs = false,
                salesTableRefs = false,
                cashTransactionsTableRefs = false,
                scenariosTableRefs = false,
                risksTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (budgetItemsTableRefs) db.budgetItemsTable,
                    if (expensesTableRefs) db.expensesTable,
                    if (activitiesTableRefs) db.activitiesTable,
                    if (harvestsTableRefs) db.harvestsTable,
                    if (salesTableRefs) db.salesTable,
                    if (cashTransactionsTableRefs) db.cashTransactionsTable,
                    if (scenariosTableRefs) db.scenariosTable,
                    if (risksTableRefs) db.risksTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (farmId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.farmId,
                                    referencedTable:
                                        $$ProjectsTableTableReferences
                                            ._farmIdTable(db),
                                    referencedColumn:
                                        $$ProjectsTableTableReferences
                                            ._farmIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (budgetItemsTableRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTableTable,
                          BudgetItem
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableTableReferences
                              ._budgetItemsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetItemsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (expensesTableRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTableTable,
                          Expense
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableTableReferences
                              ._expensesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (activitiesTableRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTableTable,
                          Activity
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableTableReferences
                              ._activitiesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).activitiesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (harvestsTableRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTableTable,
                          Harvest
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableTableReferences
                              ._harvestsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).harvestsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (salesTableRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTableTable,
                          Sale
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableTableReferences
                              ._salesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).salesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cashTransactionsTableRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTableTable,
                          CashTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableTableReferences
                              ._cashTransactionsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).cashTransactionsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scenariosTableRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTableTable,
                          Scenario
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableTableReferences
                              ._scenariosTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).scenariosTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (risksTableRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTableTable,
                          Risk
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableTableReferences
                              ._risksTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).risksTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProjectsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTableTable,
      Project,
      $$ProjectsTableTableFilterComposer,
      $$ProjectsTableTableOrderingComposer,
      $$ProjectsTableTableAnnotationComposer,
      $$ProjectsTableTableCreateCompanionBuilder,
      $$ProjectsTableTableUpdateCompanionBuilder,
      (Project, $$ProjectsTableTableReferences),
      Project,
      PrefetchHooks Function({
        bool farmId,
        bool budgetItemsTableRefs,
        bool expensesTableRefs,
        bool activitiesTableRefs,
        bool harvestsTableRefs,
        bool salesTableRefs,
        bool cashTransactionsTableRefs,
        bool scenariosTableRefs,
        bool risksTableRefs,
      })
    >;
typedef $$BudgetCategoriesTableTableCreateCompanionBuilder =
    BudgetCategoriesTableCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      required String name,
      Value<String?> description,
      Value<String?> iconName,
      Value<bool> isSystemDefault,
      Value<int> displayOrder,
      Value<int> rowid,
    });
typedef $$BudgetCategoriesTableTableUpdateCompanionBuilder =
    BudgetCategoriesTableCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<String> name,
      Value<String?> description,
      Value<String?> iconName,
      Value<bool> isSystemDefault,
      Value<int> displayOrder,
      Value<int> rowid,
    });

final class $$BudgetCategoriesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BudgetCategoriesTableTable,
          BudgetCategory
        > {
  $$BudgetCategoriesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$BudgetItemsTableTable, List<BudgetItem>>
  _budgetItemsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.budgetItemsTable,
    aliasName: $_aliasNameGenerator(
      db.budgetCategoriesTable.id,
      db.budgetItemsTable.categoryId,
    ),
  );

  $$BudgetItemsTableTableProcessedTableManager get budgetItemsTableRefs {
    final manager = $$BudgetItemsTableTableTableManager(
      $_db,
      $_db.budgetItemsTable,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _budgetItemsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTableTable, List<Expense>>
  _expensesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expensesTable,
    aliasName: $_aliasNameGenerator(
      db.budgetCategoriesTable.id,
      db.expensesTable.categoryId,
    ),
  );

  $$ExpensesTableTableProcessedTableManager get expensesTableRefs {
    final manager = $$ExpensesTableTableTableManager(
      $_db,
      $_db.expensesTable,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BudgetCategoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetCategoriesTableTable> {
  $$BudgetCategoriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystemDefault => $composableBuilder(
    column: $table.isSystemDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> budgetItemsTableRefs(
    Expression<bool> Function($$BudgetItemsTableTableFilterComposer f) f,
  ) {
    final $$BudgetItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetItemsTable,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.budgetItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesTableRefs(
    Expression<bool> Function($$ExpensesTableTableFilterComposer f) f,
  ) {
    final $$ExpensesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expensesTable,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableTableFilterComposer(
            $db: $db,
            $table: $db.expensesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BudgetCategoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetCategoriesTableTable> {
  $$BudgetCategoriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystemDefault => $composableBuilder(
    column: $table.isSystemDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetCategoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetCategoriesTableTable> {
  $$BudgetCategoriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<bool> get isSystemDefault => $composableBuilder(
    column: $table.isSystemDefault,
    builder: (column) => column,
  );

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  Expression<T> budgetItemsTableRefs<T extends Object>(
    Expression<T> Function($$BudgetItemsTableTableAnnotationComposer a) f,
  ) {
    final $$BudgetItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetItemsTable,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.budgetItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesTableRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expensesTable,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.expensesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BudgetCategoriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetCategoriesTableTable,
          BudgetCategory,
          $$BudgetCategoriesTableTableFilterComposer,
          $$BudgetCategoriesTableTableOrderingComposer,
          $$BudgetCategoriesTableTableAnnotationComposer,
          $$BudgetCategoriesTableTableCreateCompanionBuilder,
          $$BudgetCategoriesTableTableUpdateCompanionBuilder,
          (BudgetCategory, $$BudgetCategoriesTableTableReferences),
          BudgetCategory,
          PrefetchHooks Function({
            bool budgetItemsTableRefs,
            bool expensesTableRefs,
          })
        > {
  $$BudgetCategoriesTableTableTableManager(
    _$AppDatabase db,
    $BudgetCategoriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetCategoriesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BudgetCategoriesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BudgetCategoriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> iconName = const Value.absent(),
                Value<bool> isSystemDefault = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetCategoriesTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                name: name,
                description: description,
                iconName: iconName,
                isSystemDefault: isSystemDefault,
                displayOrder: displayOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> iconName = const Value.absent(),
                Value<bool> isSystemDefault = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetCategoriesTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                name: name,
                description: description,
                iconName: iconName,
                isSystemDefault: isSystemDefault,
                displayOrder: displayOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetCategoriesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({budgetItemsTableRefs = false, expensesTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (budgetItemsTableRefs) db.budgetItemsTable,
                    if (expensesTableRefs) db.expensesTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (budgetItemsTableRefs)
                        await $_getPrefetchedData<
                          BudgetCategory,
                          $BudgetCategoriesTableTable,
                          BudgetItem
                        >(
                          currentTable: table,
                          referencedTable:
                              $$BudgetCategoriesTableTableReferences
                                  ._budgetItemsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BudgetCategoriesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetItemsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (expensesTableRefs)
                        await $_getPrefetchedData<
                          BudgetCategory,
                          $BudgetCategoriesTableTable,
                          Expense
                        >(
                          currentTable: table,
                          referencedTable:
                              $$BudgetCategoriesTableTableReferences
                                  ._expensesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BudgetCategoriesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BudgetCategoriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetCategoriesTableTable,
      BudgetCategory,
      $$BudgetCategoriesTableTableFilterComposer,
      $$BudgetCategoriesTableTableOrderingComposer,
      $$BudgetCategoriesTableTableAnnotationComposer,
      $$BudgetCategoriesTableTableCreateCompanionBuilder,
      $$BudgetCategoriesTableTableUpdateCompanionBuilder,
      (BudgetCategory, $$BudgetCategoriesTableTableReferences),
      BudgetCategory,
      PrefetchHooks Function({
        bool budgetItemsTableRefs,
        bool expensesTableRefs,
      })
    >;
typedef $$BudgetItemsTableTableCreateCompanionBuilder =
    BudgetItemsTableCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      required String projectId,
      required String categoryId,
      required String name,
      Value<String?> description,
      required double quantity,
      required String unit,
      required int unitCostMinor,
      required int plannedAmountMinor,
      Value<String> currency,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$BudgetItemsTableTableUpdateCompanionBuilder =
    BudgetItemsTableCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<String> projectId,
      Value<String> categoryId,
      Value<String> name,
      Value<String?> description,
      Value<double> quantity,
      Value<String> unit,
      Value<int> unitCostMinor,
      Value<int> plannedAmountMinor,
      Value<String> currency,
      Value<String> status,
      Value<int> rowid,
    });

final class $$BudgetItemsTableTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetItemsTableTable, BudgetItem> {
  $$BudgetItemsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectsTableTable _projectIdTable(_$AppDatabase db) =>
      db.projectsTable.createAlias(
        $_aliasNameGenerator(
          db.budgetItemsTable.projectId,
          db.projectsTable.id,
        ),
      );

  $$ProjectsTableTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableTableManager(
      $_db,
      $_db.projectsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BudgetCategoriesTableTable _categoryIdTable(_$AppDatabase db) =>
      db.budgetCategoriesTable.createAlias(
        $_aliasNameGenerator(
          db.budgetItemsTable.categoryId,
          db.budgetCategoriesTable.id,
        ),
      );

  $$BudgetCategoriesTableTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$BudgetCategoriesTableTableTableManager(
      $_db,
      $_db.budgetCategoriesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExpensesTableTable, List<Expense>>
  _expensesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expensesTable,
    aliasName: $_aliasNameGenerator(
      db.budgetItemsTable.id,
      db.expensesTable.budgetItemId,
    ),
  );

  $$ExpensesTableTableProcessedTableManager get expensesTableRefs {
    final manager = $$ExpensesTableTableTableManager(
      $_db,
      $_db.expensesTable,
    ).filter((f) => f.budgetItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BudgetItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetItemsTableTable> {
  $$BudgetItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedAmountMinor => $composableBuilder(
    column: $table.plannedAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableTableFilterComposer get projectId {
    final $$ProjectsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableFilterComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BudgetCategoriesTableTableFilterComposer get categoryId {
    final $$BudgetCategoriesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.budgetCategoriesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BudgetCategoriesTableTableFilterComposer(
                $db: $db,
                $table: $db.budgetCategoriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> expensesTableRefs(
    Expression<bool> Function($$ExpensesTableTableFilterComposer f) f,
  ) {
    final $$ExpensesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expensesTable,
      getReferencedColumn: (t) => t.budgetItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableTableFilterComposer(
            $db: $db,
            $table: $db.expensesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BudgetItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetItemsTableTable> {
  $$BudgetItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedAmountMinor => $composableBuilder(
    column: $table.plannedAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableTableOrderingComposer get projectId {
    final $$ProjectsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableOrderingComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BudgetCategoriesTableTableOrderingComposer get categoryId {
    final $$BudgetCategoriesTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.budgetCategoriesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BudgetCategoriesTableTableOrderingComposer(
                $db: $db,
                $table: $db.budgetCategoriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$BudgetItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetItemsTableTable> {
  $$BudgetItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedAmountMinor => $composableBuilder(
    column: $table.plannedAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$ProjectsTableTableAnnotationComposer get projectId {
    final $$ProjectsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BudgetCategoriesTableTableAnnotationComposer get categoryId {
    final $$BudgetCategoriesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.budgetCategoriesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BudgetCategoriesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.budgetCategoriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> expensesTableRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expensesTable,
      getReferencedColumn: (t) => t.budgetItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.expensesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BudgetItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetItemsTableTable,
          BudgetItem,
          $$BudgetItemsTableTableFilterComposer,
          $$BudgetItemsTableTableOrderingComposer,
          $$BudgetItemsTableTableAnnotationComposer,
          $$BudgetItemsTableTableCreateCompanionBuilder,
          $$BudgetItemsTableTableUpdateCompanionBuilder,
          (BudgetItem, $$BudgetItemsTableTableReferences),
          BudgetItem,
          PrefetchHooks Function({
            bool projectId,
            bool categoryId,
            bool expensesTableRefs,
          })
        > {
  $$BudgetItemsTableTableTableManager(
    _$AppDatabase db,
    $BudgetItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetItemsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int> unitCostMinor = const Value.absent(),
                Value<int> plannedAmountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetItemsTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                categoryId: categoryId,
                name: name,
                description: description,
                quantity: quantity,
                unit: unit,
                unitCostMinor: unitCostMinor,
                plannedAmountMinor: plannedAmountMinor,
                currency: currency,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String projectId,
                required String categoryId,
                required String name,
                Value<String?> description = const Value.absent(),
                required double quantity,
                required String unit,
                required int unitCostMinor,
                required int plannedAmountMinor,
                Value<String> currency = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetItemsTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                categoryId: categoryId,
                name: name,
                description: description,
                quantity: quantity,
                unit: unit,
                unitCostMinor: unitCostMinor,
                plannedAmountMinor: plannedAmountMinor,
                currency: currency,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetItemsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectId = false,
                categoryId = false,
                expensesTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (expensesTableRefs) db.expensesTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable:
                                        $$BudgetItemsTableTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$BudgetItemsTableTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$BudgetItemsTableTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$BudgetItemsTableTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (expensesTableRefs)
                        await $_getPrefetchedData<
                          BudgetItem,
                          $BudgetItemsTableTable,
                          Expense
                        >(
                          currentTable: table,
                          referencedTable: $$BudgetItemsTableTableReferences
                              ._expensesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BudgetItemsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.budgetItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BudgetItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetItemsTableTable,
      BudgetItem,
      $$BudgetItemsTableTableFilterComposer,
      $$BudgetItemsTableTableOrderingComposer,
      $$BudgetItemsTableTableAnnotationComposer,
      $$BudgetItemsTableTableCreateCompanionBuilder,
      $$BudgetItemsTableTableUpdateCompanionBuilder,
      (BudgetItem, $$BudgetItemsTableTableReferences),
      BudgetItem,
      PrefetchHooks Function({
        bool projectId,
        bool categoryId,
        bool expensesTableRefs,
      })
    >;
typedef $$ExpensesTableTableCreateCompanionBuilder =
    ExpensesTableCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      required String projectId,
      required String categoryId,
      Value<String?> budgetItemId,
      Value<String?> activityId,
      required int transactionDate,
      required String description,
      Value<double> quantity,
      Value<String?> unit,
      Value<int?> unitCostMinor,
      required int amountMinor,
      Value<String> currency,
      required String paymentMethod,
      Value<String?> vendorName,
      Value<String?> receiptPhotoPath,
      Value<String?> notes,
      Value<bool> isVoided,
      Value<int?> voidedAt,
      Value<String?> voidReason,
      Value<int> rowid,
    });
typedef $$ExpensesTableTableUpdateCompanionBuilder =
    ExpensesTableCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<String> projectId,
      Value<String> categoryId,
      Value<String?> budgetItemId,
      Value<String?> activityId,
      Value<int> transactionDate,
      Value<String> description,
      Value<double> quantity,
      Value<String?> unit,
      Value<int?> unitCostMinor,
      Value<int> amountMinor,
      Value<String> currency,
      Value<String> paymentMethod,
      Value<String?> vendorName,
      Value<String?> receiptPhotoPath,
      Value<String?> notes,
      Value<bool> isVoided,
      Value<int?> voidedAt,
      Value<String?> voidReason,
      Value<int> rowid,
    });

final class $$ExpensesTableTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTableTable, Expense> {
  $$ExpensesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectsTableTable _projectIdTable(_$AppDatabase db) =>
      db.projectsTable.createAlias(
        $_aliasNameGenerator(db.expensesTable.projectId, db.projectsTable.id),
      );

  $$ProjectsTableTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableTableManager(
      $_db,
      $_db.projectsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BudgetCategoriesTableTable _categoryIdTable(_$AppDatabase db) =>
      db.budgetCategoriesTable.createAlias(
        $_aliasNameGenerator(
          db.expensesTable.categoryId,
          db.budgetCategoriesTable.id,
        ),
      );

  $$BudgetCategoriesTableTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$BudgetCategoriesTableTableTableManager(
      $_db,
      $_db.budgetCategoriesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BudgetItemsTableTable _budgetItemIdTable(_$AppDatabase db) =>
      db.budgetItemsTable.createAlias(
        $_aliasNameGenerator(
          db.expensesTable.budgetItemId,
          db.budgetItemsTable.id,
        ),
      );

  $$BudgetItemsTableTableProcessedTableManager? get budgetItemId {
    final $_column = $_itemColumn<String>('budget_item_id');
    if ($_column == null) return null;
    final manager = $$BudgetItemsTableTableTableManager(
      $_db,
      $_db.budgetItemsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_budgetItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vendorName => $composableBuilder(
    column: $table.vendorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptPhotoPath => $composableBuilder(
    column: $table.receiptPhotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVoided => $composableBuilder(
    column: $table.isVoided,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableTableFilterComposer get projectId {
    final $$ProjectsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableFilterComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BudgetCategoriesTableTableFilterComposer get categoryId {
    final $$BudgetCategoriesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.budgetCategoriesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BudgetCategoriesTableTableFilterComposer(
                $db: $db,
                $table: $db.budgetCategoriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$BudgetItemsTableTableFilterComposer get budgetItemId {
    final $$BudgetItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetItemId,
      referencedTable: $db.budgetItemsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.budgetItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vendorName => $composableBuilder(
    column: $table.vendorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptPhotoPath => $composableBuilder(
    column: $table.receiptPhotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVoided => $composableBuilder(
    column: $table.isVoided,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableTableOrderingComposer get projectId {
    final $$ProjectsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableOrderingComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BudgetCategoriesTableTableOrderingComposer get categoryId {
    final $$BudgetCategoriesTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.budgetCategoriesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BudgetCategoriesTableTableOrderingComposer(
                $db: $db,
                $table: $db.budgetCategoriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$BudgetItemsTableTableOrderingComposer get budgetItemId {
    final $$BudgetItemsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetItemId,
      referencedTable: $db.budgetItemsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetItemsTableTableOrderingComposer(
            $db: $db,
            $table: $db.budgetItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vendorName => $composableBuilder(
    column: $table.vendorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptPhotoPath => $composableBuilder(
    column: $table.receiptPhotoPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isVoided =>
      $composableBuilder(column: $table.isVoided, builder: (column) => column);

  GeneratedColumn<int> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  $$ProjectsTableTableAnnotationComposer get projectId {
    final $$ProjectsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BudgetCategoriesTableTableAnnotationComposer get categoryId {
    final $$BudgetCategoriesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.budgetCategoriesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BudgetCategoriesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.budgetCategoriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$BudgetItemsTableTableAnnotationComposer get budgetItemId {
    final $$BudgetItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetItemId,
      referencedTable: $db.budgetItemsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.budgetItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTableTable,
          Expense,
          $$ExpensesTableTableFilterComposer,
          $$ExpensesTableTableOrderingComposer,
          $$ExpensesTableTableAnnotationComposer,
          $$ExpensesTableTableCreateCompanionBuilder,
          $$ExpensesTableTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableTableReferences),
          Expense,
          PrefetchHooks Function({
            bool projectId,
            bool categoryId,
            bool budgetItemId,
          })
        > {
  $$ExpensesTableTableTableManager(_$AppDatabase db, $ExpensesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> budgetItemId = const Value.absent(),
                Value<String?> activityId = const Value.absent(),
                Value<int> transactionDate = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<int?> unitCostMinor = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> vendorName = const Value.absent(),
                Value<String?> receiptPhotoPath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isVoided = const Value.absent(),
                Value<int?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                categoryId: categoryId,
                budgetItemId: budgetItemId,
                activityId: activityId,
                transactionDate: transactionDate,
                description: description,
                quantity: quantity,
                unit: unit,
                unitCostMinor: unitCostMinor,
                amountMinor: amountMinor,
                currency: currency,
                paymentMethod: paymentMethod,
                vendorName: vendorName,
                receiptPhotoPath: receiptPhotoPath,
                notes: notes,
                isVoided: isVoided,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String projectId,
                required String categoryId,
                Value<String?> budgetItemId = const Value.absent(),
                Value<String?> activityId = const Value.absent(),
                required int transactionDate,
                required String description,
                Value<double> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<int?> unitCostMinor = const Value.absent(),
                required int amountMinor,
                Value<String> currency = const Value.absent(),
                required String paymentMethod,
                Value<String?> vendorName = const Value.absent(),
                Value<String?> receiptPhotoPath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isVoided = const Value.absent(),
                Value<int?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                categoryId: categoryId,
                budgetItemId: budgetItemId,
                activityId: activityId,
                transactionDate: transactionDate,
                description: description,
                quantity: quantity,
                unit: unit,
                unitCostMinor: unitCostMinor,
                amountMinor: amountMinor,
                currency: currency,
                paymentMethod: paymentMethod,
                vendorName: vendorName,
                receiptPhotoPath: receiptPhotoPath,
                notes: notes,
                isVoided: isVoided,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpensesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({projectId = false, categoryId = false, budgetItemId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable:
                                        $$ExpensesTableTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$ExpensesTableTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$ExpensesTableTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$ExpensesTableTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (budgetItemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.budgetItemId,
                                    referencedTable:
                                        $$ExpensesTableTableReferences
                                            ._budgetItemIdTable(db),
                                    referencedColumn:
                                        $$ExpensesTableTableReferences
                                            ._budgetItemIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ExpensesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTableTable,
      Expense,
      $$ExpensesTableTableFilterComposer,
      $$ExpensesTableTableOrderingComposer,
      $$ExpensesTableTableAnnotationComposer,
      $$ExpensesTableTableCreateCompanionBuilder,
      $$ExpensesTableTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableTableReferences),
      Expense,
      PrefetchHooks Function({
        bool projectId,
        bool categoryId,
        bool budgetItemId,
      })
    >;
typedef $$ActivitiesTableTableCreateCompanionBuilder =
    ActivitiesTableCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      required String projectId,
      required String activityType,
      required String title,
      required int activityDate,
      Value<String?> description,
      Value<int> labourCount,
      Value<double?> durationHours,
      Value<int> costMinor,
      Value<String> currency,
      Value<String> status,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$ActivitiesTableTableUpdateCompanionBuilder =
    ActivitiesTableCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<String> projectId,
      Value<String> activityType,
      Value<String> title,
      Value<int> activityDate,
      Value<String?> description,
      Value<int> labourCount,
      Value<double?> durationHours,
      Value<int> costMinor,
      Value<String> currency,
      Value<String> status,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$ActivitiesTableTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTableTable, Activity> {
  $$ActivitiesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectsTableTable _projectIdTable(_$AppDatabase db) =>
      db.projectsTable.createAlias(
        $_aliasNameGenerator(db.activitiesTable.projectId, db.projectsTable.id),
      );

  $$ProjectsTableTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableTableManager(
      $_db,
      $_db.projectsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActivitiesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTableTable> {
  $$ActivitiesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activityDate => $composableBuilder(
    column: $table.activityDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get labourCount => $composableBuilder(
    column: $table.labourCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get durationHours => $composableBuilder(
    column: $table.durationHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costMinor => $composableBuilder(
    column: $table.costMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableTableFilterComposer get projectId {
    final $$ProjectsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableFilterComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTableTable> {
  $$ActivitiesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activityDate => $composableBuilder(
    column: $table.activityDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get labourCount => $composableBuilder(
    column: $table.labourCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get durationHours => $composableBuilder(
    column: $table.durationHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costMinor => $composableBuilder(
    column: $table.costMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableTableOrderingComposer get projectId {
    final $$ProjectsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableOrderingComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTableTable> {
  $$ActivitiesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get activityDate => $composableBuilder(
    column: $table.activityDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get labourCount => $composableBuilder(
    column: $table.labourCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get durationHours => $composableBuilder(
    column: $table.durationHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get costMinor =>
      $composableBuilder(column: $table.costMinor, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$ProjectsTableTableAnnotationComposer get projectId {
    final $$ProjectsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTableTable,
          Activity,
          $$ActivitiesTableTableFilterComposer,
          $$ActivitiesTableTableOrderingComposer,
          $$ActivitiesTableTableAnnotationComposer,
          $$ActivitiesTableTableCreateCompanionBuilder,
          $$ActivitiesTableTableUpdateCompanionBuilder,
          (Activity, $$ActivitiesTableTableReferences),
          Activity,
          PrefetchHooks Function({bool projectId})
        > {
  $$ActivitiesTableTableTableManager(
    _$AppDatabase db,
    $ActivitiesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> activityType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> activityDate = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> labourCount = const Value.absent(),
                Value<double?> durationHours = const Value.absent(),
                Value<int> costMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                activityType: activityType,
                title: title,
                activityDate: activityDate,
                description: description,
                labourCount: labourCount,
                durationHours: durationHours,
                costMinor: costMinor,
                currency: currency,
                status: status,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String projectId,
                required String activityType,
                required String title,
                required int activityDate,
                Value<String?> description = const Value.absent(),
                Value<int> labourCount = const Value.absent(),
                Value<double?> durationHours = const Value.absent(),
                Value<int> costMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                activityType: activityType,
                title: title,
                activityDate: activityDate,
                description: description,
                labourCount: labourCount,
                durationHours: durationHours,
                costMinor: costMinor,
                currency: currency,
                status: status,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActivitiesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable:
                                    $$ActivitiesTableTableReferences
                                        ._projectIdTable(db),
                                referencedColumn:
                                    $$ActivitiesTableTableReferences
                                        ._projectIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ActivitiesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTableTable,
      Activity,
      $$ActivitiesTableTableFilterComposer,
      $$ActivitiesTableTableOrderingComposer,
      $$ActivitiesTableTableAnnotationComposer,
      $$ActivitiesTableTableCreateCompanionBuilder,
      $$ActivitiesTableTableUpdateCompanionBuilder,
      (Activity, $$ActivitiesTableTableReferences),
      Activity,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$HarvestsTableTableCreateCompanionBuilder =
    HarvestsTableCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      required String projectId,
      required String batchNumber,
      required int harvestDate,
      required String productName,
      required double quantity,
      required String unit,
      Value<String?> grade,
      Value<String?> storageLocation,
      Value<String?> notes,
      Value<String?> photoPath,
      Value<int> rowid,
    });
typedef $$HarvestsTableTableUpdateCompanionBuilder =
    HarvestsTableCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<String> projectId,
      Value<String> batchNumber,
      Value<int> harvestDate,
      Value<String> productName,
      Value<double> quantity,
      Value<String> unit,
      Value<String?> grade,
      Value<String?> storageLocation,
      Value<String?> notes,
      Value<String?> photoPath,
      Value<int> rowid,
    });

final class $$HarvestsTableTableReferences
    extends BaseReferences<_$AppDatabase, $HarvestsTableTable, Harvest> {
  $$HarvestsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectsTableTable _projectIdTable(_$AppDatabase db) =>
      db.projectsTable.createAlias(
        $_aliasNameGenerator(db.harvestsTable.projectId, db.projectsTable.id),
      );

  $$ProjectsTableTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableTableManager(
      $_db,
      $_db.projectsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SalesTableTable, List<Sale>> _salesTableRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.salesTable,
    aliasName: $_aliasNameGenerator(
      db.harvestsTable.id,
      db.salesTable.harvestId,
    ),
  );

  $$SalesTableTableProcessedTableManager get salesTableRefs {
    final manager = $$SalesTableTableTableManager(
      $_db,
      $_db.salesTable,
    ).filter((f) => f.harvestId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_salesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HarvestsTableTableFilterComposer
    extends Composer<_$AppDatabase, $HarvestsTableTable> {
  $$HarvestsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get harvestDate => $composableBuilder(
    column: $table.harvestDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageLocation => $composableBuilder(
    column: $table.storageLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableTableFilterComposer get projectId {
    final $$ProjectsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableFilterComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> salesTableRefs(
    Expression<bool> Function($$SalesTableTableFilterComposer f) f,
  ) {
    final $$SalesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.harvestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableFilterComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HarvestsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HarvestsTableTable> {
  $$HarvestsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get harvestDate => $composableBuilder(
    column: $table.harvestDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageLocation => $composableBuilder(
    column: $table.storageLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableTableOrderingComposer get projectId {
    final $$ProjectsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableOrderingComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HarvestsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HarvestsTableTable> {
  $$HarvestsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get harvestDate => $composableBuilder(
    column: $table.harvestDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get storageLocation => $composableBuilder(
    column: $table.storageLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  $$ProjectsTableTableAnnotationComposer get projectId {
    final $$ProjectsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> salesTableRefs<T extends Object>(
    Expression<T> Function($$SalesTableTableAnnotationComposer a) f,
  ) {
    final $$SalesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.harvestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HarvestsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HarvestsTableTable,
          Harvest,
          $$HarvestsTableTableFilterComposer,
          $$HarvestsTableTableOrderingComposer,
          $$HarvestsTableTableAnnotationComposer,
          $$HarvestsTableTableCreateCompanionBuilder,
          $$HarvestsTableTableUpdateCompanionBuilder,
          (Harvest, $$HarvestsTableTableReferences),
          Harvest,
          PrefetchHooks Function({bool projectId, bool salesTableRefs})
        > {
  $$HarvestsTableTableTableManager(_$AppDatabase db, $HarvestsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HarvestsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HarvestsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HarvestsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> batchNumber = const Value.absent(),
                Value<int> harvestDate = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> grade = const Value.absent(),
                Value<String?> storageLocation = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HarvestsTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                batchNumber: batchNumber,
                harvestDate: harvestDate,
                productName: productName,
                quantity: quantity,
                unit: unit,
                grade: grade,
                storageLocation: storageLocation,
                notes: notes,
                photoPath: photoPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String projectId,
                required String batchNumber,
                required int harvestDate,
                required String productName,
                required double quantity,
                required String unit,
                Value<String?> grade = const Value.absent(),
                Value<String?> storageLocation = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HarvestsTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                batchNumber: batchNumber,
                harvestDate: harvestDate,
                productName: productName,
                quantity: quantity,
                unit: unit,
                grade: grade,
                storageLocation: storageLocation,
                notes: notes,
                photoPath: photoPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HarvestsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false, salesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (salesTableRefs) db.salesTable],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$HarvestsTableTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$HarvestsTableTableReferences
                                    ._projectIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (salesTableRefs)
                    await $_getPrefetchedData<
                      Harvest,
                      $HarvestsTableTable,
                      Sale
                    >(
                      currentTable: table,
                      referencedTable: $$HarvestsTableTableReferences
                          ._salesTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HarvestsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).salesTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.harvestId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HarvestsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HarvestsTableTable,
      Harvest,
      $$HarvestsTableTableFilterComposer,
      $$HarvestsTableTableOrderingComposer,
      $$HarvestsTableTableAnnotationComposer,
      $$HarvestsTableTableCreateCompanionBuilder,
      $$HarvestsTableTableUpdateCompanionBuilder,
      (Harvest, $$HarvestsTableTableReferences),
      Harvest,
      PrefetchHooks Function({bool projectId, bool salesTableRefs})
    >;
typedef $$BuyersTableTableCreateCompanionBuilder =
    BuyersTableCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      required String name,
      Value<String?> phone,
      Value<String?> businessName,
      Value<String?> location,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$BuyersTableTableUpdateCompanionBuilder =
    BuyersTableCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<String> name,
      Value<String?> phone,
      Value<String?> businessName,
      Value<String?> location,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$BuyersTableTableReferences
    extends BaseReferences<_$AppDatabase, $BuyersTableTable, Buyer> {
  $$BuyersTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SalesTableTable, List<Sale>> _salesTableRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.salesTable,
    aliasName: $_aliasNameGenerator(db.buyersTable.id, db.salesTable.buyerId),
  );

  $$SalesTableTableProcessedTableManager get salesTableRefs {
    final manager = $$SalesTableTableTableManager(
      $_db,
      $_db.salesTable,
    ).filter((f) => f.buyerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_salesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BuyersTableTableFilterComposer
    extends Composer<_$AppDatabase, $BuyersTableTable> {
  $$BuyersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> salesTableRefs(
    Expression<bool> Function($$SalesTableTableFilterComposer f) f,
  ) {
    final $$SalesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.buyerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableFilterComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BuyersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BuyersTableTable> {
  $$BuyersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BuyersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BuyersTableTable> {
  $$BuyersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> salesTableRefs<T extends Object>(
    Expression<T> Function($$SalesTableTableAnnotationComposer a) f,
  ) {
    final $$SalesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.buyerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BuyersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BuyersTableTable,
          Buyer,
          $$BuyersTableTableFilterComposer,
          $$BuyersTableTableOrderingComposer,
          $$BuyersTableTableAnnotationComposer,
          $$BuyersTableTableCreateCompanionBuilder,
          $$BuyersTableTableUpdateCompanionBuilder,
          (Buyer, $$BuyersTableTableReferences),
          Buyer,
          PrefetchHooks Function({bool salesTableRefs})
        > {
  $$BuyersTableTableTableManager(_$AppDatabase db, $BuyersTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuyersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BuyersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BuyersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> businessName = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BuyersTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                name: name,
                phone: phone,
                businessName: businessName,
                location: location,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> businessName = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BuyersTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                name: name,
                phone: phone,
                businessName: businessName,
                location: location,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BuyersTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({salesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (salesTableRefs) db.salesTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (salesTableRefs)
                    await $_getPrefetchedData<Buyer, $BuyersTableTable, Sale>(
                      currentTable: table,
                      referencedTable: $$BuyersTableTableReferences
                          ._salesTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BuyersTableTableReferences(
                            db,
                            table,
                            p0,
                          ).salesTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.buyerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BuyersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BuyersTableTable,
      Buyer,
      $$BuyersTableTableFilterComposer,
      $$BuyersTableTableOrderingComposer,
      $$BuyersTableTableAnnotationComposer,
      $$BuyersTableTableCreateCompanionBuilder,
      $$BuyersTableTableUpdateCompanionBuilder,
      (Buyer, $$BuyersTableTableReferences),
      Buyer,
      PrefetchHooks Function({bool salesTableRefs})
    >;
typedef $$SalesTableTableCreateCompanionBuilder =
    SalesTableCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      required String projectId,
      Value<String?> buyerId,
      Value<String?> harvestId,
      required int saleDate,
      required String productName,
      required double quantity,
      required String unit,
      required int unitPriceMinor,
      required int totalAmountMinor,
      Value<String> currency,
      Value<String> paymentStatus,
      Value<String?> notes,
      Value<bool> isVoided,
      Value<int?> voidedAt,
      Value<String?> voidReason,
      Value<int> rowid,
    });
typedef $$SalesTableTableUpdateCompanionBuilder =
    SalesTableCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<String> projectId,
      Value<String?> buyerId,
      Value<String?> harvestId,
      Value<int> saleDate,
      Value<String> productName,
      Value<double> quantity,
      Value<String> unit,
      Value<int> unitPriceMinor,
      Value<int> totalAmountMinor,
      Value<String> currency,
      Value<String> paymentStatus,
      Value<String?> notes,
      Value<bool> isVoided,
      Value<int?> voidedAt,
      Value<String?> voidReason,
      Value<int> rowid,
    });

final class $$SalesTableTableReferences
    extends BaseReferences<_$AppDatabase, $SalesTableTable, Sale> {
  $$SalesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTableTable _projectIdTable(_$AppDatabase db) =>
      db.projectsTable.createAlias(
        $_aliasNameGenerator(db.salesTable.projectId, db.projectsTable.id),
      );

  $$ProjectsTableTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableTableManager(
      $_db,
      $_db.projectsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BuyersTableTable _buyerIdTable(_$AppDatabase db) =>
      db.buyersTable.createAlias(
        $_aliasNameGenerator(db.salesTable.buyerId, db.buyersTable.id),
      );

  $$BuyersTableTableProcessedTableManager? get buyerId {
    final $_column = $_itemColumn<String>('buyer_id');
    if ($_column == null) return null;
    final manager = $$BuyersTableTableTableManager(
      $_db,
      $_db.buyersTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_buyerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $HarvestsTableTable _harvestIdTable(_$AppDatabase db) =>
      db.harvestsTable.createAlias(
        $_aliasNameGenerator(db.salesTable.harvestId, db.harvestsTable.id),
      );

  $$HarvestsTableTableProcessedTableManager? get harvestId {
    final $_column = $_itemColumn<String>('harvest_id');
    if ($_column == null) return null;
    final manager = $$HarvestsTableTableTableManager(
      $_db,
      $_db.harvestsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_harvestIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentsTableTable, List<Payment>>
  _paymentsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.paymentsTable,
    aliasName: $_aliasNameGenerator(db.salesTable.id, db.paymentsTable.saleId),
  );

  $$PaymentsTableTableProcessedTableManager get paymentsTableRefs {
    final manager = $$PaymentsTableTableTableManager(
      $_db,
      $_db.paymentsTable,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SalesTableTable> {
  $$SalesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get saleDate => $composableBuilder(
    column: $table.saleDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalAmountMinor => $composableBuilder(
    column: $table.totalAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVoided => $composableBuilder(
    column: $table.isVoided,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableTableFilterComposer get projectId {
    final $$ProjectsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableFilterComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BuyersTableTableFilterComposer get buyerId {
    final $$BuyersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buyerId,
      referencedTable: $db.buyersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuyersTableTableFilterComposer(
            $db: $db,
            $table: $db.buyersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HarvestsTableTableFilterComposer get harvestId {
    final $$HarvestsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.harvestId,
      referencedTable: $db.harvestsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HarvestsTableTableFilterComposer(
            $db: $db,
            $table: $db.harvestsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentsTableRefs(
    Expression<bool> Function($$PaymentsTableTableFilterComposer f) f,
  ) {
    final $$PaymentsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentsTable,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableTableFilterComposer(
            $db: $db,
            $table: $db.paymentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTableTable> {
  $$SalesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get saleDate => $composableBuilder(
    column: $table.saleDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAmountMinor => $composableBuilder(
    column: $table.totalAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVoided => $composableBuilder(
    column: $table.isVoided,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableTableOrderingComposer get projectId {
    final $$ProjectsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableOrderingComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BuyersTableTableOrderingComposer get buyerId {
    final $$BuyersTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buyerId,
      referencedTable: $db.buyersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuyersTableTableOrderingComposer(
            $db: $db,
            $table: $db.buyersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HarvestsTableTableOrderingComposer get harvestId {
    final $$HarvestsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.harvestId,
      referencedTable: $db.harvestsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HarvestsTableTableOrderingComposer(
            $db: $db,
            $table: $db.harvestsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTableTable> {
  $$SalesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get saleDate =>
      $composableBuilder(column: $table.saleDate, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalAmountMinor => $composableBuilder(
    column: $table.totalAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isVoided =>
      $composableBuilder(column: $table.isVoided, builder: (column) => column);

  GeneratedColumn<int> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  $$ProjectsTableTableAnnotationComposer get projectId {
    final $$ProjectsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BuyersTableTableAnnotationComposer get buyerId {
    final $$BuyersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buyerId,
      referencedTable: $db.buyersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuyersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.buyersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HarvestsTableTableAnnotationComposer get harvestId {
    final $$HarvestsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.harvestId,
      referencedTable: $db.harvestsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HarvestsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.harvestsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentsTableRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentsTable,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTableTable,
          Sale,
          $$SalesTableTableFilterComposer,
          $$SalesTableTableOrderingComposer,
          $$SalesTableTableAnnotationComposer,
          $$SalesTableTableCreateCompanionBuilder,
          $$SalesTableTableUpdateCompanionBuilder,
          (Sale, $$SalesTableTableReferences),
          Sale,
          PrefetchHooks Function({
            bool projectId,
            bool buyerId,
            bool harvestId,
            bool paymentsTableRefs,
          })
        > {
  $$SalesTableTableTableManager(_$AppDatabase db, $SalesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String?> buyerId = const Value.absent(),
                Value<String?> harvestId = const Value.absent(),
                Value<int> saleDate = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int> unitPriceMinor = const Value.absent(),
                Value<int> totalAmountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isVoided = const Value.absent(),
                Value<int?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                buyerId: buyerId,
                harvestId: harvestId,
                saleDate: saleDate,
                productName: productName,
                quantity: quantity,
                unit: unit,
                unitPriceMinor: unitPriceMinor,
                totalAmountMinor: totalAmountMinor,
                currency: currency,
                paymentStatus: paymentStatus,
                notes: notes,
                isVoided: isVoided,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String projectId,
                Value<String?> buyerId = const Value.absent(),
                Value<String?> harvestId = const Value.absent(),
                required int saleDate,
                required String productName,
                required double quantity,
                required String unit,
                required int unitPriceMinor,
                required int totalAmountMinor,
                Value<String> currency = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isVoided = const Value.absent(),
                Value<int?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                buyerId: buyerId,
                harvestId: harvestId,
                saleDate: saleDate,
                productName: productName,
                quantity: quantity,
                unit: unit,
                unitPriceMinor: unitPriceMinor,
                totalAmountMinor: totalAmountMinor,
                currency: currency,
                paymentStatus: paymentStatus,
                notes: notes,
                isVoided: isVoided,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SalesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectId = false,
                buyerId = false,
                harvestId = false,
                paymentsTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentsTableRefs) db.paymentsTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable: $$SalesTableTableReferences
                                        ._projectIdTable(db),
                                    referencedColumn:
                                        $$SalesTableTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (buyerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.buyerId,
                                    referencedTable: $$SalesTableTableReferences
                                        ._buyerIdTable(db),
                                    referencedColumn:
                                        $$SalesTableTableReferences
                                            ._buyerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (harvestId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.harvestId,
                                    referencedTable: $$SalesTableTableReferences
                                        ._harvestIdTable(db),
                                    referencedColumn:
                                        $$SalesTableTableReferences
                                            ._harvestIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentsTableRefs)
                        await $_getPrefetchedData<
                          Sale,
                          $SalesTableTable,
                          Payment
                        >(
                          currentTable: table,
                          referencedTable: $$SalesTableTableReferences
                              ._paymentsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SalesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.saleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SalesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTableTable,
      Sale,
      $$SalesTableTableFilterComposer,
      $$SalesTableTableOrderingComposer,
      $$SalesTableTableAnnotationComposer,
      $$SalesTableTableCreateCompanionBuilder,
      $$SalesTableTableUpdateCompanionBuilder,
      (Sale, $$SalesTableTableReferences),
      Sale,
      PrefetchHooks Function({
        bool projectId,
        bool buyerId,
        bool harvestId,
        bool paymentsTableRefs,
      })
    >;
typedef $$PaymentsTableTableCreateCompanionBuilder =
    PaymentsTableCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      required String saleId,
      required int paymentDate,
      required int amountMinor,
      Value<String> currency,
      required String paymentMethod,
      Value<String?> referenceNumber,
      Value<String?> notes,
      Value<bool> isVoided,
      Value<int?> voidedAt,
      Value<String?> voidReason,
      Value<int> rowid,
    });
typedef $$PaymentsTableTableUpdateCompanionBuilder =
    PaymentsTableCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<String> saleId,
      Value<int> paymentDate,
      Value<int> amountMinor,
      Value<String> currency,
      Value<String> paymentMethod,
      Value<String?> referenceNumber,
      Value<String?> notes,
      Value<bool> isVoided,
      Value<int?> voidedAt,
      Value<String?> voidReason,
      Value<int> rowid,
    });

final class $$PaymentsTableTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTableTable, Payment> {
  $$PaymentsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SalesTableTable _saleIdTable(_$AppDatabase db) =>
      db.salesTable.createAlias(
        $_aliasNameGenerator(db.paymentsTable.saleId, db.salesTable.id),
      );

  $$SalesTableTableProcessedTableManager get saleId {
    final $_column = $_itemColumn<String>('sale_id')!;

    final manager = $$SalesTableTableTableManager(
      $_db,
      $_db.salesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVoided => $composableBuilder(
    column: $table.isVoided,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  $$SalesTableTableFilterComposer get saleId {
    final $$SalesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableFilterComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVoided => $composableBuilder(
    column: $table.isVoided,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesTableTableOrderingComposer get saleId {
    final $$SalesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableOrderingComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isVoided =>
      $composableBuilder(column: $table.isVoided, builder: (column) => column);

  GeneratedColumn<int> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  $$SalesTableTableAnnotationComposer get saleId {
    final $$SalesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTableTable,
          Payment,
          $$PaymentsTableTableFilterComposer,
          $$PaymentsTableTableOrderingComposer,
          $$PaymentsTableTableAnnotationComposer,
          $$PaymentsTableTableCreateCompanionBuilder,
          $$PaymentsTableTableUpdateCompanionBuilder,
          (Payment, $$PaymentsTableTableReferences),
          Payment,
          PrefetchHooks Function({bool saleId})
        > {
  $$PaymentsTableTableTableManager(_$AppDatabase db, $PaymentsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<int> paymentDate = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isVoided = const Value.absent(),
                Value<int?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                saleId: saleId,
                paymentDate: paymentDate,
                amountMinor: amountMinor,
                currency: currency,
                paymentMethod: paymentMethod,
                referenceNumber: referenceNumber,
                notes: notes,
                isVoided: isVoided,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String saleId,
                required int paymentDate,
                required int amountMinor,
                Value<String> currency = const Value.absent(),
                required String paymentMethod,
                Value<String?> referenceNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isVoided = const Value.absent(),
                Value<int?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                saleId: saleId,
                paymentDate: paymentDate,
                amountMinor: amountMinor,
                currency: currency,
                paymentMethod: paymentMethod,
                referenceNumber: referenceNumber,
                notes: notes,
                isVoided: isVoided,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (saleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.saleId,
                                referencedTable: $$PaymentsTableTableReferences
                                    ._saleIdTable(db),
                                referencedColumn: $$PaymentsTableTableReferences
                                    ._saleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTableTable,
      Payment,
      $$PaymentsTableTableFilterComposer,
      $$PaymentsTableTableOrderingComposer,
      $$PaymentsTableTableAnnotationComposer,
      $$PaymentsTableTableCreateCompanionBuilder,
      $$PaymentsTableTableUpdateCompanionBuilder,
      (Payment, $$PaymentsTableTableReferences),
      Payment,
      PrefetchHooks Function({bool saleId})
    >;
typedef $$CashTransactionsTableTableCreateCompanionBuilder =
    CashTransactionsTableCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<String?> projectId,
      required String transactionType,
      required String category,
      required int transactionDate,
      required int amountMinor,
      Value<String> currency,
      Value<String?> referenceId,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$CashTransactionsTableTableUpdateCompanionBuilder =
    CashTransactionsTableCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<String?> projectId,
      Value<String> transactionType,
      Value<String> category,
      Value<int> transactionDate,
      Value<int> amountMinor,
      Value<String> currency,
      Value<String?> referenceId,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$CashTransactionsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CashTransactionsTableTable,
          CashTransaction
        > {
  $$CashTransactionsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectsTableTable _projectIdTable(_$AppDatabase db) =>
      db.projectsTable.createAlias(
        $_aliasNameGenerator(
          db.cashTransactionsTable.projectId,
          db.projectsTable.id,
        ),
      );

  $$ProjectsTableTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableTableManager(
      $_db,
      $_db.projectsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CashTransactionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CashTransactionsTableTable> {
  $$CashTransactionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableTableFilterComposer get projectId {
    final $$ProjectsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableFilterComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashTransactionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CashTransactionsTableTable> {
  $$CashTransactionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableTableOrderingComposer get projectId {
    final $$ProjectsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableOrderingComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashTransactionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashTransactionsTableTable> {
  $$CashTransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$ProjectsTableTableAnnotationComposer get projectId {
    final $$ProjectsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashTransactionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashTransactionsTableTable,
          CashTransaction,
          $$CashTransactionsTableTableFilterComposer,
          $$CashTransactionsTableTableOrderingComposer,
          $$CashTransactionsTableTableAnnotationComposer,
          $$CashTransactionsTableTableCreateCompanionBuilder,
          $$CashTransactionsTableTableUpdateCompanionBuilder,
          (CashTransaction, $$CashTransactionsTableTableReferences),
          CashTransaction,
          PrefetchHooks Function({bool projectId})
        > {
  $$CashTransactionsTableTableTableManager(
    _$AppDatabase db,
    $CashTransactionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashTransactionsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CashTransactionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CashTransactionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> transactionDate = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashTransactionsTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                transactionType: transactionType,
                category: category,
                transactionDate: transactionDate,
                amountMinor: amountMinor,
                currency: currency,
                referenceId: referenceId,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                required String transactionType,
                required String category,
                required int transactionDate,
                required int amountMinor,
                Value<String> currency = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashTransactionsTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                transactionType: transactionType,
                category: category,
                transactionDate: transactionDate,
                amountMinor: amountMinor,
                currency: currency,
                referenceId: referenceId,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CashTransactionsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable:
                                    $$CashTransactionsTableTableReferences
                                        ._projectIdTable(db),
                                referencedColumn:
                                    $$CashTransactionsTableTableReferences
                                        ._projectIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CashTransactionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashTransactionsTableTable,
      CashTransaction,
      $$CashTransactionsTableTableFilterComposer,
      $$CashTransactionsTableTableOrderingComposer,
      $$CashTransactionsTableTableAnnotationComposer,
      $$CashTransactionsTableTableCreateCompanionBuilder,
      $$CashTransactionsTableTableUpdateCompanionBuilder,
      (CashTransaction, $$CashTransactionsTableTableReferences),
      CashTransaction,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$ScenariosTableTableCreateCompanionBuilder =
    ScenariosTableCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      required String projectId,
      required String scenarioType,
      required double expectedYield,
      required String yieldUnit,
      required int expectedUnitPriceMinor,
      required int projectedRevenueMinor,
      required int projectedCostMinor,
      required int projectedProfitMinor,
      required double projectedRoiPercent,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$ScenariosTableTableUpdateCompanionBuilder =
    ScenariosTableCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<String> projectId,
      Value<String> scenarioType,
      Value<double> expectedYield,
      Value<String> yieldUnit,
      Value<int> expectedUnitPriceMinor,
      Value<int> projectedRevenueMinor,
      Value<int> projectedCostMinor,
      Value<int> projectedProfitMinor,
      Value<double> projectedRoiPercent,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$ScenariosTableTableReferences
    extends BaseReferences<_$AppDatabase, $ScenariosTableTable, Scenario> {
  $$ScenariosTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectsTableTable _projectIdTable(_$AppDatabase db) =>
      db.projectsTable.createAlias(
        $_aliasNameGenerator(db.scenariosTable.projectId, db.projectsTable.id),
      );

  $$ProjectsTableTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableTableManager(
      $_db,
      $_db.projectsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScenariosTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScenariosTableTable> {
  $$ScenariosTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scenarioType => $composableBuilder(
    column: $table.scenarioType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get expectedYield => $composableBuilder(
    column: $table.expectedYield,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get yieldUnit => $composableBuilder(
    column: $table.yieldUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedUnitPriceMinor => $composableBuilder(
    column: $table.expectedUnitPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectedRevenueMinor => $composableBuilder(
    column: $table.projectedRevenueMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectedCostMinor => $composableBuilder(
    column: $table.projectedCostMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectedProfitMinor => $composableBuilder(
    column: $table.projectedProfitMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get projectedRoiPercent => $composableBuilder(
    column: $table.projectedRoiPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableTableFilterComposer get projectId {
    final $$ProjectsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableFilterComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScenariosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScenariosTableTable> {
  $$ScenariosTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scenarioType => $composableBuilder(
    column: $table.scenarioType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get expectedYield => $composableBuilder(
    column: $table.expectedYield,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get yieldUnit => $composableBuilder(
    column: $table.yieldUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedUnitPriceMinor => $composableBuilder(
    column: $table.expectedUnitPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectedRevenueMinor => $composableBuilder(
    column: $table.projectedRevenueMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectedCostMinor => $composableBuilder(
    column: $table.projectedCostMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectedProfitMinor => $composableBuilder(
    column: $table.projectedProfitMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get projectedRoiPercent => $composableBuilder(
    column: $table.projectedRoiPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableTableOrderingComposer get projectId {
    final $$ProjectsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableOrderingComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScenariosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScenariosTableTable> {
  $$ScenariosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get scenarioType => $composableBuilder(
    column: $table.scenarioType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get expectedYield => $composableBuilder(
    column: $table.expectedYield,
    builder: (column) => column,
  );

  GeneratedColumn<String> get yieldUnit =>
      $composableBuilder(column: $table.yieldUnit, builder: (column) => column);

  GeneratedColumn<int> get expectedUnitPriceMinor => $composableBuilder(
    column: $table.expectedUnitPriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get projectedRevenueMinor => $composableBuilder(
    column: $table.projectedRevenueMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get projectedCostMinor => $composableBuilder(
    column: $table.projectedCostMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get projectedProfitMinor => $composableBuilder(
    column: $table.projectedProfitMinor,
    builder: (column) => column,
  );

  GeneratedColumn<double> get projectedRoiPercent => $composableBuilder(
    column: $table.projectedRoiPercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$ProjectsTableTableAnnotationComposer get projectId {
    final $$ProjectsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScenariosTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScenariosTableTable,
          Scenario,
          $$ScenariosTableTableFilterComposer,
          $$ScenariosTableTableOrderingComposer,
          $$ScenariosTableTableAnnotationComposer,
          $$ScenariosTableTableCreateCompanionBuilder,
          $$ScenariosTableTableUpdateCompanionBuilder,
          (Scenario, $$ScenariosTableTableReferences),
          Scenario,
          PrefetchHooks Function({bool projectId})
        > {
  $$ScenariosTableTableTableManager(
    _$AppDatabase db,
    $ScenariosTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScenariosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScenariosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScenariosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> scenarioType = const Value.absent(),
                Value<double> expectedYield = const Value.absent(),
                Value<String> yieldUnit = const Value.absent(),
                Value<int> expectedUnitPriceMinor = const Value.absent(),
                Value<int> projectedRevenueMinor = const Value.absent(),
                Value<int> projectedCostMinor = const Value.absent(),
                Value<int> projectedProfitMinor = const Value.absent(),
                Value<double> projectedRoiPercent = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScenariosTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                scenarioType: scenarioType,
                expectedYield: expectedYield,
                yieldUnit: yieldUnit,
                expectedUnitPriceMinor: expectedUnitPriceMinor,
                projectedRevenueMinor: projectedRevenueMinor,
                projectedCostMinor: projectedCostMinor,
                projectedProfitMinor: projectedProfitMinor,
                projectedRoiPercent: projectedRoiPercent,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String projectId,
                required String scenarioType,
                required double expectedYield,
                required String yieldUnit,
                required int expectedUnitPriceMinor,
                required int projectedRevenueMinor,
                required int projectedCostMinor,
                required int projectedProfitMinor,
                required double projectedRoiPercent,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScenariosTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                scenarioType: scenarioType,
                expectedYield: expectedYield,
                yieldUnit: yieldUnit,
                expectedUnitPriceMinor: expectedUnitPriceMinor,
                projectedRevenueMinor: projectedRevenueMinor,
                projectedCostMinor: projectedCostMinor,
                projectedProfitMinor: projectedProfitMinor,
                projectedRoiPercent: projectedRoiPercent,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScenariosTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$ScenariosTableTableReferences
                                    ._projectIdTable(db),
                                referencedColumn:
                                    $$ScenariosTableTableReferences
                                        ._projectIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScenariosTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScenariosTableTable,
      Scenario,
      $$ScenariosTableTableFilterComposer,
      $$ScenariosTableTableOrderingComposer,
      $$ScenariosTableTableAnnotationComposer,
      $$ScenariosTableTableCreateCompanionBuilder,
      $$ScenariosTableTableUpdateCompanionBuilder,
      (Scenario, $$ScenariosTableTableReferences),
      Scenario,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$RisksTableTableCreateCompanionBuilder =
    RisksTableCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      required String projectId,
      required String riskTitle,
      required String category,
      required int probability,
      required int impact,
      required int riskScore,
      Value<String?> mitigationStrategy,
      Value<String> status,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$RisksTableTableUpdateCompanionBuilder =
    RisksTableCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<String> projectId,
      Value<String> riskTitle,
      Value<String> category,
      Value<int> probability,
      Value<int> impact,
      Value<int> riskScore,
      Value<String?> mitigationStrategy,
      Value<String> status,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$RisksTableTableReferences
    extends BaseReferences<_$AppDatabase, $RisksTableTable, Risk> {
  $$RisksTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTableTable _projectIdTable(_$AppDatabase db) =>
      db.projectsTable.createAlias(
        $_aliasNameGenerator(db.risksTable.projectId, db.projectsTable.id),
      );

  $$ProjectsTableTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableTableManager(
      $_db,
      $_db.projectsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RisksTableTableFilterComposer
    extends Composer<_$AppDatabase, $RisksTableTable> {
  $$RisksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get riskTitle => $composableBuilder(
    column: $table.riskTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get probability => $composableBuilder(
    column: $table.probability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get impact => $composableBuilder(
    column: $table.impact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get riskScore => $composableBuilder(
    column: $table.riskScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mitigationStrategy => $composableBuilder(
    column: $table.mitigationStrategy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableTableFilterComposer get projectId {
    final $$ProjectsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableFilterComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RisksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RisksTableTable> {
  $$RisksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riskTitle => $composableBuilder(
    column: $table.riskTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get probability => $composableBuilder(
    column: $table.probability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get impact => $composableBuilder(
    column: $table.impact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get riskScore => $composableBuilder(
    column: $table.riskScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mitigationStrategy => $composableBuilder(
    column: $table.mitigationStrategy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableTableOrderingComposer get projectId {
    final $$ProjectsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableOrderingComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RisksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RisksTableTable> {
  $$RisksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get riskTitle =>
      $composableBuilder(column: $table.riskTitle, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get probability => $composableBuilder(
    column: $table.probability,
    builder: (column) => column,
  );

  GeneratedColumn<int> get impact =>
      $composableBuilder(column: $table.impact, builder: (column) => column);

  GeneratedColumn<int> get riskScore =>
      $composableBuilder(column: $table.riskScore, builder: (column) => column);

  GeneratedColumn<String> get mitigationStrategy => $composableBuilder(
    column: $table.mitigationStrategy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$ProjectsTableTableAnnotationComposer get projectId {
    final $$ProjectsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.projectsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RisksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RisksTableTable,
          Risk,
          $$RisksTableTableFilterComposer,
          $$RisksTableTableOrderingComposer,
          $$RisksTableTableAnnotationComposer,
          $$RisksTableTableCreateCompanionBuilder,
          $$RisksTableTableUpdateCompanionBuilder,
          (Risk, $$RisksTableTableReferences),
          Risk,
          PrefetchHooks Function({bool projectId})
        > {
  $$RisksTableTableTableManager(_$AppDatabase db, $RisksTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RisksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RisksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RisksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> riskTitle = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> probability = const Value.absent(),
                Value<int> impact = const Value.absent(),
                Value<int> riskScore = const Value.absent(),
                Value<String?> mitigationStrategy = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RisksTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                riskTitle: riskTitle,
                category: category,
                probability: probability,
                impact: impact,
                riskScore: riskScore,
                mitigationStrategy: mitigationStrategy,
                status: status,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String projectId,
                required String riskTitle,
                required String category,
                required int probability,
                required int impact,
                required int riskScore,
                Value<String?> mitigationStrategy = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RisksTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                isDeleted: isDeleted,
                projectId: projectId,
                riskTitle: riskTitle,
                category: category,
                probability: probability,
                impact: impact,
                riskScore: riskScore,
                mitigationStrategy: mitigationStrategy,
                status: status,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RisksTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$RisksTableTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$RisksTableTableReferences
                                    ._projectIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RisksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RisksTableTable,
      Risk,
      $$RisksTableTableFilterComposer,
      $$RisksTableTableOrderingComposer,
      $$RisksTableTableAnnotationComposer,
      $$RisksTableTableCreateCompanionBuilder,
      $$RisksTableTableUpdateCompanionBuilder,
      (Risk, $$RisksTableTableReferences),
      Risk,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$AuditLogsTableTableCreateCompanionBuilder =
    AuditLogsTableCompanion Function({
      required String id,
      required String entityTable,
      required String entityId,
      required String action,
      Value<String?> previousStateJson,
      Value<String?> newStateJson,
      Value<String> performedBy,
      Value<String?> reason,
      required int timestamp,
      Value<int> rowid,
    });
typedef $$AuditLogsTableTableUpdateCompanionBuilder =
    AuditLogsTableCompanion Function({
      Value<String> id,
      Value<String> entityTable,
      Value<String> entityId,
      Value<String> action,
      Value<String?> previousStateJson,
      Value<String?> newStateJson,
      Value<String> performedBy,
      Value<String?> reason,
      Value<int> timestamp,
      Value<int> rowid,
    });

class $$AuditLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTableTable> {
  $$AuditLogsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousStateJson => $composableBuilder(
    column: $table.previousStateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newStateJson => $composableBuilder(
    column: $table.newStateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get performedBy => $composableBuilder(
    column: $table.performedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTableTable> {
  $$AuditLogsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousStateJson => $composableBuilder(
    column: $table.previousStateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newStateJson => $composableBuilder(
    column: $table.newStateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get performedBy => $composableBuilder(
    column: $table.performedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTableTable> {
  $$AuditLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get previousStateJson => $composableBuilder(
    column: $table.previousStateJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get newStateJson => $composableBuilder(
    column: $table.newStateJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get performedBy => $composableBuilder(
    column: $table.performedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$AuditLogsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTableTable,
          AuditLog,
          $$AuditLogsTableTableFilterComposer,
          $$AuditLogsTableTableOrderingComposer,
          $$AuditLogsTableTableAnnotationComposer,
          $$AuditLogsTableTableCreateCompanionBuilder,
          $$AuditLogsTableTableUpdateCompanionBuilder,
          (
            AuditLog,
            BaseReferences<_$AppDatabase, $AuditLogsTableTable, AuditLog>,
          ),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableTableManager(
    _$AppDatabase db,
    $AuditLogsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> previousStateJson = const Value.absent(),
                Value<String?> newStateJson = const Value.absent(),
                Value<String> performedBy = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsTableCompanion(
                id: id,
                entityTable: entityTable,
                entityId: entityId,
                action: action,
                previousStateJson: previousStateJson,
                newStateJson: newStateJson,
                performedBy: performedBy,
                reason: reason,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityTable,
                required String entityId,
                required String action,
                Value<String?> previousStateJson = const Value.absent(),
                Value<String?> newStateJson = const Value.absent(),
                Value<String> performedBy = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required int timestamp,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsTableCompanion.insert(
                id: id,
                entityTable: entityTable,
                entityId: entityId,
                action: action,
                previousStateJson: previousStateJson,
                newStateJson: newStateJson,
                performedBy: performedBy,
                reason: reason,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTableTable,
      AuditLog,
      $$AuditLogsTableTableFilterComposer,
      $$AuditLogsTableTableOrderingComposer,
      $$AuditLogsTableTableAnnotationComposer,
      $$AuditLogsTableTableCreateCompanionBuilder,
      $$AuditLogsTableTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTableTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableTableCreateCompanionBuilder =
    SyncQueueTableCompanion Function({
      required String id,
      required String entityTable,
      required String entityId,
      required String operation,
      required String payloadJson,
      Value<int> retryCount,
      Value<String?> lastError,
      required int queuedAt,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$SyncQueueTableTableUpdateCompanionBuilder =
    SyncQueueTableCompanion Function({
      Value<String> id,
      Value<String> entityTable,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payloadJson,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<int> queuedAt,
      Value<String> status,
      Value<int> rowid,
    });

class $$SyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get queuedAt =>
      $composableBuilder(column: $table.queuedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SyncQueueTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTableTable,
          SyncQueueEntry,
          $$SyncQueueTableTableFilterComposer,
          $$SyncQueueTableTableOrderingComposer,
          $$SyncQueueTableTableAnnotationComposer,
          $$SyncQueueTableTableCreateCompanionBuilder,
          $$SyncQueueTableTableUpdateCompanionBuilder,
          (
            SyncQueueEntry,
            BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueEntry>,
          ),
          SyncQueueEntry,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableTableManager(
    _$AppDatabase db,
    $SyncQueueTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> queuedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueTableCompanion(
                id: id,
                entityTable: entityTable,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                retryCount: retryCount,
                lastError: lastError,
                queuedAt: queuedAt,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityTable,
                required String entityId,
                required String operation,
                required String payloadJson,
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required int queuedAt,
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueTableCompanion.insert(
                id: id,
                entityTable: entityTable,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                retryCount: retryCount,
                lastError: lastError,
                queuedAt: queuedAt,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTableTable,
      SyncQueueEntry,
      $$SyncQueueTableTableFilterComposer,
      $$SyncQueueTableTableOrderingComposer,
      $$SyncQueueTableTableAnnotationComposer,
      $$SyncQueueTableTableCreateCompanionBuilder,
      $$SyncQueueTableTableUpdateCompanionBuilder,
      (
        SyncQueueEntry,
        BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueEntry>,
      ),
      SyncQueueEntry,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      required String settingKey,
      required String settingValue,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<String> settingKey,
      Value<String> settingValue,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSetting,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTableTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$AppDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> settingKey = const Value.absent(),
                Value<String> settingValue = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion(
                settingKey: settingKey,
                settingValue: settingValue,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String settingKey,
                required String settingValue,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                settingKey: settingKey,
                settingValue: settingValue,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTableTable,
      AppSetting,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTableTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FarmsTableTableTableManager get farmsTable =>
      $$FarmsTableTableTableManager(_db, _db.farmsTable);
  $$ProjectsTableTableTableManager get projectsTable =>
      $$ProjectsTableTableTableManager(_db, _db.projectsTable);
  $$BudgetCategoriesTableTableTableManager get budgetCategoriesTable =>
      $$BudgetCategoriesTableTableTableManager(_db, _db.budgetCategoriesTable);
  $$BudgetItemsTableTableTableManager get budgetItemsTable =>
      $$BudgetItemsTableTableTableManager(_db, _db.budgetItemsTable);
  $$ExpensesTableTableTableManager get expensesTable =>
      $$ExpensesTableTableTableManager(_db, _db.expensesTable);
  $$ActivitiesTableTableTableManager get activitiesTable =>
      $$ActivitiesTableTableTableManager(_db, _db.activitiesTable);
  $$HarvestsTableTableTableManager get harvestsTable =>
      $$HarvestsTableTableTableManager(_db, _db.harvestsTable);
  $$BuyersTableTableTableManager get buyersTable =>
      $$BuyersTableTableTableManager(_db, _db.buyersTable);
  $$SalesTableTableTableManager get salesTable =>
      $$SalesTableTableTableManager(_db, _db.salesTable);
  $$PaymentsTableTableTableManager get paymentsTable =>
      $$PaymentsTableTableTableManager(_db, _db.paymentsTable);
  $$CashTransactionsTableTableTableManager get cashTransactionsTable =>
      $$CashTransactionsTableTableTableManager(_db, _db.cashTransactionsTable);
  $$ScenariosTableTableTableManager get scenariosTable =>
      $$ScenariosTableTableTableManager(_db, _db.scenariosTable);
  $$RisksTableTableTableManager get risksTable =>
      $$RisksTableTableTableManager(_db, _db.risksTable);
  $$AuditLogsTableTableTableManager get auditLogsTable =>
      $$AuditLogsTableTableTableManager(_db, _db.auditLogsTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(_db, _db.syncQueueTable);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
}
