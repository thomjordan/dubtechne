fun void yo(int a, int b) {
    <<< "yo(", a, ",", b, ") prints:", a + b >>>;
}

fun void yoyo(int a, string s) {
    <<< "yoyo(", a, ",", s, ") prints:" >>>;
    repeat(a) { <<< s >>>; }
}

(40, 64)  => yo; // ChucKing multiple args requires parens
(3, "oi!") => yoyo;

@(40, 64, 100) @=> auto foo;
   @( 1, 0, 0) @=> auto e1;
   @( 0, 1, 0) @=> auto e2;
   @( 0, 0, 1) @=> auto e3;
   
@(1, 2, 3, 4) @=> auto bar;
<<< bar >>>;
   
//foo.normalize();

<<< foo.dot(e3) >>>;
