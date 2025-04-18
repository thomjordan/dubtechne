// Options:
//
// x: X dimension size in samples. int [2-12], default 5
// y: Y dimension size in samples. int [2-12], default 4
// xpos: x strike position. float [0-1], default 0.5
// ypos: y strike position. float [0-1], default 0.5
// decay: decay factor. float [0-1], default 0.999

Mesh2D mesh1 => dac.left;
Mesh2D mesh2 => dac.right;
0.382 => mesh1.gain => mesh2.gain;

(20./135.)::second => dur pulse8;
pulse8 - (now % pulse8) => now; 

while (true)
{
    Math.random2(2,12) => mesh1.x;
    Math.random2(2,12) => mesh1.y;
    Math.randomf() => mesh1.xpos;
    Math.randomf() => mesh1.ypos;
    1 => mesh1.noteOn;
    pulse8 => now;
    Math.random2(2,12) => mesh2.x;
    Math.random2(2,12) => mesh2.y;
    Math.randomf() => mesh2.xpos;
    Math.randomf() => mesh2.ypos;
    1 => mesh2.noteOn;
    pulse8 => now;
    
}