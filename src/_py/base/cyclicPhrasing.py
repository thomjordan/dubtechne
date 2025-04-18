import time
from pythonosc.udp_client import SimpleUDPClient

ip = "127.0.0.1"
port = 4320

client  = SimpleUDPClient(ip, port)  # Create client
sendMsg = client.send_message # create shorter alias for osc send_message function

import redis
redis = redis.Redis(host='localhost', port=6379, decode_responses=True)
storedTempo = redis.get('tempo')      # get tempo value from redis store 
sendMsg("/tempo", float(storedTempo)) # set ChucK's tempo to stored value

p1 = { 
	'deltas': [0.5, 0.5], # [ 0.618, 0.382 ],
	'durs'  : [0.4, 0.4], # [ 0.618, 0.382 ],
	'amps'  : [ 0.382, 0.500, 0.382, 0.618 ],
	'notes' : [0, 6, 2, 4],  #[ 36, 48, 39, 43 ],
	'start' : 0.0,
	'end'   : 4.0,
	'loop'  : 6.0
}


p2 = { 
	'deltas': [0.5, 0.5], # [ 0.618, 0.382 ],
	'durs'  : [0.4, 0.4], # [ 0.618, 0.382 ],
	'amps'  : [ 0.382, 0.500, 0.382, 0.618 ],
	'notes' : [0, 6, 2, 4],  #[ 36, 48, 39, 43 ],
	'start' : 0.0,
	'end'   : 4.0,
	'loop'  : 6.0
}

def renderPhrase(toTracknum, p, trans=0):
	numevents = 0
	onsets = [ p['start'] ]
	durs   = []
	amps   = []
	notes  = []

	nextval = lambda k : p[k][ numevents % len(p[k]) ]

	while onsets[-1] < p['end']:
		onsets += [ onsets[-1] + nextval('deltas') ]
		notes  += [ nextval('notes') + trans * 1.0 ] # make sure they get seen as floats
		amps   += [ nextval('amps') ]
		durs   += [ nextval('durs') * 0.666667 ]
		numevents += 1

	del onsets[-1] # delete last item in onsets

	'''
	print(f"\n   onsets = {onsets} ({len(onsets)})")
	print(f"       durs = {durs} ({len(durs)})")
	print(f"       amps = {amps} ({len(amps)})")
	print(f"      notes = {notes} ({len(notes)})")
	print(f"  numevents = {numevents}\n")
	'''

	evlist = [ toTracknum, p['loop'], numevents ]

	for i in range(numevents):
		evlist += [ onsets[i], notes[i], amps[i], durs[i] ]

	print(f"\n  eventlist = {evlist} ({len(evlist)})\n")

	return evlist	


# print(f"\n  {elist} \n")

def startTransport():
	sendMsg("/transport", 1)
	redis.set('transport','1')

def stopTransport():
	sendMsg("/transport", 0)
	redis.set('transport','0')


sendMsg("/phrase", renderPhrase(0, p1))  # send phrase to track 0 of ChucK's phraseLooper
startTransport()

# wait for changes to particular keys in the redis store
# keys: tempo, transport, mute, transP1

storedTransport = redis.get('transport')
stored_mute     = redis.get('mute')
storedP1_trans  = redis.get('transP1')
storedP2_trans  = redis.get('transP2')

#'''
while True:
	time.sleep(0.05)

	currentTempo = redis.get('tempo')           # query redis for current value of tempo
	if currentTempo != storedTempo:             # if tempo-value has changed since the last query
		sendMsg("/tempo", float(currentTempo))  # set Chuck's tempo to new tempo-value
		storedTempo = currentTempo  

	currentTransport = redis.get('transport')
	if currentTransport != storedTransport:
		sendMsg("/transport", int(currentTransport))
		storedTransport = currentTransport

	current_mute = redis.get('mute')
	if current_mute != stored_mute:
		mute_val = int(current_mute)
		sendMsg("/mute", [int(mute_val/2), int(mute_val%2)]) # tracknum is mute_val/2, mute_state is mute_val%2
		stored_mute = current_mute

	currentP1_trans = redis.get('transP1')
	if currentP1_trans != storedP1_trans:
		sendMsg("/phrase", renderPhrase(0, p1, int(currentP1_trans))) # render on track 1
		storedP1_trans = currentP1_trans

	currentP2_trans = redis.get('transP2')
	if currentP2_trans != storedP2_trans:
		sendMsg("/phrase", renderPhrase(1, p2, int(currentP2_trans))) # render on track 2 
		storedP2_trans = currentP2_trans


#'''

