import os.path
current_dir = os.path.dirname(os.path.abspath(__file__))
import time
import glob
import json
import cherrypy
import urllib
import liblo
import time
import socket
import os

USER_PATH = os.environ['USER_DIR']
GRABS_PATH = USER_PATH+"/Grabs/"
MODES_PATH = USER_PATH+"/Modes/"

print "user path : " + USER_PATH
print "modes : " + MODES_PATH
print "grabs : " + GRABS_PATH

try:
	osc_target = liblo.Address(4000)
except liblo.AddressError as err:
	print(err)
	sys.exit()

def get_immediate_subdirectories(dir) :
    return [name for name in os.listdir(dir)
            if os.path.isdir(os.path.join(dir, name))]

class Root():

    # /mode/mode-name  loads mode
    def get_mode(self, p):
        mode_path = MODES_PATH+p+'/main.py'
        mode = open(mode_path, 'r').read()
        liblo.send(osc_target, "/set", p)
        return mode
    get_mode.exposed = True

    def save_new(self, name, contents):
        p = name
        mode_dir = MODES_PATH+p
        mode_path = MODES_PATH+p+'/main.py'
        if not os.path.exists(mode_dir): os.makedirs(mode_dir)
        with open(mode_path, "w") as text_file:
            text_file.write(contents)
        #then send reload command
        print "sending new: " + str(name)
        liblo.send(osc_target, "/new", name)
        return "SAVED " + name
    save_new.exposed = True

    def send_reload(self, name):
        liblo.send(osc_target, "/reload", 1)
        return "TEST"
    send_reload.exposed = True
 
    def save(self, name, contents):
        #save the mode
        p = name
        mode_path = MODES_PATH+p+'/main.py'
        with open(mode_path, "w") as text_file:
            text_file.write(contents)
        #then send reload command
        liblo.send(osc_target, "/reload", 1)
        return "SAVED " + name
    save.exposed = True
   
    def get_grabs(self):
        
        images = []
        for filepath in sorted(glob.glob(GRABS_PATH+'*.jpg')):
            filename = os.path.basename(filepath)
            images.append(filename)
        return json.dumps(images)
    get_grabs.exposed = True

    def get_grab(self, name):
        grab_path = GRABS_PATH+name
        grab = open(grab_path, 'r').read()
        cherrypy.response.headers['Content-Type'] = "image/jpg"
        return grab
    get_grab.exposed = True


    # returns list of all the modees
    def index(self):
        
        print "loading modees..."
        modees = []
        mode_folders = get_immediate_subdirectories(MODES_PATH)

        for mode_folder in mode_folders :
            mode_name = str(mode_folder)
            mode_path = MODES_PATH+mode_name+'/main.py'
            #modees.append(urllib.quote(mode_name))
            modees.append(mode_name)

        return json.dumps(modees)

    index.exposed = True


