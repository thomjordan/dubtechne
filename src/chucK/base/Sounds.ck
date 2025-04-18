@import "globals.ck"

SndBuf buf1( sounds.get("tamb_shake", 384) ) => dac;  // play sound by number of file in folder (any_int_value % numfiles_in_folder)
0.5::second => now;
SndBuf buf2( sounds.get("snare_long") ) => dac;       // play random sound from folder
0.5::second => now;
Machine.clearVM();  // to be able to evaluate this file multiple times

public class sounds extends Object
{

    fun static string[][] getFilepathsAt(string relativePathOfDirectory)
    {
        me.dir() + relativePathOfDirectory => string pathToDirectory; // get path to sounds directory
        
        FileIO fio; 
        fio.open( pathToDirectory, FileIO.READ );  // open the directory
        fio.dirList() @=> string names[];   // get all the filenames in directory
        
        string allPathsWithNames[0][names.size()];
        string paths[names.size()];
        
        // construct a full filepath for each filename in directory
        // also include the filenames themselves (much shorter than the full paths), so they may ease in doing sound selection with logging
        for(0 => int i; i < names.size(); i++)  
            pathToDirectory + names[i] => paths[i];
        
        paths @=> allPathsWithNames["path"];
        names @=> allPathsWithNames["name"];
        
        return allPathsWithNames; // return array of all filepaths
    }

    fun static string get(string dirname)
    {  
        g.soundsFolder + "/" + dirname + "/" => string relpath;
        
        getFilepathsAt(relpath) @=> string allSoundsInDir[][];
        Math.random2(0, allSoundsInDir["name"].size()-1) => int randnum;
        
        <<< "selected", dirname, "#", randnum, ":", allSoundsInDir["name"][randnum] >>>; // print out the filename only (not the full path)
        
        return allSoundsInDir["path"][randnum];  // return absolute-path to randomly-chosen audio file
    }

    fun static string get(string dirname, int wavnum)
    {  
        g.soundsFolder + "/" + dirname + "/" => string relpath;
        getFilepathsAt(relpath) @=> string allSoundsInDir[][];
        allSoundsInDir["name"].size() => int numWavs;
        wavnum % numWavs => int boundedWavNum;
        
        <<< "selected", dirname, "#", boundedWavNum, ":", allSoundsInDir["name"][boundedWavNum] >>>; // print out the filename only (not the full path)
        
        return allSoundsInDir["path"][boundedWavNum];  // return absolute-path to randomly-chosen audio file
    }

}

// 20::second => now;
