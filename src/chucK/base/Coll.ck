SawOsc osc => LPF filter => dac;

0 => filter.freq;
60 => osc.freq;
6 => filter.Q;
0.1 => osc.gain;

625::ms => dur T;
T - (now % T) => now;

[1.0, 1.5, 2.0, 1.6] @=> float scalars1[];
[1.0, 2.0, 4.0] @=> float scalars2[];

scalars2 @=> float scl[];

[1,2,3,4] @=> int list[];

0 => int counter;

while(true) 
{
    scl[counter/2 % scl.size()] => float s;
    
    for(2000 => int i; i > 0; i--) {
        (i * s) / 3.0 => filter.freq;
        T / 2000 => now;
    }
    
    counter + 1 => counter;
}


class FloatList extends Object 
{
    float list[];
    float history[128][0];
    0 => int historySize;
    0 => int counter;
    
    fun void write(float inlist[]) {
        if(list.size() > 0) addCurrentListToHistory(); // if list already has contents, add it to history before updating it
        inlist @=> list;
        
    }
    
    fun float next() {
        list[counter % list.size()] => float nextElement;
        counter++;
        return nextElement;
    }
    
    fun float previous() {
        // { counter - 1 } would be the same element, since counter doesn't update until after the element is used
        // so we do { counter - 2 } which is the previous element, then update counter as normal with counter++
        // if previous is called more than once in a row, it will continue to access the "next previous element"
        // negative array indices are allowed as long as they are mod'd by list.size()
        counter - 2 => counter; 
        list[counter % list.size()] => float prevElement;
        counter++;
        return prevElement;
    }
    
    fun float again() {
        counter - 1 => counter; 
        list[counter % list.size()] => float sameElement;
        counter++;
        return sameElement;
    }
    
    fun void restart() {
        0 => counter;
    }
    
    // jump to a random place in the list and continue on from there
    fun float jump() {
        if(list.size() == 1) return next(); // needed so next line won't risk throwing an error
        Math.random2(1, list.size()-1) => int j;
        counter + j => counter;
        return next();
    }
    
    // jump to a specified place in list and continue on from there
    // jump(0) does the same thing as next()
    // jump(-1) is the same as again()
    // jump(-2) is the same as previous(), jump(-3) jumps to the value before that, etc.
    fun float jump(int j) {
        counter + j => counter;
        return next();
    }
    
    fun float nth(int i) {
        return list[i % list.size()];
    }
    
    fun float randElem() {
        Math.random2(0, list.size()-1) => int i;
        return list[i];
    }
    
    fun void shuffle() {
        addCurrentListToHistory();
        list.shuffle();
    }
    
    // restores list to original contents
    fun void restore() {
        addCurrentListToHistory();
        history[0] => copy @=> list;
    }
    
    // restores to the list n-places-back in history
    fun void restore(int n) {
        addCurrentListToHistory();
        history[-n % history.size()] => copy @=> list;
    }
    
    fun void scaleBy(float scalar) {
        addCurrentListToHistory();
        float newlist[0];
        for(auto e: list) newlist << e*scalar;
    }
    
    fun void reverse()  { addCurrentListToHistory(); list.reverse();  }
    fun void popBack()  { addCurrentListToHistory(); list.popBack();  }
    fun void popFront() { addCurrentListToHistory(); list.popFront(); }
    fun void popOut(int pos) { addCurrentListToHistory(); list.popOut(pos % list.size()); }
    
    // private
    fun float[] copy(float inlist[]) {
        float copy[0];
        for(float e: inlist) copy << e;
        return copy;
    }
    
    fun void addCurrentListToHistory() {
        list => copy @=> history[historySize];
        historySize++;
    }
}


class IntList extends Object 
{
    int list[];
    int history[128][0];
    0 => int historySize;
    0 => int counter;
    
    fun void write(int inlist[]) {
        if(list.size() > 0) addCurrentListToHistory(); // if list already has contents, add it to history before updating it
        inlist @=> list;
        
    }
    
    fun int next() {
        list[counter % list.size()] => int nextElement;
        counter++;
        return nextElement;
    }
    
    fun int previous() {
        // { counter - 1 } would be the same element, since counter doesn't update until after the element is used
        // so we do { counter - 2 } which is the previous element, then update counter as normal with counter++
        // if previous is called more than once in a row, it will continue to access the "next previous element"
        // negative array indices are allowed as long as they are mod'd by list.size()
        counter - 2 => counter; 
        list[counter % list.size()] => int prevElement;
        counter++;
        return prevElement;
    }
    
    fun int again() {
        counter - 1 => counter; 
        list[counter % list.size()] => int sameElement;
        counter++;
        return sameElement;
    }
    
    fun void restart() {
        0 => counter;
    }
    
    // jump to a random place in the list and continue on from there
    fun int jump() {
        if(list.size() == 1) return next(); // needed so next line won't risk throwing an error
        Math.random2(1, list.size()-1) => int j;
        counter + j => counter;
        return next();
    }
    
    // jump to a specified place in list and continue on from there
    // jump(0) does the same thing as next()
    // jump(-1) is the same as again()
    // jump(-2) is the same as previous(), jump(-3) jumps to the value before that, etc.
    fun int jump(int j) {
        counter + j => counter;
        return next();
    }
    
    fun int nth(int i) {
        return list[i % list.size()];
    }
    
    fun int randElem() {
        Math.random2(0, list.size()-1) => int i;
        return list[i];
    }
    
    fun void shuffle() {
        addCurrentListToHistory();
        list.shuffle();
    }
    
    // restores list to original contents
    fun void restore() {
        addCurrentListToHistory();
        history[0] => copy @=> list;
    }
    
    // restores to the list n-places-back in history
    fun void restore(int n) {
        addCurrentListToHistory();
        history[-n % history.size()] => copy @=> list;
    }
    
    fun void transpose(int amt) {
        addCurrentListToHistory();
        int newlist[0];
        for(auto e: list) newlist << e + amt;
    }
    
    fun void reverse()  { addCurrentListToHistory(); list.reverse();  }
    fun void popBack()  { addCurrentListToHistory(); list.popBack();  }
    fun void popFront() { addCurrentListToHistory(); list.popFront(); }
    fun void popOut(int pos) { addCurrentListToHistory(); list.popOut(pos % list.size()); }
    
    // private
    fun int[] copy(int inlist[]) {
        int copy[0];
        for(int e: inlist) copy << e;
        return copy;
    }
    
    fun void addCurrentListToHistory() {
        list => copy @=> history[historySize];
        historySize++;
    }
}
