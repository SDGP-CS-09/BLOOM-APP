import 'dart:async' as _i4;

import 'package:firebase_core/firebase_core.dart' as _i2;
import 'package:firebase_database/firebase_database.dart' as _i3;
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart'
    as _i6;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;

class _FakeFirebaseApp_0 extends _i1.SmartFake implements _i2.FirebaseApp {
  _FakeFirebaseApp_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeDatabaseReference_1 extends _i1.SmartFake
    implements _i3.DatabaseReference {
  _FakeDatabaseReference_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeTransactionResult_2 extends _i1.SmartFake
    implements _i3.TransactionResult {
  _FakeTransactionResult_2(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeOnDisconnect_3 extends _i1.SmartFake implements _i3.OnDisconnect {
  _FakeOnDisconnect_3(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeDataSnapshot_4 extends _i1.SmartFake implements _i3.DataSnapshot {
  _FakeDataSnapshot_4(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeDatabaseEvent_5 extends _i1.SmartFake implements _i3.DatabaseEvent {
  _FakeDatabaseEvent_5(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeQuery_6 extends _i1.SmartFake implements _i3.Query {
  _FakeQuery_6(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class MockFirebaseDatabase extends _i1.Mock implements _i3.FirebaseDatabase {
  MockFirebaseDatabase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.FirebaseApp get app => (super.noSuchMethod(
        Invocation.getter(#app),
        returnValue: _FakeFirebaseApp_0(this, Invocation.getter(#app)),
      ) as _i2.FirebaseApp);

  @override
  set app(_i2.FirebaseApp? _app) => super.noSuchMethod(
        Invocation.setter(#app, _app),
        returnValueForMissingStub: null,
      );

  @override
  set databaseURL(String? _databaseURL) => super.noSuchMethod(
        Invocation.setter(#databaseURL, _databaseURL),
        returnValueForMissingStub: null,
      );

  @override
  Map<dynamic, dynamic> get pluginConstants => (super.noSuchMethod(
        Invocation.getter(#pluginConstants),
        returnValue: <dynamic, dynamic>{},
      ) as Map<dynamic, dynamic>);

  @override
  void useDatabaseEmulator(
    String? host,
    int? port, {
    bool? automaticHostMapping = true,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #useDatabaseEmulator,
          [host, port],
          {#automaticHostMapping: automaticHostMapping},
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i3.DatabaseReference ref([String? path]) => (super.noSuchMethod(
        Invocation.method(#ref, [path]),
        returnValue: _FakeDatabaseReference_1(
          this,
          Invocation.method(#ref, [path]),
        ),
      ) as _i3.DatabaseReference);

  @override
  _i3.DatabaseReference refFromURL(String? url) => (super.noSuchMethod(
        Invocation.method(#refFromURL, [url]),
        returnValue: _FakeDatabaseReference_1(
          this,
          Invocation.method(#refFromURL, [url]),
        ),
      ) as _i3.DatabaseReference);

  @override
  void setPersistenceEnabled(bool? enabled) => super.noSuchMethod(
        Invocation.method(#setPersistenceEnabled, [enabled]),
        returnValueForMissingStub: null,
      );

  @override
  void setPersistenceCacheSizeBytes(int? cacheSize) => super.noSuchMethod(
        Invocation.method(#setPersistenceCacheSizeBytes, [cacheSize]),
        returnValueForMissingStub: null,
      );

  @override
  void setLoggingEnabled(bool? enabled) => super.noSuchMethod(
        Invocation.method(#setLoggingEnabled, [enabled]),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Future<void> goOnline() => (super.noSuchMethod(
        Invocation.method(#goOnline, []),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> goOffline() => (super.noSuchMethod(
        Invocation.method(#goOffline, []),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> purgeOutstandingWrites() => (super.noSuchMethod(
        Invocation.method(#purgeOutstandingWrites, []),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}

/// A class which mocks [DatabaseReference].
///
/// See the documentation for Mockito's code generation for more information.
class MockDatabaseReference extends _i1.Mock implements _i3.DatabaseReference {
  MockDatabaseReference() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.DatabaseReference get root => (super.noSuchMethod(
        Invocation.getter(#root),
        returnValue: _FakeDatabaseReference_1(
          this,
          Invocation.getter(#root),
        ),
      ) as _i3.DatabaseReference);

  @override
  _i3.DatabaseReference get ref => (super.noSuchMethod(
        Invocation.getter(#ref),
        returnValue: _FakeDatabaseReference_1(
          this,
          Invocation.getter(#ref),
        ),
      ) as _i3.DatabaseReference);

  @override
  String get path => (super.noSuchMethod(
        Invocation.getter(#path),
        returnValue: _i5.dummyValue<String>(this, Invocation.getter(#path)),
      ) as String);

  @override
  _i4.Stream<_i3.DatabaseEvent> get onChildAdded => (super.noSuchMethod(
        Invocation.getter(#onChildAdded),
        returnValue: _i4.Stream<_i3.DatabaseEvent>.empty(),
      ) as _i4.Stream<_i3.DatabaseEvent>);

  @override
  _i4.Stream<_i3.DatabaseEvent> get onChildRemoved => (super.noSuchMethod(
        Invocation.getter(#onChildRemoved),
        returnValue: _i4.Stream<_i3.DatabaseEvent>.empty(),
      ) as _i4.Stream<_i3.DatabaseEvent>);

  @override
  _i4.Stream<_i3.DatabaseEvent> get onChildChanged => (super.noSuchMethod(
        Invocation.getter(#onChildChanged),
        returnValue: _i4.Stream<_i3.DatabaseEvent>.empty(),
      ) as _i4.Stream<_i3.DatabaseEvent>);

  @override
  _i4.Stream<_i3.DatabaseEvent> get onChildMoved => (super.noSuchMethod(
        Invocation.getter(#onChildMoved),
        returnValue: _i4.Stream<_i3.DatabaseEvent>.empty(),
      ) as _i4.Stream<_i3.DatabaseEvent>);

  @override
  _i4.Stream<_i3.DatabaseEvent> get onValue => (super.noSuchMethod(
        Invocation.getter(#onValue),
        returnValue: _i4.Stream<_i3.DatabaseEvent>.empty(),
      ) as _i4.Stream<_i3.DatabaseEvent>);

  @override
  _i3.DatabaseReference child(String? path) => (super.noSuchMethod(
        Invocation.method(#child, [path]),
        returnValue: _FakeDatabaseReference_1(
          this,
          Invocation.method(#child, [path]),
        ),
      ) as _i3.DatabaseReference);

  @override
  _i3.DatabaseReference push() => (super.noSuchMethod(
        Invocation.method(#push, []),
        returnValue: _FakeDatabaseReference_1(
          this,
          Invocation.method(#push, []),
        ),
      ) as _i3.DatabaseReference);

  @override
  _i4.Future<void> set(Object? value) => (super.noSuchMethod(
        Invocation.method(#set, [value]),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setWithPriority(Object? value, Object? priority) =>
      (super.noSuchMethod(
        Invocation.method(#setWithPriority, [value, priority]),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> update(Map<String, Object?>? value) => (super.noSuchMethod(
        Invocation.method(#update, [value]),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setPriority(Object? priority) => (super.noSuchMethod(
        Invocation.method(#setPriority, [priority]),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> remove() => (super.noSuchMethod(
        Invocation.method(#remove, []),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<_i3.TransactionResult> runTransaction(
    _i6.TransactionHandler? transactionHandler, {
    bool? applyLocally = true,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #runTransaction,
          [transactionHandler],
          {#applyLocally: applyLocally},
        ),
        returnValue: _i4.Future<_i3.TransactionResult>.value(
          _FakeTransactionResult_2(
            this,
            Invocation.method(
              #runTransaction,
              [transactionHandler],
              {#applyLocally: applyLocally},
            ),
          ),
        ),
      ) as _i4.Future<_i3.TransactionResult>);

  @override
  _i3.OnDisconnect onDisconnect() => (super.noSuchMethod(
        Invocation.method(#onDisconnect, []),
        returnValue: _FakeOnDisconnect_3(
          this,
          Invocation.method(#onDisconnect, []),
        ),
      ) as _i3.OnDisconnect);

  @override
  _i4.Future<_i3.DataSnapshot> get() => (super.noSuchMethod(
        Invocation.method(#get, []),
        returnValue: _i4.Future<_i3.DataSnapshot>.value(
          _FakeDataSnapshot_4(this, Invocation.method(#get, [])),
        ),
      ) as _i4.Future<_i3.DataSnapshot>);

  @override
  _i4.Future<_i3.DatabaseEvent> once([
    _i6.DatabaseEventType? eventType = _i6.DatabaseEventType.value,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(#once, [eventType]),
        returnValue: _i4.Future<_i3.DatabaseEvent>.value(
          _FakeDatabaseEvent_5(this, Invocation.method(#once, [eventType])),
        ),
      ) as _i4.Future<_i3.DatabaseEvent>);

  @override
  _i3.Query startAt(Object? value, {String? key}) => (super.noSuchMethod(
        Invocation.method(#startAt, [value], {#key: key}),
        returnValue: _FakeQuery_6(
          this,
          Invocation.method(#startAt, [value], {#key: key}),
        ),
      ) as _i3.Query);

  @override
  _i3.Query startAfter(Object? value, {String? key}) => (super.noSuchMethod(
        Invocation.method(#startAfter, [value], {#key: key}),
        returnValue: _FakeQuery_6(
          this,
          Invocation.method(#startAfter, [value], {#key: key}),
        ),
      ) as _i3.Query);

  @override
  _i3.Query endAt(Object? value, {String? key}) => (super.noSuchMethod(
        Invocation.method(#endAt, [value], {#key: key}),
        returnValue: _FakeQuery_6(
          this,
          Invocation.method(#endAt, [value], {#key: key}),
        ),
      ) as _i3.Query);

  @override
  _i3.Query endBefore(Object? value, {String? key}) => (super.noSuchMethod(
        Invocation.method(#endBefore, [value], {#key: key}),
        returnValue: _FakeQuery_6(
          this,
          Invocation.method(#endBefore, [value], {#key: key}),
        ),
      ) as _i3.Query);

  @override
  _i3.Query equalTo(Object? value, {String? key}) => (super.noSuchMethod(
        Invocation.method(#equalTo, [value], {#key: key}),
        returnValue: _FakeQuery_6(
          this,
          Invocation.method(#equalTo, [value], {#key: key}),
        ),
      ) as _i3.Query);

  @override
  _i3.Query limitToFirst(int? limit) => (super.noSuchMethod(
        Invocation.method(#limitToFirst, [limit]),
        returnValue: _FakeQuery_6(
          this,
          Invocation.method(#limitToFirst, [limit]),
        ),
      ) as _i3.Query);

  @override
  _i3.Query limitToLast(int? limit) => (super.noSuchMethod(
        Invocation.method(#limitToLast, [limit]),
        returnValue: _FakeQuery_6(
          this,
          Invocation.method(#limitToLast, [limit]),
        ),
      ) as _i3.Query);

  @override
  _i3.Query orderByChild(String? path) => (super.noSuchMethod(
        Invocation.method(#orderByChild, [path]),
        returnValue: _FakeQuery_6(
          this,
          Invocation.method(#orderByChild, [path]),
        ),
      ) as _i3.Query);

  @override
  _i3.Query orderByKey() => (super.noSuchMethod(
        Invocation.method(#orderByKey, []),
        returnValue: _FakeQuery_6(this, Invocation.method(#orderByKey, [])),
      ) as _i3.Query);

  @override
  _i3.Query orderByValue() => (super.noSuchMethod(
        Invocation.method(#orderByValue, []),
        returnValue: _FakeQuery_6(
          this,
          Invocation.method(#orderByValue, []),
        ),
      ) as _i3.Query);

  @override
  _i3.Query orderByPriority() => (super.noSuchMethod(
        Invocation.method(#orderByPriority, []),
        returnValue: _FakeQuery_6(
          this,
          Invocation.method(#orderByPriority, []),
        ),
      ) as _i3.Query);

  @override
  _i4.Future<void> keepSynced(bool? value) => (super.noSuchMethod(
        Invocation.method(#keepSynced, [value]),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}

/// A class which mocks [DatabaseEvent].
///
/// See the documentation for Mockito's code generation for more information.
class MockDatabaseEvent extends _i1.Mock implements _i3.DatabaseEvent {
  MockDatabaseEvent() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.DatabaseEventType get type => (super.noSuchMethod(
        Invocation.getter(#type),
        returnValue: _i6.DatabaseEventType.childAdded,
      ) as _i6.DatabaseEventType);

  @override
  _i3.DataSnapshot get snapshot => (super.noSuchMethod(
        Invocation.getter(#snapshot),
        returnValue: _FakeDataSnapshot_4(
          this,
          Invocation.getter(#snapshot),
        ),
      ) as _i3.DataSnapshot);
}

/// A class which mocks [DataSnapshot].
///
/// See the documentation for Mockito's code generation for more information.
class MockDataSnapshot extends _i1.Mock implements _i3.DataSnapshot {
  MockDataSnapshot() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.DatabaseReference get ref => (super.noSuchMethod(
        Invocation.getter(#ref),
        returnValue: _FakeDatabaseReference_1(
          this,
          Invocation.getter(#ref),
        ),
      ) as _i3.DatabaseReference);

  @override
  bool get exists =>
      (super.noSuchMethod(Invocation.getter(#exists), returnValue: false)
          as bool);

  @override
  Iterable<_i3.DataSnapshot> get children => (super.noSuchMethod(
        Invocation.getter(#children),
        returnValue: <_i3.DataSnapshot>[],
      ) as Iterable<_i3.DataSnapshot>);

  @override
  bool hasChild(String? path) => (super.noSuchMethod(
        Invocation.method(#hasChild, [path]),
        returnValue: false,
      ) as bool);

  @override
  _i3.DataSnapshot child(String? path) => (super.noSuchMethod(
        Invocation.method(#child, [path]),
        returnValue: _FakeDataSnapshot_4(
          this,
          Invocation.method(#child, [path]),
        ),
      ) as _i3.DataSnapshot);
}
