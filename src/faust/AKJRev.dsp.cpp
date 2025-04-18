/* ------------------------------------------------------------
author: "Aaron Krister Johnson"
name: "AKJRev"
Code generated with Faust 2.80.0 (https://faust.grame.fr)
Compilation options: -a .faust2ck_tmp/AKJRev.dsp-wrapper.cpp -lang cpp -ct 1 -es 1 -mcd 16 -mdd 1024 -mdy 33 -single -ftz 0
------------------------------------------------------------ */

#ifndef  __mydsp_H__
#define  __mydsp_H__

#include "chugin.h"
// #include "chuck_dl.h"

#include <stdio.h>
#include <string.h>
#include <limits.h>

#include <map>
#include <string>
#include <cmath>
#include <algorithm>

//-------------------------------------------------------------------
// Generic min and max using C++ inline
//-------------------------------------------------------------------

inline int      lsr (int x, int n)          { return int(((unsigned int)x) >> n); }
inline int      int2pow2 (int x)            { int r=0; while ((1<<r)<x) r++; return r; }


/******************************************************************************
 *******************************************************************************
 
 FAUST META DATA
 
 *******************************************************************************
 *******************************************************************************/

struct Meta : std::map<std::string, std::string>
{
    void declare(const char* key, const char* value)
    {
        (*this)[key] = value;
    }
};

/* UI class - do-nothing (from FAUST/minimal.cpp) */

#ifdef WIN32
#ifdef interface
#undef interface
#endif // interface
#endif // WIN32

#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif

class Soundfile;

class UI
{
    public:
        virtual ~UI() {}
        
        // active widgets
        virtual void addButton(const char* label, FAUSTFLOAT* zone) = 0;
        virtual void addCheckButton(const char* label, FAUSTFLOAT* zone) = 0;
        virtual void addVerticalSlider(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step) = 0;
        virtual void addHorizontalSlider(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step) = 0;
        virtual void addNumEntry(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step) = 0;
        
        // passive widgets
        virtual void addHorizontalBargraph(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT min, FAUSTFLOAT max) = 0;
        virtual void addVerticalBargraph(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT min, FAUSTFLOAT max) = 0;
        
        // layout widgets
        virtual void openTabBox(const char* label) = 0;
        virtual void openHorizontalBox(const char* label) = 0;
        virtual void openVerticalBox(const char* label) = 0;
        virtual void closeBox() = 0;
        
        // soundfiles
        
        virtual void addSoundfile(const char* label, const char* filename, Soundfile** sf_zone) = 0;
        
        virtual void declare(FAUSTFLOAT* zone, const char* key, const char* value) {}
};

class dsp
{
    public:
        virtual ~dsp() {}

        virtual int getNumInputs() = 0;
        virtual int getNumOutputs() = 0;
        virtual void buildUserInterface(UI* interface) = 0;
        virtual int getSampleRate() = 0;
        virtual void init(int samplingRate) = 0;
        virtual void instanceInit(int sample_rate) = 0;
        virtual void instanceConstants(int sample_rate) = 0;
        virtual void instanceResetUserInterface() = 0;
        virtual void instanceClear() = 0;
        virtual dsp* clone() = 0;
        virtual void metadata(Meta* m) = 0;
        virtual void compute(int len, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) = 0;

        SAMPLE ** ck_frame_in;
        SAMPLE ** ck_frame_out;
};

/*
 * FAUST intrinsic
 */

/*
 * FAUST defines UI values as private, but provides no getters/setters.
 * In our particular case it's way more convenient to access them directly
 * than to set up a complicated UI structure.  Also get rid of everything
 * being "virtual", since it may stop the compiler from inlining properly!
 */
#define private public
#define virtual

/* Rename the class the name of our DSP. */
#define mydsp AKJRev

/*
 * FAUST class
 */
#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif 

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <math.h>

#ifndef FAUSTCLASS 
#define FAUSTCLASS mydsp
#endif

#ifdef __APPLE__ 
#define exp10f __exp10f
#define exp10 __exp10
#endif

#if defined(_WIN32)
#define RESTRICT __restrict
#else
#define RESTRICT __restrict__
#endif


class mydsp : public dsp {
	
 private:
	
	FAUSTFLOAT fEntry0;
	FAUSTFLOAT fEntry1;
	int fSampleRate;
	float fConst0;
	FAUSTFLOAT fEntry2;
	float fRec16[2];
	float fRec17[2];
	float fRec18[2];
	float fRec19[2];
	float fRec20[2];
	float fRec21[2];
	float fRec22[2];
	float fRec23[2];
	float fRec24[2];
	float fRec25[2];
	float fRec26[2];
	float fRec27[2];
	float fRec28[2];
	float fRec29[2];
	float fRec30[2];
	float fRec31[2];
	int IOTA0;
	float fVec0[8192];
	float fRec32[2];
	float fRec33[2];
	float fRec34[2];
	float fRec35[2];
	float fRec0[3];
	float fVec1[8192];
	float fRec36[2];
	float fRec37[2];
	float fRec38[2];
	float fRec39[2];
	float fRec1[3];
	float fVec2[8192];
	float fRec40[2];
	float fRec41[2];
	float fRec42[2];
	float fRec43[2];
	float fRec2[3];
	float fVec3[8192];
	float fRec44[2];
	float fRec45[2];
	float fRec46[2];
	float fRec47[2];
	float fRec3[3];
	float fVec4[8192];
	float fRec48[2];
	float fRec49[2];
	float fRec50[2];
	float fRec51[2];
	float fRec4[3];
	float fVec5[8192];
	float fRec52[2];
	float fRec53[2];
	float fRec54[2];
	float fRec55[2];
	float fRec5[3];
	float fVec6[8192];
	float fRec56[2];
	float fRec57[2];
	float fRec58[2];
	float fRec59[2];
	float fRec6[3];
	float fVec7[8192];
	float fRec60[2];
	float fRec61[2];
	float fRec62[2];
	float fRec63[2];
	float fRec7[3];
	float fVec8[8192];
	float fRec64[2];
	float fRec65[2];
	float fRec66[2];
	float fRec67[2];
	float fRec8[3];
	float fVec9[8192];
	float fRec68[2];
	float fRec69[2];
	float fRec70[2];
	float fRec71[2];
	float fRec9[3];
	float fVec10[8192];
	float fRec72[2];
	float fRec73[2];
	float fRec74[2];
	float fRec75[2];
	float fRec10[3];
	float fVec11[8192];
	float fRec76[2];
	float fRec77[2];
	float fRec78[2];
	float fRec79[2];
	float fRec11[3];
	float fVec12[8192];
	float fRec80[2];
	float fRec81[2];
	float fRec82[2];
	float fRec83[2];
	float fRec12[3];
	float fVec13[8192];
	float fRec84[2];
	float fRec85[2];
	float fRec86[2];
	float fRec87[2];
	float fRec13[3];
	float fVec14[8192];
	float fRec88[2];
	float fRec89[2];
	float fRec90[2];
	float fRec91[2];
	float fRec14[3];
	float fVec15[8192];
	float fRec92[2];
	float fRec93[2];
	float fRec94[2];
	float fRec95[2];
	float fRec15[3];
	
 public:
	mydsp() {
	}
	
	void metadata(Meta* m) { 
		m->declare("about", "AKJRev is a reverb modeled after reverbsc in csound by Sean Costello. It utilizes his approach of mixing several delays whose lengths are some prime number of samples.");
		m->declare("author", "Aaron Krister Johnson");
		m->declare("basics.lib/name", "Faust Basic Element Library");
		m->declare("basics.lib/sAndH:author", "Romain Michon");
		m->declare("basics.lib/version", "1.21.0");
		m->declare("compile_options", "-a .faust2ck_tmp/AKJRev.dsp-wrapper.cpp -lang cpp -ct 1 -es 1 -mcd 16 -mdd 1024 -mdy 33 -single -ftz 0");
		m->declare("delays.lib/name", "Faust Delay Library");
		m->declare("delays.lib/version", "1.1.0");
		m->declare("filename", "AKJRev.dsp");
		m->declare("filters.lib/lowpass0_highpass1", "MIT-style STK-4.3 license");
		m->declare("filters.lib/lowpass0_highpass1:author", "Julius O. Smith III");
		m->declare("filters.lib/lowpass:author", "Julius O. Smith III");
		m->declare("filters.lib/lowpass:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
		m->declare("filters.lib/lowpass:license", "MIT-style STK-4.3 license");
		m->declare("filters.lib/name", "Faust Filters Library");
		m->declare("filters.lib/tf1:author", "Julius O. Smith III");
		m->declare("filters.lib/tf1:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
		m->declare("filters.lib/tf1:license", "MIT-style STK-4.3 license");
		m->declare("filters.lib/tf1s:author", "Julius O. Smith III");
		m->declare("filters.lib/tf1s:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
		m->declare("filters.lib/tf1s:license", "MIT-style STK-4.3 license");
		m->declare("filters.lib/version", "1.7.1");
		m->declare("maths.lib/author", "GRAME");
		m->declare("maths.lib/copyright", "GRAME");
		m->declare("maths.lib/license", "LGPL with exception");
		m->declare("maths.lib/name", "Faust Math Library");
		m->declare("maths.lib/version", "2.8.1");
		m->declare("misceffects.lib/dryWetMixerConstantPower:author", "David Braun, revised by Stéphane Letz");
		m->declare("misceffects.lib/name", "Misc Effects Library");
		m->declare("misceffects.lib/version", "2.5.1");
		m->declare("name", "AKJRev");
		m->declare("noises.lib/name", "Faust Noise Generator Library");
		m->declare("noises.lib/version", "1.4.1");
		m->declare("platform.lib/name", "Generic Platform Library");
		m->declare("platform.lib/version", "1.3.0");
		m->declare("signals.lib/name", "Faust Signal Routing Library");
		m->declare("signals.lib/version", "1.6.0");
	}

	virtual int getNumInputs() {
		return 2;
	}
	virtual int getNumOutputs() {
		return 2;
	}
	
	static void classInit(int sample_rate) {
	}
	
	virtual void instanceConstants(int sample_rate) {
		fSampleRate = sample_rate;
		fConst0 = 3.1415927f / std::min<float>(1.92e+05f, std::max<float>(1.0f, float(fSampleRate)));
	}
	
	virtual void instanceResetUserInterface() {
		fEntry0 = FAUSTFLOAT(0.5f);
		fEntry1 = FAUSTFLOAT(0.7f);
		fEntry2 = FAUSTFLOAT(5e+03f);
	}
	
	virtual void instanceClear() {
		for (int l0 = 0; l0 < 2; l0 = l0 + 1) {
			fRec16[l0] = 0.0f;
		}
		for (int l1 = 0; l1 < 2; l1 = l1 + 1) {
			fRec17[l1] = 0.0f;
		}
		for (int l2 = 0; l2 < 2; l2 = l2 + 1) {
			fRec18[l2] = 0.0f;
		}
		for (int l3 = 0; l3 < 2; l3 = l3 + 1) {
			fRec19[l3] = 0.0f;
		}
		for (int l4 = 0; l4 < 2; l4 = l4 + 1) {
			fRec20[l4] = 0.0f;
		}
		for (int l5 = 0; l5 < 2; l5 = l5 + 1) {
			fRec21[l5] = 0.0f;
		}
		for (int l6 = 0; l6 < 2; l6 = l6 + 1) {
			fRec22[l6] = 0.0f;
		}
		for (int l7 = 0; l7 < 2; l7 = l7 + 1) {
			fRec23[l7] = 0.0f;
		}
		for (int l8 = 0; l8 < 2; l8 = l8 + 1) {
			fRec24[l8] = 0.0f;
		}
		for (int l9 = 0; l9 < 2; l9 = l9 + 1) {
			fRec25[l9] = 0.0f;
		}
		for (int l10 = 0; l10 < 2; l10 = l10 + 1) {
			fRec26[l10] = 0.0f;
		}
		for (int l11 = 0; l11 < 2; l11 = l11 + 1) {
			fRec27[l11] = 0.0f;
		}
		for (int l12 = 0; l12 < 2; l12 = l12 + 1) {
			fRec28[l12] = 0.0f;
		}
		for (int l13 = 0; l13 < 2; l13 = l13 + 1) {
			fRec29[l13] = 0.0f;
		}
		for (int l14 = 0; l14 < 2; l14 = l14 + 1) {
			fRec30[l14] = 0.0f;
		}
		for (int l15 = 0; l15 < 2; l15 = l15 + 1) {
			fRec31[l15] = 0.0f;
		}
		IOTA0 = 0;
		for (int l16 = 0; l16 < 8192; l16 = l16 + 1) {
			fVec0[l16] = 0.0f;
		}
		for (int l17 = 0; l17 < 2; l17 = l17 + 1) {
			fRec32[l17] = 0.0f;
		}
		for (int l18 = 0; l18 < 2; l18 = l18 + 1) {
			fRec33[l18] = 0.0f;
		}
		for (int l19 = 0; l19 < 2; l19 = l19 + 1) {
			fRec34[l19] = 0.0f;
		}
		for (int l20 = 0; l20 < 2; l20 = l20 + 1) {
			fRec35[l20] = 0.0f;
		}
		for (int l21 = 0; l21 < 3; l21 = l21 + 1) {
			fRec0[l21] = 0.0f;
		}
		for (int l22 = 0; l22 < 8192; l22 = l22 + 1) {
			fVec1[l22] = 0.0f;
		}
		for (int l23 = 0; l23 < 2; l23 = l23 + 1) {
			fRec36[l23] = 0.0f;
		}
		for (int l24 = 0; l24 < 2; l24 = l24 + 1) {
			fRec37[l24] = 0.0f;
		}
		for (int l25 = 0; l25 < 2; l25 = l25 + 1) {
			fRec38[l25] = 0.0f;
		}
		for (int l26 = 0; l26 < 2; l26 = l26 + 1) {
			fRec39[l26] = 0.0f;
		}
		for (int l27 = 0; l27 < 3; l27 = l27 + 1) {
			fRec1[l27] = 0.0f;
		}
		for (int l28 = 0; l28 < 8192; l28 = l28 + 1) {
			fVec2[l28] = 0.0f;
		}
		for (int l29 = 0; l29 < 2; l29 = l29 + 1) {
			fRec40[l29] = 0.0f;
		}
		for (int l30 = 0; l30 < 2; l30 = l30 + 1) {
			fRec41[l30] = 0.0f;
		}
		for (int l31 = 0; l31 < 2; l31 = l31 + 1) {
			fRec42[l31] = 0.0f;
		}
		for (int l32 = 0; l32 < 2; l32 = l32 + 1) {
			fRec43[l32] = 0.0f;
		}
		for (int l33 = 0; l33 < 3; l33 = l33 + 1) {
			fRec2[l33] = 0.0f;
		}
		for (int l34 = 0; l34 < 8192; l34 = l34 + 1) {
			fVec3[l34] = 0.0f;
		}
		for (int l35 = 0; l35 < 2; l35 = l35 + 1) {
			fRec44[l35] = 0.0f;
		}
		for (int l36 = 0; l36 < 2; l36 = l36 + 1) {
			fRec45[l36] = 0.0f;
		}
		for (int l37 = 0; l37 < 2; l37 = l37 + 1) {
			fRec46[l37] = 0.0f;
		}
		for (int l38 = 0; l38 < 2; l38 = l38 + 1) {
			fRec47[l38] = 0.0f;
		}
		for (int l39 = 0; l39 < 3; l39 = l39 + 1) {
			fRec3[l39] = 0.0f;
		}
		for (int l40 = 0; l40 < 8192; l40 = l40 + 1) {
			fVec4[l40] = 0.0f;
		}
		for (int l41 = 0; l41 < 2; l41 = l41 + 1) {
			fRec48[l41] = 0.0f;
		}
		for (int l42 = 0; l42 < 2; l42 = l42 + 1) {
			fRec49[l42] = 0.0f;
		}
		for (int l43 = 0; l43 < 2; l43 = l43 + 1) {
			fRec50[l43] = 0.0f;
		}
		for (int l44 = 0; l44 < 2; l44 = l44 + 1) {
			fRec51[l44] = 0.0f;
		}
		for (int l45 = 0; l45 < 3; l45 = l45 + 1) {
			fRec4[l45] = 0.0f;
		}
		for (int l46 = 0; l46 < 8192; l46 = l46 + 1) {
			fVec5[l46] = 0.0f;
		}
		for (int l47 = 0; l47 < 2; l47 = l47 + 1) {
			fRec52[l47] = 0.0f;
		}
		for (int l48 = 0; l48 < 2; l48 = l48 + 1) {
			fRec53[l48] = 0.0f;
		}
		for (int l49 = 0; l49 < 2; l49 = l49 + 1) {
			fRec54[l49] = 0.0f;
		}
		for (int l50 = 0; l50 < 2; l50 = l50 + 1) {
			fRec55[l50] = 0.0f;
		}
		for (int l51 = 0; l51 < 3; l51 = l51 + 1) {
			fRec5[l51] = 0.0f;
		}
		for (int l52 = 0; l52 < 8192; l52 = l52 + 1) {
			fVec6[l52] = 0.0f;
		}
		for (int l53 = 0; l53 < 2; l53 = l53 + 1) {
			fRec56[l53] = 0.0f;
		}
		for (int l54 = 0; l54 < 2; l54 = l54 + 1) {
			fRec57[l54] = 0.0f;
		}
		for (int l55 = 0; l55 < 2; l55 = l55 + 1) {
			fRec58[l55] = 0.0f;
		}
		for (int l56 = 0; l56 < 2; l56 = l56 + 1) {
			fRec59[l56] = 0.0f;
		}
		for (int l57 = 0; l57 < 3; l57 = l57 + 1) {
			fRec6[l57] = 0.0f;
		}
		for (int l58 = 0; l58 < 8192; l58 = l58 + 1) {
			fVec7[l58] = 0.0f;
		}
		for (int l59 = 0; l59 < 2; l59 = l59 + 1) {
			fRec60[l59] = 0.0f;
		}
		for (int l60 = 0; l60 < 2; l60 = l60 + 1) {
			fRec61[l60] = 0.0f;
		}
		for (int l61 = 0; l61 < 2; l61 = l61 + 1) {
			fRec62[l61] = 0.0f;
		}
		for (int l62 = 0; l62 < 2; l62 = l62 + 1) {
			fRec63[l62] = 0.0f;
		}
		for (int l63 = 0; l63 < 3; l63 = l63 + 1) {
			fRec7[l63] = 0.0f;
		}
		for (int l64 = 0; l64 < 8192; l64 = l64 + 1) {
			fVec8[l64] = 0.0f;
		}
		for (int l65 = 0; l65 < 2; l65 = l65 + 1) {
			fRec64[l65] = 0.0f;
		}
		for (int l66 = 0; l66 < 2; l66 = l66 + 1) {
			fRec65[l66] = 0.0f;
		}
		for (int l67 = 0; l67 < 2; l67 = l67 + 1) {
			fRec66[l67] = 0.0f;
		}
		for (int l68 = 0; l68 < 2; l68 = l68 + 1) {
			fRec67[l68] = 0.0f;
		}
		for (int l69 = 0; l69 < 3; l69 = l69 + 1) {
			fRec8[l69] = 0.0f;
		}
		for (int l70 = 0; l70 < 8192; l70 = l70 + 1) {
			fVec9[l70] = 0.0f;
		}
		for (int l71 = 0; l71 < 2; l71 = l71 + 1) {
			fRec68[l71] = 0.0f;
		}
		for (int l72 = 0; l72 < 2; l72 = l72 + 1) {
			fRec69[l72] = 0.0f;
		}
		for (int l73 = 0; l73 < 2; l73 = l73 + 1) {
			fRec70[l73] = 0.0f;
		}
		for (int l74 = 0; l74 < 2; l74 = l74 + 1) {
			fRec71[l74] = 0.0f;
		}
		for (int l75 = 0; l75 < 3; l75 = l75 + 1) {
			fRec9[l75] = 0.0f;
		}
		for (int l76 = 0; l76 < 8192; l76 = l76 + 1) {
			fVec10[l76] = 0.0f;
		}
		for (int l77 = 0; l77 < 2; l77 = l77 + 1) {
			fRec72[l77] = 0.0f;
		}
		for (int l78 = 0; l78 < 2; l78 = l78 + 1) {
			fRec73[l78] = 0.0f;
		}
		for (int l79 = 0; l79 < 2; l79 = l79 + 1) {
			fRec74[l79] = 0.0f;
		}
		for (int l80 = 0; l80 < 2; l80 = l80 + 1) {
			fRec75[l80] = 0.0f;
		}
		for (int l81 = 0; l81 < 3; l81 = l81 + 1) {
			fRec10[l81] = 0.0f;
		}
		for (int l82 = 0; l82 < 8192; l82 = l82 + 1) {
			fVec11[l82] = 0.0f;
		}
		for (int l83 = 0; l83 < 2; l83 = l83 + 1) {
			fRec76[l83] = 0.0f;
		}
		for (int l84 = 0; l84 < 2; l84 = l84 + 1) {
			fRec77[l84] = 0.0f;
		}
		for (int l85 = 0; l85 < 2; l85 = l85 + 1) {
			fRec78[l85] = 0.0f;
		}
		for (int l86 = 0; l86 < 2; l86 = l86 + 1) {
			fRec79[l86] = 0.0f;
		}
		for (int l87 = 0; l87 < 3; l87 = l87 + 1) {
			fRec11[l87] = 0.0f;
		}
		for (int l88 = 0; l88 < 8192; l88 = l88 + 1) {
			fVec12[l88] = 0.0f;
		}
		for (int l89 = 0; l89 < 2; l89 = l89 + 1) {
			fRec80[l89] = 0.0f;
		}
		for (int l90 = 0; l90 < 2; l90 = l90 + 1) {
			fRec81[l90] = 0.0f;
		}
		for (int l91 = 0; l91 < 2; l91 = l91 + 1) {
			fRec82[l91] = 0.0f;
		}
		for (int l92 = 0; l92 < 2; l92 = l92 + 1) {
			fRec83[l92] = 0.0f;
		}
		for (int l93 = 0; l93 < 3; l93 = l93 + 1) {
			fRec12[l93] = 0.0f;
		}
		for (int l94 = 0; l94 < 8192; l94 = l94 + 1) {
			fVec13[l94] = 0.0f;
		}
		for (int l95 = 0; l95 < 2; l95 = l95 + 1) {
			fRec84[l95] = 0.0f;
		}
		for (int l96 = 0; l96 < 2; l96 = l96 + 1) {
			fRec85[l96] = 0.0f;
		}
		for (int l97 = 0; l97 < 2; l97 = l97 + 1) {
			fRec86[l97] = 0.0f;
		}
		for (int l98 = 0; l98 < 2; l98 = l98 + 1) {
			fRec87[l98] = 0.0f;
		}
		for (int l99 = 0; l99 < 3; l99 = l99 + 1) {
			fRec13[l99] = 0.0f;
		}
		for (int l100 = 0; l100 < 8192; l100 = l100 + 1) {
			fVec14[l100] = 0.0f;
		}
		for (int l101 = 0; l101 < 2; l101 = l101 + 1) {
			fRec88[l101] = 0.0f;
		}
		for (int l102 = 0; l102 < 2; l102 = l102 + 1) {
			fRec89[l102] = 0.0f;
		}
		for (int l103 = 0; l103 < 2; l103 = l103 + 1) {
			fRec90[l103] = 0.0f;
		}
		for (int l104 = 0; l104 < 2; l104 = l104 + 1) {
			fRec91[l104] = 0.0f;
		}
		for (int l105 = 0; l105 < 3; l105 = l105 + 1) {
			fRec14[l105] = 0.0f;
		}
		for (int l106 = 0; l106 < 8192; l106 = l106 + 1) {
			fVec15[l106] = 0.0f;
		}
		for (int l107 = 0; l107 < 2; l107 = l107 + 1) {
			fRec92[l107] = 0.0f;
		}
		for (int l108 = 0; l108 < 2; l108 = l108 + 1) {
			fRec93[l108] = 0.0f;
		}
		for (int l109 = 0; l109 < 2; l109 = l109 + 1) {
			fRec94[l109] = 0.0f;
		}
		for (int l110 = 0; l110 < 2; l110 = l110 + 1) {
			fRec95[l110] = 0.0f;
		}
		for (int l111 = 0; l111 < 3; l111 = l111 + 1) {
			fRec15[l111] = 0.0f;
		}
	}
	
	virtual void init(int sample_rate) {
		classInit(sample_rate);
		instanceInit(sample_rate);
	}
	
	virtual void instanceInit(int sample_rate) {
		instanceConstants(sample_rate);
		instanceResetUserInterface();
		instanceClear();
	}
	
	virtual mydsp* clone() {
		return new mydsp();
	}
	
	virtual int getSampleRate() {
		return fSampleRate;
	}
	
	virtual void buildUserInterface(UI* ui_interface) {
		ui_interface->openVerticalBox("AKJRev");
		ui_interface->addNumEntry("cutoff", &fEntry2, FAUSTFLOAT(5e+03f), FAUSTFLOAT(5e+02f), FAUSTFLOAT(1.2e+04f), FAUSTFLOAT(0.01f));
		ui_interface->addNumEntry("feedback", &fEntry1, FAUSTFLOAT(0.7f), FAUSTFLOAT(0.0f), FAUSTFLOAT(1.0f), FAUSTFLOAT(0.01f));
		ui_interface->addNumEntry("wet", &fEntry0, FAUSTFLOAT(0.5f), FAUSTFLOAT(0.0f), FAUSTFLOAT(1.0f), FAUSTFLOAT(0.01f));
		ui_interface->closeBox();
	}
	
	virtual void compute(int count, FAUSTFLOAT** RESTRICT inputs, FAUSTFLOAT** RESTRICT outputs) {
		FAUSTFLOAT* input0 = inputs[0];
		FAUSTFLOAT* input1 = inputs[1];
		FAUSTFLOAT* output0 = outputs[0];
		FAUSTFLOAT* output1 = outputs[1];
		float fSlow0 = 1.4137167f * float(fEntry0);
		float fSlow1 = std::sin(fSlow0);
		float fSlow2 = 0.25f * float(fEntry1);
		float fSlow3 = 1.0f / std::tan(fConst0 * float(fEntry2));
		float fSlow4 = 1.0f / (fSlow3 + 1.0f);
		float fSlow5 = 1.0f - fSlow3;
		float fSlow6 = std::cos(fSlow0);
		for (int i0 = 0; i0 < count; i0 = i0 + 1) {
			float fTemp0 = float(input0[i0]);
			fRec16[0] = -(fSlow4 * (fSlow5 * fRec16[1] - (fRec0[1] + fRec0[2])));
			fRec17[0] = -(fSlow4 * (fSlow5 * fRec17[1] - (fRec8[1] + fRec8[2])));
			float fTemp1 = fRec16[0] + fRec17[0];
			fRec18[0] = -(fSlow4 * (fSlow5 * fRec18[1] - (fRec4[1] + fRec4[2])));
			fRec19[0] = -(fSlow4 * (fSlow5 * fRec19[1] - (fRec12[1] + fRec12[2])));
			float fTemp2 = fRec18[0] + fRec19[0];
			float fTemp3 = fTemp1 + fTemp2;
			fRec20[0] = -(fSlow4 * (fSlow5 * fRec20[1] - (fRec2[1] + fRec2[2])));
			fRec21[0] = -(fSlow4 * (fSlow5 * fRec21[1] - (fRec10[1] + fRec10[2])));
			float fTemp4 = fRec20[0] + fRec21[0];
			fRec22[0] = -(fSlow4 * (fSlow5 * fRec22[1] - (fRec6[1] + fRec6[2])));
			fRec23[0] = -(fSlow4 * (fSlow5 * fRec23[1] - (fRec14[1] + fRec14[2])));
			float fTemp5 = fRec22[0] + fRec23[0];
			float fTemp6 = fTemp4 + fTemp5;
			float fTemp7 = fTemp3 + fTemp6;
			fRec24[0] = -(fSlow4 * (fSlow5 * fRec24[1] - (fRec1[1] + fRec1[2])));
			fRec25[0] = -(fSlow4 * (fSlow5 * fRec25[1] - (fRec9[1] + fRec9[2])));
			float fTemp8 = fRec24[0] + fRec25[0];
			fRec26[0] = -(fSlow4 * (fSlow5 * fRec26[1] - (fRec5[1] + fRec5[2])));
			fRec27[0] = -(fSlow4 * (fSlow5 * fRec27[1] - (fRec13[1] + fRec13[2])));
			float fTemp9 = fRec26[0] + fRec27[0];
			float fTemp10 = fTemp8 + fTemp9;
			fRec28[0] = -(fSlow4 * (fSlow5 * fRec28[1] - (fRec3[1] + fRec3[2])));
			fRec29[0] = -(fSlow4 * (fSlow5 * fRec29[1] - (fRec11[1] + fRec11[2])));
			float fTemp11 = fRec28[0] + fRec29[0];
			fRec30[0] = -(fSlow4 * (fSlow5 * fRec30[1] - (fRec7[1] + fRec7[2])));
			fRec31[0] = -(fSlow4 * (fSlow5 * fRec31[1] - (fRec15[1] + fRec15[2])));
			float fTemp12 = fRec30[0] + fRec31[0];
			float fTemp13 = fTemp11 + fTemp12;
			float fTemp14 = fTemp10 + fTemp13;
			float fTemp15 = fTemp0 + fSlow2 * (fTemp7 + fTemp14);
			fVec0[IOTA0 & 8191] = fTemp15;
			float fTemp16 = ((fRec32[1] != 0.0f) ? (((fRec33[1] > 0.0f) & (fRec33[1] < 1.0f)) ? fRec32[1] : 0.0f) : (((fRec33[1] == 0.0f) & (1949.0f != fRec34[1])) ? 0.0009765625f : (((fRec33[1] == 1.0f) & (1949.0f != fRec35[1])) ? -0.0009765625f : 0.0f)));
			fRec32[0] = fTemp16;
			fRec33[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec33[1] + fTemp16));
			fRec34[0] = (((fRec33[1] >= 1.0f) & (fRec35[1] != 1949.0f)) ? 1949.0f : fRec34[1]);
			fRec35[0] = (((fRec33[1] <= 0.0f) & (fRec34[1] != 1949.0f)) ? 1949.0f : fRec35[1]);
			float fTemp17 = fVec0[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec34[0])))) & 8191];
			fRec0[0] = fTemp17 + fRec33[0] * (fVec0[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec35[0])))) & 8191] - fTemp17);
			float fTemp18 = float(input1[i0]);
			float fTemp19 = fTemp18 + fSlow2 * (fTemp7 - fTemp14);
			fVec1[IOTA0 & 8191] = fTemp19;
			float fTemp20 = ((fRec36[1] != 0.0f) ? (((fRec37[1] > 0.0f) & (fRec37[1] < 1.0f)) ? fRec36[1] : 0.0f) : (((fRec37[1] == 0.0f) & (2081.0f != fRec38[1])) ? 0.0009765625f : (((fRec37[1] == 1.0f) & (2081.0f != fRec39[1])) ? -0.0009765625f : 0.0f)));
			fRec36[0] = fTemp20;
			fRec37[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec37[1] + fTemp20));
			fRec38[0] = (((fRec37[1] >= 1.0f) & (fRec39[1] != 2081.0f)) ? 2081.0f : fRec38[1]);
			fRec39[0] = (((fRec37[1] <= 0.0f) & (fRec38[1] != 2081.0f)) ? 2081.0f : fRec39[1]);
			float fTemp21 = fVec1[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec38[0])))) & 8191];
			fRec1[0] = fTemp21 + fRec37[0] * (fVec1[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec39[0])))) & 8191] - fTemp21);
			float fTemp22 = fTemp3 - fTemp6;
			float fTemp23 = fTemp10 - fTemp13;
			float fTemp24 = fTemp0 + fSlow2 * (fTemp22 + fTemp23);
			fVec2[IOTA0 & 8191] = fTemp24;
			float fTemp25 = ((fRec40[1] != 0.0f) ? (((fRec41[1] > 0.0f) & (fRec41[1] < 1.0f)) ? fRec40[1] : 0.0f) : (((fRec41[1] == 0.0f) & (2209.0f != fRec42[1])) ? 0.0009765625f : (((fRec41[1] == 1.0f) & (2209.0f != fRec43[1])) ? -0.0009765625f : 0.0f)));
			fRec40[0] = fTemp25;
			fRec41[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec41[1] + fTemp25));
			fRec42[0] = (((fRec41[1] >= 1.0f) & (fRec43[1] != 2209.0f)) ? 2209.0f : fRec42[1]);
			fRec43[0] = (((fRec41[1] <= 0.0f) & (fRec42[1] != 2209.0f)) ? 2209.0f : fRec43[1]);
			float fTemp26 = fVec2[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec42[0])))) & 8191];
			fRec2[0] = fTemp26 + fRec41[0] * (fVec2[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec43[0])))) & 8191] - fTemp26);
			float fTemp27 = fTemp18 + fSlow2 * (fTemp22 - fTemp23);
			fVec3[IOTA0 & 8191] = fTemp27;
			float fTemp28 = ((fRec44[1] != 0.0f) ? (((fRec45[1] > 0.0f) & (fRec45[1] < 1.0f)) ? fRec44[1] : 0.0f) : (((fRec45[1] == 0.0f) & (2339.0f != fRec46[1])) ? 0.0009765625f : (((fRec45[1] == 1.0f) & (2339.0f != fRec47[1])) ? -0.0009765625f : 0.0f)));
			fRec44[0] = fTemp28;
			fRec45[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec45[1] + fTemp28));
			fRec46[0] = (((fRec45[1] >= 1.0f) & (fRec47[1] != 2339.0f)) ? 2339.0f : fRec46[1]);
			fRec47[0] = (((fRec45[1] <= 0.0f) & (fRec46[1] != 2339.0f)) ? 2339.0f : fRec47[1]);
			float fTemp29 = fVec3[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec46[0])))) & 8191];
			fRec3[0] = fTemp29 + fRec45[0] * (fVec3[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec47[0])))) & 8191] - fTemp29);
			float fTemp30 = fTemp1 - fTemp2;
			float fTemp31 = fTemp4 - fTemp5;
			float fTemp32 = fTemp30 + fTemp31;
			float fTemp33 = fTemp8 - fTemp9;
			float fTemp34 = fTemp11 - fTemp12;
			float fTemp35 = fTemp33 + fTemp34;
			float fTemp36 = fTemp0 + fSlow2 * (fTemp32 + fTemp35);
			fVec4[IOTA0 & 8191] = fTemp36;
			float fTemp37 = ((fRec48[1] != 0.0f) ? (((fRec49[1] > 0.0f) & (fRec49[1] < 1.0f)) ? fRec48[1] : 0.0f) : (((fRec49[1] == 0.0f) & (2447.0f != fRec50[1])) ? 0.0009765625f : (((fRec49[1] == 1.0f) & (2447.0f != fRec51[1])) ? -0.0009765625f : 0.0f)));
			fRec48[0] = fTemp37;
			fRec49[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec49[1] + fTemp37));
			fRec50[0] = (((fRec49[1] >= 1.0f) & (fRec51[1] != 2447.0f)) ? 2447.0f : fRec50[1]);
			fRec51[0] = (((fRec49[1] <= 0.0f) & (fRec50[1] != 2447.0f)) ? 2447.0f : fRec51[1]);
			float fTemp38 = fVec4[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec50[0])))) & 8191];
			fRec4[0] = fTemp38 + fRec49[0] * (fVec4[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec51[0])))) & 8191] - fTemp38);
			float fTemp39 = fTemp18 + fSlow2 * (fTemp32 - fTemp35);
			fVec5[IOTA0 & 8191] = fTemp39;
			float fTemp40 = ((fRec52[1] != 0.0f) ? (((fRec53[1] > 0.0f) & (fRec53[1] < 1.0f)) ? fRec52[1] : 0.0f) : (((fRec53[1] == 0.0f) & (2617.0f != fRec54[1])) ? 0.0009765625f : (((fRec53[1] == 1.0f) & (2617.0f != fRec55[1])) ? -0.0009765625f : 0.0f)));
			fRec52[0] = fTemp40;
			fRec53[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec53[1] + fTemp40));
			fRec54[0] = (((fRec53[1] >= 1.0f) & (fRec55[1] != 2617.0f)) ? 2617.0f : fRec54[1]);
			fRec55[0] = (((fRec53[1] <= 0.0f) & (fRec54[1] != 2617.0f)) ? 2617.0f : fRec55[1]);
			float fTemp41 = fVec5[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec54[0])))) & 8191];
			fRec5[0] = fTemp41 + fRec53[0] * (fVec5[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec55[0])))) & 8191] - fTemp41);
			float fTemp42 = fTemp30 - fTemp31;
			float fTemp43 = fTemp33 - fTemp34;
			float fTemp44 = fTemp0 + fSlow2 * (fTemp42 + fTemp43);
			fVec6[IOTA0 & 8191] = fTemp44;
			float fTemp45 = ((fRec56[1] != 0.0f) ? (((fRec57[1] > 0.0f) & (fRec57[1] < 1.0f)) ? fRec56[1] : 0.0f) : (((fRec57[1] == 0.0f) & (2719.0f != fRec58[1])) ? 0.0009765625f : (((fRec57[1] == 1.0f) & (2719.0f != fRec59[1])) ? -0.0009765625f : 0.0f)));
			fRec56[0] = fTemp45;
			fRec57[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec57[1] + fTemp45));
			fRec58[0] = (((fRec57[1] >= 1.0f) & (fRec59[1] != 2719.0f)) ? 2719.0f : fRec58[1]);
			fRec59[0] = (((fRec57[1] <= 0.0f) & (fRec58[1] != 2719.0f)) ? 2719.0f : fRec59[1]);
			float fTemp46 = fVec6[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec58[0])))) & 8191];
			fRec6[0] = fTemp46 + fRec57[0] * (fVec6[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec59[0])))) & 8191] - fTemp46);
			float fTemp47 = fTemp18 + fSlow2 * (fTemp42 - fTemp43);
			fVec7[IOTA0 & 8191] = fTemp47;
			float fTemp48 = ((fRec60[1] != 0.0f) ? (((fRec61[1] > 0.0f) & (fRec61[1] < 1.0f)) ? fRec60[1] : 0.0f) : (((fRec61[1] == 0.0f) & (2843.0f != fRec62[1])) ? 0.0009765625f : (((fRec61[1] == 1.0f) & (2843.0f != fRec63[1])) ? -0.0009765625f : 0.0f)));
			fRec60[0] = fTemp48;
			fRec61[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec61[1] + fTemp48));
			fRec62[0] = (((fRec61[1] >= 1.0f) & (fRec63[1] != 2843.0f)) ? 2843.0f : fRec62[1]);
			fRec63[0] = (((fRec61[1] <= 0.0f) & (fRec62[1] != 2843.0f)) ? 2843.0f : fRec63[1]);
			float fTemp49 = fVec7[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec62[0])))) & 8191];
			fRec7[0] = fTemp49 + fRec61[0] * (fVec7[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec63[0])))) & 8191] - fTemp49);
			float fTemp50 = fRec16[0] - fRec17[0];
			float fTemp51 = fRec18[0] - fRec19[0];
			float fTemp52 = fTemp50 + fTemp51;
			float fTemp53 = fRec20[0] - fRec21[0];
			float fTemp54 = fRec22[0] - fRec23[0];
			float fTemp55 = fTemp53 + fTemp54;
			float fTemp56 = fTemp52 + fTemp55;
			float fTemp57 = fRec24[0] - fRec25[0];
			float fTemp58 = fRec26[0] - fRec27[0];
			float fTemp59 = fTemp57 + fTemp58;
			float fTemp60 = fRec28[0] - fRec29[0];
			float fTemp61 = fRec30[0] - fRec31[0];
			float fTemp62 = fTemp60 + fTemp61;
			float fTemp63 = fTemp59 + fTemp62;
			float fTemp64 = fTemp0 + fSlow2 * (fTemp56 + fTemp63);
			fVec8[IOTA0 & 8191] = fTemp64;
			float fTemp65 = ((fRec64[1] != 0.0f) ? (((fRec65[1] > 0.0f) & (fRec65[1] < 1.0f)) ? fRec64[1] : 0.0f) : (((fRec65[1] == 0.0f) & (2999.0f != fRec66[1])) ? 0.0009765625f : (((fRec65[1] == 1.0f) & (2999.0f != fRec67[1])) ? -0.0009765625f : 0.0f)));
			fRec64[0] = fTemp65;
			fRec65[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec65[1] + fTemp65));
			fRec66[0] = (((fRec65[1] >= 1.0f) & (fRec67[1] != 2999.0f)) ? 2999.0f : fRec66[1]);
			fRec67[0] = (((fRec65[1] <= 0.0f) & (fRec66[1] != 2999.0f)) ? 2999.0f : fRec67[1]);
			float fTemp66 = fVec8[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec66[0])))) & 8191];
			fRec8[0] = fTemp66 + fRec65[0] * (fVec8[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec67[0])))) & 8191] - fTemp66);
			float fTemp67 = fTemp18 + fSlow2 * (fTemp56 - fTemp63);
			fVec9[IOTA0 & 8191] = fTemp67;
			float fTemp68 = ((fRec68[1] != 0.0f) ? (((fRec69[1] > 0.0f) & (fRec69[1] < 1.0f)) ? fRec68[1] : 0.0f) : (((fRec69[1] == 0.0f) & (3163.0f != fRec70[1])) ? 0.0009765625f : (((fRec69[1] == 1.0f) & (3163.0f != fRec71[1])) ? -0.0009765625f : 0.0f)));
			fRec68[0] = fTemp68;
			fRec69[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec69[1] + fTemp68));
			fRec70[0] = (((fRec69[1] >= 1.0f) & (fRec71[1] != 3163.0f)) ? 3163.0f : fRec70[1]);
			fRec71[0] = (((fRec69[1] <= 0.0f) & (fRec70[1] != 3163.0f)) ? 3163.0f : fRec71[1]);
			float fTemp69 = fVec9[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec70[0])))) & 8191];
			fRec9[0] = fTemp69 + fRec69[0] * (fVec9[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec71[0])))) & 8191] - fTemp69);
			float fTemp70 = fTemp52 - fTemp55;
			float fTemp71 = fTemp59 - fTemp62;
			float fTemp72 = fTemp0 + fSlow2 * (fTemp70 + fTemp71);
			fVec10[IOTA0 & 8191] = fTemp72;
			float fTemp73 = ((fRec72[1] != 0.0f) ? (((fRec73[1] > 0.0f) & (fRec73[1] < 1.0f)) ? fRec72[1] : 0.0f) : (((fRec73[1] == 0.0f) & (3301.0f != fRec74[1])) ? 0.0009765625f : (((fRec73[1] == 1.0f) & (3301.0f != fRec75[1])) ? -0.0009765625f : 0.0f)));
			fRec72[0] = fTemp73;
			fRec73[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec73[1] + fTemp73));
			fRec74[0] = (((fRec73[1] >= 1.0f) & (fRec75[1] != 3301.0f)) ? 3301.0f : fRec74[1]);
			fRec75[0] = (((fRec73[1] <= 0.0f) & (fRec74[1] != 3301.0f)) ? 3301.0f : fRec75[1]);
			float fTemp74 = fVec10[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec74[0])))) & 8191];
			fRec10[0] = fTemp74 + fRec73[0] * (fVec10[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec75[0])))) & 8191] - fTemp74);
			float fTemp75 = fTemp18 + fSlow2 * (fTemp70 - fTemp71);
			fVec11[IOTA0 & 8191] = fTemp75;
			float fTemp76 = ((fRec76[1] != 0.0f) ? (((fRec77[1] > 0.0f) & (fRec77[1] < 1.0f)) ? fRec76[1] : 0.0f) : (((fRec77[1] == 0.0f) & (3433.0f != fRec78[1])) ? 0.0009765625f : (((fRec77[1] == 1.0f) & (3433.0f != fRec79[1])) ? -0.0009765625f : 0.0f)));
			fRec76[0] = fTemp76;
			fRec77[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec77[1] + fTemp76));
			fRec78[0] = (((fRec77[1] >= 1.0f) & (fRec79[1] != 3433.0f)) ? 3433.0f : fRec78[1]);
			fRec79[0] = (((fRec77[1] <= 0.0f) & (fRec78[1] != 3433.0f)) ? 3433.0f : fRec79[1]);
			float fTemp77 = fVec11[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec78[0])))) & 8191];
			fRec11[0] = fTemp77 + fRec77[0] * (fVec11[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec79[0])))) & 8191] - fTemp77);
			float fTemp78 = fTemp50 - fTemp51;
			float fTemp79 = fTemp53 - fTemp54;
			float fTemp80 = fTemp78 + fTemp79;
			float fTemp81 = fTemp57 - fTemp58;
			float fTemp82 = fTemp60 - fTemp61;
			float fTemp83 = fTemp81 + fTemp82;
			float fTemp84 = fTemp0 + fSlow2 * (fTemp80 + fTemp83);
			fVec12[IOTA0 & 8191] = fTemp84;
			float fTemp85 = ((fRec80[1] != 0.0f) ? (((fRec81[1] > 0.0f) & (fRec81[1] < 1.0f)) ? fRec80[1] : 0.0f) : (((fRec81[1] == 0.0f) & (3547.0f != fRec82[1])) ? 0.0009765625f : (((fRec81[1] == 1.0f) & (3547.0f != fRec83[1])) ? -0.0009765625f : 0.0f)));
			fRec80[0] = fTemp85;
			fRec81[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec81[1] + fTemp85));
			fRec82[0] = (((fRec81[1] >= 1.0f) & (fRec83[1] != 3547.0f)) ? 3547.0f : fRec82[1]);
			fRec83[0] = (((fRec81[1] <= 0.0f) & (fRec82[1] != 3547.0f)) ? 3547.0f : fRec83[1]);
			float fTemp86 = fVec12[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec82[0])))) & 8191];
			fRec12[0] = fTemp86 + fRec81[0] * (fVec12[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec83[0])))) & 8191] - fTemp86);
			float fTemp87 = fTemp18 + fSlow2 * (fTemp80 - fTemp83);
			fVec13[IOTA0 & 8191] = fTemp87;
			float fTemp88 = ((fRec84[1] != 0.0f) ? (((fRec85[1] > 0.0f) & (fRec85[1] < 1.0f)) ? fRec84[1] : 0.0f) : (((fRec85[1] == 0.0f) & (3677.0f != fRec86[1])) ? 0.0009765625f : (((fRec85[1] == 1.0f) & (3677.0f != fRec87[1])) ? -0.0009765625f : 0.0f)));
			fRec84[0] = fTemp88;
			fRec85[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec85[1] + fTemp88));
			fRec86[0] = (((fRec85[1] >= 1.0f) & (fRec87[1] != 3677.0f)) ? 3677.0f : fRec86[1]);
			fRec87[0] = (((fRec85[1] <= 0.0f) & (fRec86[1] != 3677.0f)) ? 3677.0f : fRec87[1]);
			float fTemp89 = fVec13[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec86[0])))) & 8191];
			fRec13[0] = fTemp89 + fRec85[0] * (fVec13[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec87[0])))) & 8191] - fTemp89);
			float fTemp90 = fTemp78 - fTemp79;
			float fTemp91 = fTemp81 - fTemp82;
			float fTemp92 = fTemp0 + fSlow2 * (fTemp90 + fTemp91);
			fVec14[IOTA0 & 8191] = fTemp92;
			float fTemp93 = ((fRec88[1] != 0.0f) ? (((fRec89[1] > 0.0f) & (fRec89[1] < 1.0f)) ? fRec88[1] : 0.0f) : (((fRec89[1] == 0.0f) & (3823.0f != fRec90[1])) ? 0.0009765625f : (((fRec89[1] == 1.0f) & (3823.0f != fRec91[1])) ? -0.0009765625f : 0.0f)));
			fRec88[0] = fTemp93;
			fRec89[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec89[1] + fTemp93));
			fRec90[0] = (((fRec89[1] >= 1.0f) & (fRec91[1] != 3823.0f)) ? 3823.0f : fRec90[1]);
			fRec91[0] = (((fRec89[1] <= 0.0f) & (fRec90[1] != 3823.0f)) ? 3823.0f : fRec91[1]);
			float fTemp94 = fVec14[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec90[0])))) & 8191];
			fRec14[0] = fTemp94 + fRec89[0] * (fVec14[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec91[0])))) & 8191] - fTemp94);
			float fTemp95 = fTemp18 + fSlow2 * (fTemp90 - fTemp91);
			fVec15[IOTA0 & 8191] = fTemp95;
			float fTemp96 = ((fRec92[1] != 0.0f) ? (((fRec93[1] > 0.0f) & (fRec93[1] < 1.0f)) ? fRec92[1] : 0.0f) : (((fRec93[1] == 0.0f) & (3967.0f != fRec94[1])) ? 0.0009765625f : (((fRec93[1] == 1.0f) & (3967.0f != fRec95[1])) ? -0.0009765625f : 0.0f)));
			fRec92[0] = fTemp96;
			fRec93[0] = std::max<float>(0.0f, std::min<float>(1.0f, fRec93[1] + fTemp96));
			fRec94[0] = (((fRec93[1] >= 1.0f) & (fRec95[1] != 3967.0f)) ? 3967.0f : fRec94[1]);
			fRec95[0] = (((fRec93[1] <= 0.0f) & (fRec94[1] != 3967.0f)) ? 3967.0f : fRec95[1]);
			float fTemp97 = fVec15[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec94[0])))) & 8191];
			fRec15[0] = fTemp97 + fRec93[0] * (fVec15[(IOTA0 - int(std::min<float>(4096.0f, std::max<float>(0.0f, fRec95[0])))) & 8191] - fTemp97);
			float fTemp98 = fSlow6 * fTemp0;
			output0[i0] = FAUSTFLOAT(0.70710677f * (fSlow1 * fRec0[0] + fTemp98 + fTemp98 + fSlow1 * fRec2[0] + fTemp98 + fSlow1 * fRec4[0] + fTemp98 + fSlow1 * fRec6[0] + fTemp98 + fSlow1 * fRec8[0] + fTemp98 + fSlow1 * fRec10[0] + fTemp98 + fSlow1 * fRec12[0] + fTemp98 + fSlow1 * fRec14[0]));
			float fTemp99 = fSlow6 * fTemp18;
			output1[i0] = FAUSTFLOAT(0.70710677f * (fSlow1 * fRec1[0] + fTemp99 + fTemp99 + fSlow1 * fRec3[0] + fTemp99 + fSlow1 * fRec5[0] + fTemp99 + fSlow1 * fRec7[0] + fTemp99 + fSlow1 * fRec9[0] + fTemp99 + fSlow1 * fRec11[0] + fTemp99 + fSlow1 * fRec13[0] + fTemp99 + fSlow1 * fRec15[0]));
			fRec16[1] = fRec16[0];
			fRec17[1] = fRec17[0];
			fRec18[1] = fRec18[0];
			fRec19[1] = fRec19[0];
			fRec20[1] = fRec20[0];
			fRec21[1] = fRec21[0];
			fRec22[1] = fRec22[0];
			fRec23[1] = fRec23[0];
			fRec24[1] = fRec24[0];
			fRec25[1] = fRec25[0];
			fRec26[1] = fRec26[0];
			fRec27[1] = fRec27[0];
			fRec28[1] = fRec28[0];
			fRec29[1] = fRec29[0];
			fRec30[1] = fRec30[0];
			fRec31[1] = fRec31[0];
			IOTA0 = IOTA0 + 1;
			fRec32[1] = fRec32[0];
			fRec33[1] = fRec33[0];
			fRec34[1] = fRec34[0];
			fRec35[1] = fRec35[0];
			fRec0[2] = fRec0[1];
			fRec0[1] = fRec0[0];
			fRec36[1] = fRec36[0];
			fRec37[1] = fRec37[0];
			fRec38[1] = fRec38[0];
			fRec39[1] = fRec39[0];
			fRec1[2] = fRec1[1];
			fRec1[1] = fRec1[0];
			fRec40[1] = fRec40[0];
			fRec41[1] = fRec41[0];
			fRec42[1] = fRec42[0];
			fRec43[1] = fRec43[0];
			fRec2[2] = fRec2[1];
			fRec2[1] = fRec2[0];
			fRec44[1] = fRec44[0];
			fRec45[1] = fRec45[0];
			fRec46[1] = fRec46[0];
			fRec47[1] = fRec47[0];
			fRec3[2] = fRec3[1];
			fRec3[1] = fRec3[0];
			fRec48[1] = fRec48[0];
			fRec49[1] = fRec49[0];
			fRec50[1] = fRec50[0];
			fRec51[1] = fRec51[0];
			fRec4[2] = fRec4[1];
			fRec4[1] = fRec4[0];
			fRec52[1] = fRec52[0];
			fRec53[1] = fRec53[0];
			fRec54[1] = fRec54[0];
			fRec55[1] = fRec55[0];
			fRec5[2] = fRec5[1];
			fRec5[1] = fRec5[0];
			fRec56[1] = fRec56[0];
			fRec57[1] = fRec57[0];
			fRec58[1] = fRec58[0];
			fRec59[1] = fRec59[0];
			fRec6[2] = fRec6[1];
			fRec6[1] = fRec6[0];
			fRec60[1] = fRec60[0];
			fRec61[1] = fRec61[0];
			fRec62[1] = fRec62[0];
			fRec63[1] = fRec63[0];
			fRec7[2] = fRec7[1];
			fRec7[1] = fRec7[0];
			fRec64[1] = fRec64[0];
			fRec65[1] = fRec65[0];
			fRec66[1] = fRec66[0];
			fRec67[1] = fRec67[0];
			fRec8[2] = fRec8[1];
			fRec8[1] = fRec8[0];
			fRec68[1] = fRec68[0];
			fRec69[1] = fRec69[0];
			fRec70[1] = fRec70[0];
			fRec71[1] = fRec71[0];
			fRec9[2] = fRec9[1];
			fRec9[1] = fRec9[0];
			fRec72[1] = fRec72[0];
			fRec73[1] = fRec73[0];
			fRec74[1] = fRec74[0];
			fRec75[1] = fRec75[0];
			fRec10[2] = fRec10[1];
			fRec10[1] = fRec10[0];
			fRec76[1] = fRec76[0];
			fRec77[1] = fRec77[0];
			fRec78[1] = fRec78[0];
			fRec79[1] = fRec79[0];
			fRec11[2] = fRec11[1];
			fRec11[1] = fRec11[0];
			fRec80[1] = fRec80[0];
			fRec81[1] = fRec81[0];
			fRec82[1] = fRec82[0];
			fRec83[1] = fRec83[0];
			fRec12[2] = fRec12[1];
			fRec12[1] = fRec12[0];
			fRec84[1] = fRec84[0];
			fRec85[1] = fRec85[0];
			fRec86[1] = fRec86[0];
			fRec87[1] = fRec87[0];
			fRec13[2] = fRec13[1];
			fRec13[1] = fRec13[0];
			fRec88[1] = fRec88[0];
			fRec89[1] = fRec89[0];
			fRec90[1] = fRec90[0];
			fRec91[1] = fRec91[0];
			fRec14[2] = fRec14[1];
			fRec14[1] = fRec14[0];
			fRec92[1] = fRec92[0];
			fRec93[1] = fRec93[0];
			fRec94[1] = fRec94[0];
			fRec95[1] = fRec95[0];
			fRec15[2] = fRec15[1];
			fRec15[1] = fRec15[0];
		}
	}

};

#undef private
#undef virtual
#undef mydsp

/*
 * ChucK glue code
 */
static t_CKUINT AKJRev_offset_data = 0;
static int g_sr = 44100;
static int g_nChans = 1;

CK_DLL_CTOR(AKJRev_ctor)
{
    // return data to be used later
    AKJRev *d = new AKJRev;
    OBJ_MEMBER_UINT(SELF, AKJRev_offset_data) = (t_CKUINT)d;
    d->init(g_sr);
    d->ck_frame_in = new SAMPLE*[g_nChans];
    d->ck_frame_out = new SAMPLE*[g_nChans];
}

CK_DLL_DTOR(AKJRev_dtor)
{
    AKJRev *d = (AKJRev*)OBJ_MEMBER_UINT(SELF, AKJRev_offset_data);

    delete[] d->ck_frame_in;
    delete[] d->ck_frame_out;
    
    delete d;
    
    OBJ_MEMBER_UINT(SELF, AKJRev_offset_data) = 0;
}

// mono tick
CK_DLL_TICK(AKJRev_tick)
{
    AKJRev *d = (AKJRev*)OBJ_MEMBER_UINT(SELF, AKJRev_offset_data);
    
    d->ck_frame_in[0] = &in;
    d->ck_frame_out[0] = out;

    d->compute(1, d->ck_frame_in, d->ck_frame_out);
    
    return TRUE;
}

// multichannel tick
CK_DLL_TICKF(AKJRev_tickf)
{
    AKJRev *d = (AKJRev*)OBJ_MEMBER_UINT(SELF, AKJRev_offset_data);
    
    for(int f = 0; f < nframes; f++)
    {
        // fake-deinterleave
        for(int c = 0; c < g_nChans; c++)
        {
            d->ck_frame_in[c] = &in[f*g_nChans+c];
            d->ck_frame_out[c] = &out[f*g_nChans+c];
        }
        
        d->compute(1, d->ck_frame_in, d->ck_frame_out);
    }
    
    return TRUE;
}

CK_DLL_MFUN(AKJRev_ctrl_fEntry2)
{
    AKJRev *d = (AKJRev*)OBJ_MEMBER_UINT(SELF, AKJRev_offset_data);
    d->fEntry2 = (SAMPLE)GET_CK_FLOAT(ARGS);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry2);
}

CK_DLL_MFUN(AKJRev_cget_fEntry2)
{
    AKJRev *d = (AKJRev*)OBJ_MEMBER_UINT(SELF, AKJRev_offset_data);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry2);
}


CK_DLL_MFUN(AKJRev_ctrl_fEntry1)
{
    AKJRev *d = (AKJRev*)OBJ_MEMBER_UINT(SELF, AKJRev_offset_data);
    d->fEntry1 = (SAMPLE)GET_CK_FLOAT(ARGS);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry1);
}

CK_DLL_MFUN(AKJRev_cget_fEntry1)
{
    AKJRev *d = (AKJRev*)OBJ_MEMBER_UINT(SELF, AKJRev_offset_data);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry1);
}


CK_DLL_MFUN(AKJRev_ctrl_fEntry0)
{
    AKJRev *d = (AKJRev*)OBJ_MEMBER_UINT(SELF, AKJRev_offset_data);
    d->fEntry0 = (SAMPLE)GET_CK_FLOAT(ARGS);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry0);
}

CK_DLL_MFUN(AKJRev_cget_fEntry0)
{
    AKJRev *d = (AKJRev*)OBJ_MEMBER_UINT(SELF, AKJRev_offset_data);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry0);
}




CK_DLL_QUERY(AKJRev_query)
{
    //g_sr = QUERY->srate;
    //g_sr = QUERY->srate(); // changed by TJ on 4/2/25, to address error that appears when trying to use the faust2ck utility

	AKJRev temp; // needed to get IO channel count

    QUERY->setname(QUERY, "AKJRev");
    
    QUERY->begin_class(QUERY, "AKJRev", "UGen");
    QUERY->doc_class(QUERY, "AKJRev");
    QUERY->add_ex(QUERY, "AKJRev-test.ck");
    
    QUERY->add_ctor(QUERY, AKJRev_ctor);
    QUERY->add_dtor(QUERY, AKJRev_dtor);
    
    g_nChans = std::max(temp.getNumInputs(), temp.getNumOutputs());
    
    if(g_nChans == 1)
        QUERY->add_ugen_func(QUERY, AKJRev_tick, NULL, g_nChans, g_nChans);
    else
        QUERY->add_ugen_funcf(QUERY, AKJRev_tickf, NULL, g_nChans, g_nChans);

    // add member variable
    AKJRev_offset_data = QUERY->add_mvar( QUERY, "int", "@AKJRev_data", FALSE );
    if( AKJRev_offset_data == CK_INVALID_OFFSET ) goto error;

    
    QUERY->add_mfun( QUERY, AKJRev_cget_fEntry2 , "float", "cutoff" );
    
    QUERY->add_mfun( QUERY, AKJRev_ctrl_fEntry2 , "float", "cutoff" );
    QUERY->add_arg( QUERY, "float", "cutoff" );
    QUERY->doc_func(QUERY, "float value controls cutoff" );
    

    QUERY->add_mfun( QUERY, AKJRev_cget_fEntry1 , "float", "feedback" );
    
    QUERY->add_mfun( QUERY, AKJRev_ctrl_fEntry1 , "float", "feedback" );
    QUERY->add_arg( QUERY, "float", "feedback" );
    QUERY->doc_func(QUERY, "float value controls feedback" );
    

    QUERY->add_mfun( QUERY, AKJRev_cget_fEntry0 , "float", "wet" );
    
    QUERY->add_mfun( QUERY, AKJRev_ctrl_fEntry0 , "float", "wet" );
    QUERY->add_arg( QUERY, "float", "wet" );
    QUERY->doc_func(QUERY, "float value controls wet" );
    


    // end import
	QUERY->end_class(QUERY);
	
    return TRUE;

error:
    // end import
	QUERY->end_class(QUERY);

    return FALSE;
}

#endif
