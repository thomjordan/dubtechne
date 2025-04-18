/* ------------------------------------------------------------
author: "Thom Jordan"
copyright: "Copyright (C) 2025 Thom Jordan <thomjordan@gatech.edu>"
license: "MIT license"
name: "SawDL"
version: "1.0"
Code generated with Faust 2.80.0 (https://faust.grame.fr)
Compilation options: -a .faust2ck_tmp/SawDL.dsp-wrapper.cpp -lang cpp -ct 1 -es 1 -mcd 16 -mdd 1024 -mdy 33 -single -ftz 0
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
#define mydsp SawDL

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

static float mydsp_faustpower2_f(float value) {
	return value * value;
}
static float mydsp_faustpower3_f(float value) {
	return value * value * value;
}
static float mydsp_faustpower4_f(float value) {
	return value * value * value * value;
}

class mydsp : public dsp {
	
 private:
	
	int fSampleRate;
	float fConst0;
	float fConst1;
	FAUSTFLOAT fEntry0;
	FAUSTFLOAT fEntry1;
	float fConst2;
	FAUSTFLOAT fEntry2;
	FAUSTFLOAT fEntry3;
	float fRec7[2];
	float fRec5[2];
	FAUSTFLOAT fEntry4;
	float fRec0[2];
	float fRec1[2];
	float fRec3[2];
	float fRec4[2];
	
 public:
	mydsp() {
	}
	
	void metadata(Meta* m) { 
		m->declare("about", "SawDL is a single oscillator sawtooth wave with built-in diodeLadder LP filter. It requires an envelope-generator as input, or else no sound will be heard. This is made for working well with EnvGen as input.");
		m->declare("author", "Thom Jordan");
		m->declare("basics.lib/name", "Faust Basic Element Library");
		m->declare("basics.lib/version", "1.21.0");
		m->declare("compile_options", "-a .faust2ck_tmp/SawDL.dsp-wrapper.cpp -lang cpp -ct 1 -es 1 -mcd 16 -mdd 1024 -mdy 33 -single -ftz 0");
		m->declare("copyright", "Copyright (C) 2025 Thom Jordan <thomjordan@gatech.edu>");
		m->declare("filename", "SawDL.dsp");
		m->declare("license", "MIT license");
		m->declare("maths.lib/author", "GRAME");
		m->declare("maths.lib/copyright", "GRAME");
		m->declare("maths.lib/license", "LGPL with exception");
		m->declare("maths.lib/name", "Faust Math Library");
		m->declare("maths.lib/version", "2.8.1");
		m->declare("misceffects.lib/cubicnl:author", "Julius O. Smith III");
		m->declare("misceffects.lib/cubicnl:license", "STK-4.3");
		m->declare("misceffects.lib/name", "Misc Effects Library");
		m->declare("misceffects.lib/version", "2.5.1");
		m->declare("name", "SawDL");
		m->declare("oscillators.lib/name", "Faust Oscillator Library");
		m->declare("oscillators.lib/saw2ptr:author", "Julius O. Smith III");
		m->declare("oscillators.lib/saw2ptr:license", "STK-4.3");
		m->declare("oscillators.lib/version", "1.6.0");
		m->declare("platform.lib/name", "Generic Platform Library");
		m->declare("platform.lib/version", "1.3.0");
		m->declare("signals.lib/name", "Faust Signal Routing Library");
		m->declare("signals.lib/version", "1.6.0");
		m->declare("vaeffects.lib/diodeLadder:author", "Eric Tarr");
		m->declare("vaeffects.lib/diodeLadder:license", "MIT-style STK-4.3 license");
		m->declare("vaeffects.lib/name", "Faust Virtual Analog Filter Effect Library");
		m->declare("vaeffects.lib/version", "1.3.0");
		m->declare("version", "1.0");
	}

	virtual int getNumInputs() {
		return 1;
	}
	virtual int getNumOutputs() {
		return 2;
	}
	
	static void classInit(int sample_rate) {
	}
	
	virtual void instanceConstants(int sample_rate) {
		fSampleRate = sample_rate;
		fConst0 = std::min<float>(1.92e+05f, std::max<float>(1.0f, float(fSampleRate)));
		fConst1 = 6.2831855f / fConst0;
		fConst2 = 1.0f / fConst0;
	}
	
	virtual void instanceResetUserInterface() {
		fEntry0 = FAUSTFLOAT(0.78f);
		fEntry1 = FAUSTFLOAT(0.1f);
		fEntry2 = FAUSTFLOAT(54.0f);
		fEntry3 = FAUSTFLOAT(8.88f);
		fEntry4 = FAUSTFLOAT(0.52f);
	}
	
	virtual void instanceClear() {
		for (int l0 = 0; l0 < 2; l0 = l0 + 1) {
			fRec7[l0] = 0.0f;
		}
		for (int l1 = 0; l1 < 2; l1 = l1 + 1) {
			fRec5[l1] = 0.0f;
		}
		for (int l2 = 0; l2 < 2; l2 = l2 + 1) {
			fRec0[l2] = 0.0f;
		}
		for (int l3 = 0; l3 < 2; l3 = l3 + 1) {
			fRec1[l3] = 0.0f;
		}
		for (int l4 = 0; l4 < 2; l4 = l4 + 1) {
			fRec3[l4] = 0.0f;
		}
		for (int l5 = 0; l5 < 2; l5 = l5 + 1) {
			fRec4[l5] = 0.0f;
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
		ui_interface->openVerticalBox("SawDL");
		ui_interface->addNumEntry("cutoff", &fEntry0, FAUSTFLOAT(0.78f), FAUSTFLOAT(0.0f), FAUSTFLOAT(1.5f), FAUSTFLOAT(1e-05f));
		ui_interface->addNumEntry("freq", &fEntry2, FAUSTFLOAT(54.0f), FAUSTFLOAT(5e+01f), FAUSTFLOAT(5e+03f), FAUSTFLOAT(1e-09f));
		ui_interface->addNumEntry("gain", &fEntry1, FAUSTFLOAT(0.1f), FAUSTFLOAT(0.0f), FAUSTFLOAT(1.0f), FAUSTFLOAT(0.001f));
		ui_interface->addNumEntry("glide", &fEntry3, FAUSTFLOAT(8.88f), FAUSTFLOAT(0.0f), FAUSTFLOAT(5e+02f), FAUSTFLOAT(0.01f));
		ui_interface->addNumEntry("reson", &fEntry4, FAUSTFLOAT(0.52f), FAUSTFLOAT(0.0f), FAUSTFLOAT(1.0f), FAUSTFLOAT(0.001f));
		ui_interface->closeBox();
	}
	
	virtual void compute(int count, FAUSTFLOAT** RESTRICT inputs, FAUSTFLOAT** RESTRICT outputs) {
		FAUSTFLOAT* input0 = inputs[0];
		FAUSTFLOAT* output0 = outputs[0];
		FAUSTFLOAT* output1 = outputs[1];
		float fSlow0 = float(fEntry0);
		float fSlow1 = 6.0f * fSlow0;
		float fSlow2 = 1e+02f * float(fEntry1);
		float fSlow3 = 0.001f * float(fEntry3);
		int iSlow4 = std::fabs(fSlow3) < 1.1920929e-07f;
		float fSlow5 = ((iSlow4) ? 0.0f : std::exp(-(fConst2 / ((iSlow4) ? 1.0f : fSlow3))));
		float fSlow6 = float(fEntry2) * (1.0f - fSlow5);
		float fSlow7 = 25.0f * float(fEntry4) + -0.70710677f;
		float fSlow8 = 2.0f * fSlow0;
		float fSlow9 = 0.0051455377f * fSlow7;
		for (int i0 = 0; i0 < count; i0 = i0 + 1) {
			float fTemp0 = float(input0[i0]);
			float fTemp1 = std::tan(fConst1 * std::pow(1e+01f, fSlow1 * fTemp0 + 1.0f));
			fRec7[0] = fSlow6 + fSlow5 * fRec7[1];
			float fTemp2 = std::max<float>(1.1920929e-07f, std::fabs(fRec7[0]));
			float fTemp3 = fRec5[1] + fConst2 * fTemp2;
			float fTemp4 = fTemp3 + -1.0f;
			int iTemp5 = fTemp4 < 0.0f;
			fRec5[0] = ((iTemp5) ? fTemp3 : fTemp4);
			float fRec6 = ((iTemp5) ? fTemp3 : fTemp3 + (1.0f - fConst0 / fTemp2) * fTemp4);
			float fTemp6 = std::max<float>(-1.0f, std::min<float>(1.0f, fSlow2 * fTemp0 * (2.0f * fRec6 + -1.0f)));
			float fTemp7 = 17.0f - 9.7f * std::pow(fSlow8 * fTemp0, 1e+01f);
			float fTemp8 = fTemp1 + 1.0f;
			float fTemp9 = 0.5f * (fRec0[1] * fTemp1 / fTemp8) + fRec1[1];
			float fTemp10 = fTemp1 * (1.0f - 0.25f * (fTemp1 / fTemp8)) + 1.0f;
			float fTemp11 = fTemp1 * fTemp9 / fTemp10;
			float fTemp12 = 0.5f * fTemp11;
			float fTemp13 = fTemp12 + fRec3[1];
			float fTemp14 = fTemp1 * (1.0f - 0.25f * (fTemp1 / fTemp10)) + 1.0f;
			float fTemp15 = fTemp1 * fTemp13 / fTemp14;
			float fTemp16 = fTemp15 + fRec4[1];
			float fTemp17 = fTemp10 * fTemp14;
			float fTemp18 = fTemp1 * (1.0f - 0.5f * (fTemp1 / fTemp14)) + 1.0f;
			float fTemp19 = mydsp_faustpower2_f(fTemp1);
			float fTemp20 = fTemp8 * fTemp10;
			float fTemp21 = fTemp1 * ((1.5f * fTemp6 * (1.0f - 0.33333334f * mydsp_faustpower2_f(fTemp6)) - fSlow7 * (fTemp7 * (0.0411643f * fRec0[1] + 0.02058215f * fTemp11 + 0.02058215f * fTemp15 + 0.0051455377f * (mydsp_faustpower3_f(fTemp1) * fTemp16 / (fTemp17 * fTemp18))) / fTemp8)) * (0.5f * (fTemp19 / (fTemp14 * fTemp18)) + 1.0f) / (fSlow9 * (mydsp_faustpower4_f(fTemp1) * fTemp7 / (fTemp20 * fTemp14 * fTemp18)) + 1.0f) + (fTemp13 + 0.5f * (fTemp1 * fTemp16 / fTemp18)) / fTemp14 - fRec4[1]) / fTemp8;
			float fTemp22 = fTemp1 * (0.5f * ((fRec4[1] + fTemp21) * (0.25f * (fTemp19 / fTemp17) + 1.0f) + (fTemp9 + 0.5f * fTemp15) / fTemp10) - fRec3[1]) / fTemp8;
			float fTemp23 = fTemp1 * (0.5f * ((fRec3[1] + fTemp22) * (0.25f * (fTemp19 / fTemp20) + 1.0f) + (fRec0[1] + fTemp12) / fTemp8) - fRec1[1]) / fTemp8;
			float fTemp24 = fTemp1 * (0.5f * (fRec1[1] + fTemp23) - fRec0[1]) / fTemp8;
			fRec0[0] = fRec0[1] + 2.0f * fTemp24;
			fRec1[0] = fRec1[1] + 2.0f * fTemp23;
			float fRec2 = fRec0[1] + fTemp24;
			fRec3[0] = fRec3[1] + 2.0f * fTemp22;
			fRec4[0] = fRec4[1] + 2.0f * fTemp21;
			output0[i0] = FAUSTFLOAT(fRec2);
			output1[i0] = FAUSTFLOAT(fRec2);
			fRec7[1] = fRec7[0];
			fRec5[1] = fRec5[0];
			fRec0[1] = fRec0[0];
			fRec1[1] = fRec1[0];
			fRec3[1] = fRec3[0];
			fRec4[1] = fRec4[0];
		}
	}

};

#undef private
#undef virtual
#undef mydsp

/*
 * ChucK glue code
 */
static t_CKUINT SawDL_offset_data = 0;
static int g_sr = 44100;
static int g_nChans = 1;

CK_DLL_CTOR(SawDL_ctor)
{
    // return data to be used later
    SawDL *d = new SawDL;
    OBJ_MEMBER_UINT(SELF, SawDL_offset_data) = (t_CKUINT)d;
    d->init(g_sr);
    d->ck_frame_in = new SAMPLE*[g_nChans];
    d->ck_frame_out = new SAMPLE*[g_nChans];
}

CK_DLL_DTOR(SawDL_dtor)
{
    SawDL *d = (SawDL*)OBJ_MEMBER_UINT(SELF, SawDL_offset_data);

    delete[] d->ck_frame_in;
    delete[] d->ck_frame_out;
    
    delete d;
    
    OBJ_MEMBER_UINT(SELF, SawDL_offset_data) = 0;
}

// mono tick
CK_DLL_TICK(SawDL_tick)
{
    SawDL *d = (SawDL*)OBJ_MEMBER_UINT(SELF, SawDL_offset_data);
    
    d->ck_frame_in[0] = &in;
    d->ck_frame_out[0] = out;

    d->compute(1, d->ck_frame_in, d->ck_frame_out);
    
    return TRUE;
}

// multichannel tick
CK_DLL_TICKF(SawDL_tickf)
{
    SawDL *d = (SawDL*)OBJ_MEMBER_UINT(SELF, SawDL_offset_data);
    
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

CK_DLL_MFUN(SawDL_ctrl_fEntry0)
{
    SawDL *d = (SawDL*)OBJ_MEMBER_UINT(SELF, SawDL_offset_data);
    d->fEntry0 = (SAMPLE)GET_CK_FLOAT(ARGS);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry0);
}

CK_DLL_MFUN(SawDL_cget_fEntry0)
{
    SawDL *d = (SawDL*)OBJ_MEMBER_UINT(SELF, SawDL_offset_data);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry0);
}


CK_DLL_MFUN(SawDL_ctrl_fEntry2)
{
    SawDL *d = (SawDL*)OBJ_MEMBER_UINT(SELF, SawDL_offset_data);
    d->fEntry2 = (SAMPLE)GET_CK_FLOAT(ARGS);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry2);
}

CK_DLL_MFUN(SawDL_cget_fEntry2)
{
    SawDL *d = (SawDL*)OBJ_MEMBER_UINT(SELF, SawDL_offset_data);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry2);
}


CK_DLL_MFUN(SawDL_ctrl_fEntry1)
{
    SawDL *d = (SawDL*)OBJ_MEMBER_UINT(SELF, SawDL_offset_data);
    d->fEntry1 = (SAMPLE)GET_CK_FLOAT(ARGS);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry1);
}

CK_DLL_MFUN(SawDL_cget_fEntry1)
{
    SawDL *d = (SawDL*)OBJ_MEMBER_UINT(SELF, SawDL_offset_data);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry1);
}


CK_DLL_MFUN(SawDL_ctrl_fEntry3)
{
    SawDL *d = (SawDL*)OBJ_MEMBER_UINT(SELF, SawDL_offset_data);
    d->fEntry3 = (SAMPLE)GET_CK_FLOAT(ARGS);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry3);
}

CK_DLL_MFUN(SawDL_cget_fEntry3)
{
    SawDL *d = (SawDL*)OBJ_MEMBER_UINT(SELF, SawDL_offset_data);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry3);
}


CK_DLL_MFUN(SawDL_ctrl_fEntry4)
{
    SawDL *d = (SawDL*)OBJ_MEMBER_UINT(SELF, SawDL_offset_data);
    d->fEntry4 = (SAMPLE)GET_CK_FLOAT(ARGS);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry4);
}

CK_DLL_MFUN(SawDL_cget_fEntry4)
{
    SawDL *d = (SawDL*)OBJ_MEMBER_UINT(SELF, SawDL_offset_data);
    RETURN->v_float = (t_CKFLOAT)(d->fEntry4);
}




CK_DLL_QUERY(SawDL_query)
{
    //g_sr = QUERY->srate;
    //g_sr = QUERY->srate(); // changed by TJ on 4/2/25, to address error that appears when trying to use the faust2ck utility

	SawDL temp; // needed to get IO channel count

    QUERY->setname(QUERY, "SawDL");
    
    QUERY->begin_class(QUERY, "SawDL", "UGen");
    QUERY->doc_class(QUERY, "SawDL");
    QUERY->add_ex(QUERY, "SawDL-test.ck");
    
    QUERY->add_ctor(QUERY, SawDL_ctor);
    QUERY->add_dtor(QUERY, SawDL_dtor);
    
    g_nChans = std::max(temp.getNumInputs(), temp.getNumOutputs());
    
    if(g_nChans == 1)
        QUERY->add_ugen_func(QUERY, SawDL_tick, NULL, g_nChans, g_nChans);
    else
        QUERY->add_ugen_funcf(QUERY, SawDL_tickf, NULL, g_nChans, g_nChans);

    // add member variable
    SawDL_offset_data = QUERY->add_mvar( QUERY, "int", "@SawDL_data", FALSE );
    if( SawDL_offset_data == CK_INVALID_OFFSET ) goto error;

    
    QUERY->add_mfun( QUERY, SawDL_cget_fEntry0 , "float", "cutoff" );
    
    QUERY->add_mfun( QUERY, SawDL_ctrl_fEntry0 , "float", "cutoff" );
    QUERY->add_arg( QUERY, "float", "cutoff" );
    QUERY->doc_func(QUERY, "float value controls cutoff" );
    

    QUERY->add_mfun( QUERY, SawDL_cget_fEntry2 , "float", "freq" );
    
    QUERY->add_mfun( QUERY, SawDL_ctrl_fEntry2 , "float", "freq" );
    QUERY->add_arg( QUERY, "float", "freq" );
    QUERY->doc_func(QUERY, "float value controls freq" );
    

    QUERY->add_mfun( QUERY, SawDL_cget_fEntry1 , "float", "gain" );
    
    QUERY->add_mfun( QUERY, SawDL_ctrl_fEntry1 , "float", "gain" );
    QUERY->add_arg( QUERY, "float", "gain" );
    QUERY->doc_func(QUERY, "float value controls gain" );
    

    QUERY->add_mfun( QUERY, SawDL_cget_fEntry3 , "float", "glide" );
    
    QUERY->add_mfun( QUERY, SawDL_ctrl_fEntry3 , "float", "glide" );
    QUERY->add_arg( QUERY, "float", "glide" );
    QUERY->doc_func(QUERY, "float value controls glide" );
    

    QUERY->add_mfun( QUERY, SawDL_cget_fEntry4 , "float", "reson" );
    
    QUERY->add_mfun( QUERY, SawDL_ctrl_fEntry4 , "float", "reson" );
    QUERY->add_arg( QUERY, "float", "reson" );
    QUERY->doc_func(QUERY, "float value controls reson" );
    


    // end import
	QUERY->end_class(QUERY);
	
    return TRUE;

error:
    // end import
	QUERY->end_class(QUERY);

    return FALSE;
}

#endif
