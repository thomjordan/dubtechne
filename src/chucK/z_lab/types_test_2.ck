// passing functions as first class values

fun int add(int x, int y) { return x + y; }
fun int sub(int x, int y) { return x - y; }
fun int mul(int x, int y) { return x * y; }
fun int div(int x, int y) { return x / y; }

add @=> auto someFun;
mul @=> someFun;

<<< "result of     add(1,2) is:",     add(1,2) >>>;
<<< "result of someFun(1,2) is:", someFun(1,2) >>>;


//[[div]] @=> auto moreFun[][];

//moreFun[1] << [sub];

//for(0 => int i; i < moreFun.size(); i++ ) <<< moreFun[i] >>>;

class Yo extends Object 
{
    auto funvar;
    
    
}