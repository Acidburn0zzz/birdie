// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013-2018 Amuza Limited
 *
 * This software is licensed under the GNU General Public License
 * (version 3 or later). See the COPYING file in this distribution.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this software; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Ivo Nunes <ivo@amuza.uk>
 *              Vasco Nunes <vasco@amuza.uk>
 *              Nathan Dyer <mail@nathandyer.me>
 */

namespace Birdie.Media {

    // returns a resized pixbuf to fit the current user's screen resolution
    public Gdk.Pixbuf fit_user_screen (string image_path, Gtk.Widget widget) {

        int screen_height;
        int screen_width;
        double factor;
        double new_width;
        double new_height;

        Gdk.Pixbuf pixbuf = null;

        try {
            pixbuf = new Gdk.Pixbuf.from_file (image_path);
        } catch (Error e) {
            warning ("Error resizing image: %s", e.message);
            try {
                pixbuf = new Gdk.Pixbuf.from_file (Constants.PKGDATADIR + "/media.png");
            } catch {}
        }

        screen_height = (int) (widget.get_screen ().get_height () / 1.5);
        screen_width = (int) (widget.get_screen ().get_width () / 1.5);

        // check if the image is larger than current screen height
        if (pixbuf.get_height () >= screen_height) {
            // formula to resize the image mantaining its proportions
            factor = (double)pixbuf.get_width () / pixbuf.get_height ();
            new_width = factor * (screen_height-100);
            pixbuf = pixbuf.scale_simple ((int)new_width, screen_height-100, Gdk.InterpType.BILINEAR);
        }

        // check if the image is larger than current screen width
        if (pixbuf.get_width () >= screen_width) {
            // formula to resize the image mantaining its proportions
            factor = (double)pixbuf.get_height () / pixbuf.get_width ();
            new_height = factor * (screen_width-100);
            pixbuf.scale_simple (screen_width-100, (int)new_height, Gdk.InterpType.BILINEAR);
        }
        return pixbuf;
    }

    // returns a larger image for use in a popover
    public Gdk.Pixbuf get_consistent_large_pixbuf (string image_path) {

        double factor;
        double new_width;
        double new_height;

        Gdk.Pixbuf pixbuf = null;

        info("Getting consistent large pixbuf");

        try {
            pixbuf = new Gdk.Pixbuf.from_file (image_path);
        } catch (Error e) {
            warning ("Error resizing image: %s", e.message);
            try {
                pixbuf = new Gdk.Pixbuf.from_file (Constants.PKGDATADIR + "/media.png");
            } catch {}
        }

        // check if the image is larger than current screen height
        if (pixbuf.get_height () >= 720) {
            // formula to resize the image mantaining its proportions
            factor = (double)pixbuf.get_width () / pixbuf.get_height ();
            new_width = factor * (720);
            pixbuf = pixbuf.scale_simple ((int)new_width, 720, Gdk.InterpType.BILINEAR);
        }

        // check if the image is larger than current screen width
        if (pixbuf.get_width () >= 480) {
            // formula to resize the image mantaining its proportions
            factor = (double)pixbuf.get_height () / pixbuf.get_width ();
            new_height = factor * (480);
            pixbuf.scale_simple (480, (int)new_height, Gdk.InterpType.BILINEAR);
        }
        return pixbuf;
    }

    public async void generate_rounded_avatar (string avatar_path,
        int width = 50, int height = 50, int roundness = 7,
        double line_width = 0, double border_color_r = 0.5,
        double border_color_g = 0.5, double border_color_b = 0.5) throws GLib.Error {

        Gdk.Pixbuf pixbuf;

        try {
            // generate rounded avatar
            var surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, width, height);
            var ctx = new Cairo.Context (surface);

            draw_rounded_path (ctx, 0, 0, width, height, roundness);
            ctx.set_line_width (line_width);
            ctx.set_source_rgb (border_color_r, border_color_g, border_color_b);
            ctx.stroke_preserve ();

            pixbuf = new Gdk.Pixbuf.from_file (avatar_path);

            if (pixbuf != null) {
                Gdk.cairo_set_source_pixbuf(ctx, pixbuf, 1, 1);
                ctx.clip ();
            }

            ctx.paint ();
            surface.write_to_png (avatar_path);
        } catch (Error e) {
            debug ("Skipped creating avatar: %s", e.message);

            try { File.new_for_path (avatar_path).delete (); } catch {}
        }
    }
}
