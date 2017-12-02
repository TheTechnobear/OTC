import pygame
import time
import etc_system
import traceback
import sys
import psutil
#from pygame.locals import *
import osc
import sound
import osd
import liblo
import midi
print "starting..."

# create etc object
# this holds all the data (mode and preset names, knob values, midi input, sound input, current states, etc...)
# it gets passed to the modes which use the audio midi and knob values
etc = etc_system.System()

# just to make sure
etc.clear_flags()

# setup osc and callbacks
osc.init(etc)

# setup alsa sound
sound.init(etc)

# init pygame, this has to happen after sound is setup
# but before the graphics stuff below
pygame.init()
clocker = pygame.time.Clock() # for locking fps

# on screen display and other screen helpers
osd.init(etc)
osc.send("/led", 7) # set led to running

osc.send("/oled/line/1", " ")
osc.send("/oled/line/2", " ")
osc.send("/oled/line/3", " ")
osc.send("/oled/line/4", " ")
osc.send("/oled/line/5", " ")
osc.send("/oled/setscreen", 3)
osc.send("/patchLoaded", 1)

# set midi ch, check for file, default to 1
ch = 1
try :
    file = open(etc.USER_PATH+"/MIDI-Channel.txt", "r")
    line = file.readline()
    ch = int(line.strip())
except IOError as (errno, strerror):
    print "MIDI ch file I/O error({0}): {1}".format(errno, strerror)
except ValueError:
    print "Could not convert data to an integer."
except:
    print "Unexpected error:", sys.exc_info()[0]
    raise

# force midi to 17 (0 is omni)
etc.midi_ch = ch % 17
print "set MIDI to ch " + str(etc.midi_ch)
osc.send("/midich", int(etc.midi_ch))

# setup midi input from USB
midi.init(etc)

print "display info:" + str(pygame.display.Info());
print "display modes:" + str(pygame.display.list_modes());

# init fb and main surfaces
print "opening frame buffer..."
#note: HWSURFACE is defaulted if present
hwscreen = pygame.display.set_mode(etc.RES,  pygame.FULLSCREEN | pygame.DOUBLEBUF, 32)
print "hwscreen : " +str(hwscreen)

screen = hwscreen.copy()
print "screen : " +str(screen)

screen.fill((0,0,0)) 
hwscreen.blit(screen, (0,0))
pygame.display.flip()
hwscreen.blit(screen, (0,0))
pygame.display.flip()
osd.loading_banner(hwscreen, "")
time.sleep(2)

# etc gets a refrence to screen so it can save screen grabs 
etc.screen = screen

# load modes, post banner if none found
if not (etc.load_modes()) :
    print "no modes found."
    osd.loading_banner(hwscreen, "No Modes found.  Insert USB drive with Modes folder and restart.")
    while True:
        # quit on esc
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                exit()
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    exit()
        time.sleep(1)

# run setup functions if modes have them
print "running setup..."
for i in range(0, len(etc.mode_names)-1) :
    print etc.mode_root
    try :
        etc.set_mode_by_index(i)
        mode = sys.modules[etc.mode]
        info = sys.modules[etc.mode + ".info"]
    except AttributeError :
        print "mode not found, probably has error"
        continue 
    try : 
        osd.loading_banner(hwscreen,"Loading " + str(etc.mode) )
        print "Loading " + str(etc.mode) 
        mode.setup(screen, etc)
        etc.memory_used = psutil.virtual_memory()[2]
    except :
        print "error in setup, or setup not found"
        continue

# load screen grabs
etc.load_grabs()

# load scenes
etc.load_scenes()

# used to measure fps

# get total memory consumed, cap at 75%
etc.memory_used = psutil.virtual_memory()[2]
etc.memory_used = (etc.memory_used / 75) * 100
if (etc.memory_used > 100): etc.memory_used = 100

# set initial mode
etc.set_mode_by_index(0)
mode = sys.modules[etc.mode]
info = sys.modules[etc.mode + ".info"]

trigcount = 0
lasttrigcount = 0
midi_led_flashing = False

def modeChanged(modename, mode,info):
    etc.modeChanged = False
    osc.send("/oled/line/1", info.knob1[:16] + ' %0.0f%%' % (etc.knob1*100))
    osc.send("/oled/line/2", info.knob2[:16] + ' %0.0f%%' % (etc.knob2*100))
    osc.send("/oled/line/3", info.knob3[:16] + ' %0.0f%%' % (etc.knob3*100))
    osc.send("/oled/line/4", info.knob4[:16] + ' %0.0f%%' % (etc.knob4*100))
    osc.send("/oled/line/5", modename)

while 1:
    
    lknob1=etc.knob1
    lknob2=etc.knob2
    lknob3=etc.knob3
    lknob4=etc.knob4
    laudiopeak = etc.audio_peak
    if(etc.frame_count % 30) == 0 : 
        lasttrigcount = trigcount
        trigcount = 0


    # check for OSC
    osc.recv()

    # send get midi and knobs for next time
    # osc.send("/nf", 1) # not required for organelle

    # stop a midi led flash if one is hapenning
    if (midi_led_flashing):
        midi_led_flashing = False
        osc.send("/led", 7)

    # check for midi from USB
    midi.poll() 
    if (etc.new_midi) :
        osc.send("/led", 2)
        midi_led_flashing = True

    # get knobs, checking for override, and check for new note on
    etc.update_knobs_and_notes()

    # check for midi program change
    etc.check_pgm_change()

    # quit on esc
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            exit()
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_ESCAPE:
                exit()

    # check for sound
    sound.recv()
    if(etc.audio_trig) :
        trigcount = trigcount + 1

    # set the mode on which to call draw
    try : 
        mode = sys.modules[etc.mode]
        info = sys.modules[etc.mode + ".info"]
    except :
        #print "mode not loaded, probably has errors"
        etc.error = "Mode " + etc.mode  + " not loaded."

    if(etc.modeChanged):
        modeChanged(etc.mode,mode,info)

    # save a screen shot before drawing stuff
    if (etc.screengrab_flag):
        osc.send("/led", 6) # flash led yellow
        etc.screengrab()
        osc.send("/led", 7)
        
    # see if save is being held down for deleting scene
    etc.update_scene_save_key()

    # clear it with bg color if auto clear enabled
    etc.bg_color =  etc.color_picker_bg()
    if etc.auto_clear :
        screen.fill(etc.bg_color) 
    
    # run setup (usually if the mode was reloaded)
    if etc.run_setup :
        etc.error = ''
        try :
            mode.setup(screen, etc)
        except Exception, e:
            etc.error = traceback.format_exc()
            print "error with setup: " + etc.error
   
    # draw it
    try :
        mode.draw(screen, etc)
    except Exception, e:
        etc.error = traceback.format_exc()
 
    #draw the main screen, limit fps 30
    hwscreen.blit(screen, (0,0))
    
    # osd
    if etc.osd :
        osd.render_overlay(hwscreen)
    else : 
        etc.fps = clocker.get_fps();

    clocker.tick(30)
    pygame.display.flip()
    etc.frame_count=etc.frame_count+1

    if etc.quit :
        osc.send("/oled/line/1", "OTC stopped")
        osc.send("/oled/line/2", " ")
        osc.send("/oled/line/3", " ")
        osc.send("/oled/line/4", " ")
        osc.send("/oled/line/5", " ")
        sys.exit()
    
    # clear all the events
    etc.clear_flags()
    osc_msgs_recv = 0

    if(etc.knob1!=lknob1) :
        osc.send("/oled/line/1", info.knob1[:16] + ' %0.0f%%' % (etc.knob1*100))
    if(etc.knob2!=lknob2) :
        osc.send("/oled/line/2", info.knob2[:16] + ' %0.0f%%' % (etc.knob2*100))
    if(etc.knob3!=lknob3) :
        osc.send("/oled/line/3", info.knob3[:16] + ' %0.0f%%' % (etc.knob3*100))
    if(etc.knob4!=lknob4) :
        osc.send("/oled/line/4", info.knob4[:16] + ' %0.0f%%' % (etc.knob4*100))
    if(etc.audio_peak!=laudiopeak) :
        peak = etc.audio_peak / 2900
        trig = lasttrigcount
        osc.send("/oled/vumeter", peak,peak, trig, trig)

time.sleep(1)

print "Quit"

