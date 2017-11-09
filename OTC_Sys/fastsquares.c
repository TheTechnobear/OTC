#include <linux/fb.h>
#include <stdio.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

uint8_t *fbp, *bbp, *vbp, *tmp;  // front and back and virtual buffers.  we draw on virtual, move it to back, fb offset gets swapped, repeat
struct fb_fix_screeninfo finfo;
struct fb_var_screeninfo vinfo;
int fb_fd = 0;
long screensize = 0;

inline uint32_t pixel_color(uint8_t r, uint8_t g, uint8_t b, struct fb_var_screeninfo *vinfo)
{
    return (r<<vinfo->red.offset) | (g<<vinfo->green.offset) | (b<<vinfo->blue.offset);
}

inline void swap_buffers() {


}

int main()
{
    fb_fd = open("/dev/fb0",O_RDWR);
    //Get variable screen information
    ioctl(fb_fd, FBIOGET_VSCREENINFO, &vinfo);
    vinfo.grayscale=0;
    vinfo.bits_per_pixel=32;
    vinfo.yres_virtual = 1440; // shouldn't this be implied?
    ioctl(fb_fd, FBIOPUT_VSCREENINFO, &vinfo);
    ioctl(fb_fd, FBIOGET_VSCREENINFO, &vinfo);

    ioctl(fb_fd, FBIOGET_FSCREENINFO, &finfo);
    
    screensize = vinfo.yres * finfo.line_length;

   // fbp = mmap(0, screensize, PROT_READ | PROT_WRITE, MAP_SHARED, fb_fd, (off_t)0);

    fbp = mmap(0, screensize * 2, PROT_READ | PROT_WRITE, MAP_SHARED, fb_fd, (off_t)0);
   bbp = fbp + screensize;
   vbp = (uint8_t *) malloc(screensize);
    
    // set buffer
    vinfo.yoffset=0;
    vinfo.xoffset=0;
    ioctl(fb_fd, FBIOPAN_DISPLAY, &vinfo); 

    printf("about to draw. size x = %d, size y = %d, bpp = %d, y virtual = %d\n", vinfo.xres, vinfo.yres, vinfo.bits_per_pixel, vinfo.yres_virtual);
    printf("red offset = %d, blue offset = %d, green offset = %d \n", vinfo.red.offset, vinfo.blue.offset, vinfo.green.offset);
    printf("alpha offset = %d, alpha length = %d \n", vinfo.transp.offset, vinfo.transp.length);
    printf("line len whatever that is %d\n", finfo.line_length);

    int x,y;
    int c;

    printf("cleared bufs\n");
    //int color = 0x28282828;
    int color = 0;
    int count = 0;
    unsigned int randox, randoy;
    unsigned int sx, sy;
    sx = vinfo.xres;
    sy = vinfo.yres; 

    for (c = 0; c <2; c++){
        // fill one h line
        for (x=0;x<vinfo.xres;x++) {
                long location = x * (vinfo.bits_per_pixel/8);
                *((uint32_t*)(vbp + location)) = color;
        }
        // copy to all v lines
        for (y=1;y<vinfo.yres;y++){
            memcpy(vbp + (finfo.line_length * y), vbp, finfo.line_length);
        }

        // copy to back  
        memcpy(bbp, vbp, screensize);

        // flip
        if (vinfo.yoffset==0)
			vinfo.yoffset = vinfo.yres;//screensize;
		else
			vinfo.yoffset=0;

		//"Pan" to the back buffer	
		ioctl(fb_fd, FBIOPAN_DISPLAY, &vinfo); 
	 
		//Update the pointer to the back buffer so we don't draw on the front buffer
		//long tmp;
		tmp=fbp;
		fbp=bbp;
		bbp=tmp;
	    
        // 30 frames a sec
        usleep(20000);
    }

    return 0;
}
