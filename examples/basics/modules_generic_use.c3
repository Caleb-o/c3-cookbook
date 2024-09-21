import genericmodule;

Foo(<int>) foo;

// or use define
def IntFoo = Foo(<int>);

IntFoo foo;

fn void main() {
  // NOTE: The generic parameter is required here, as well as the module name prefix
  int a = genericmodule::return_t(<int>)(10);
}