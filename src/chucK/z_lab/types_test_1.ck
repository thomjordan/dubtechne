
// class Yo extends Object { }

fun int add(int x, int y) { return x + y; }

function void yo() { <<< "Yo!" >>>; }

//yo();

Type.getTypes() @=> Type currentTypes[];

// for( Type t : Type.getTypes() ) <<< t.name() >>>;

<<< currentTypes.size() >>>;

currentTypes[1].name() => string name;

<<< name >>>;

yo  @=> auto yoFun;
add @=> auto addFun;\

addFun(1,2) => auto result;

<<< "result of addFun(1,2) is:", result >>>;