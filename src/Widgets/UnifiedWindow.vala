// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013 Birdie Developers (http://launchpad.net/birdie)
 *
 * This software is licensed under the GNU General Public License
 * (version 3 or later). See the COPYING file in this distribution.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this software; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Ivo Nunes <ivoavnunes@gmail.com>
 *              Vasco Nunes <vascomfnunes@gmail.com>
 */

namespace Birdie.Widgets {
    public class UnifiedWindow : Gtk.Window
    {
        public int opening_x;
        public int opening_y;
        public int window_width;
        public int window_height;
        
        public Gtk.Toolbar header;
        public Gtk.Box box;

        public UnifiedWindow () {
            this.opening_x = -1;
            this.opening_y = -1;
            this.window_width = -1;
            this.window_height = -1;

            // set smooth scrolling events
            set_events(Gdk.EventMask.SMOOTH_SCROLL_MASK);

            this.delete_event.connect (on_delete_event);
            
            header = new Gtk.Toolbar ();

            box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            box.add (header);

            this.add (box);
            this.set_title ("Birdie");
        }

        private bool on_delete_event () {
            this.save_window ();
            base.hide_on_delete ();
            return true;
        }

        public void save_window () {
            this.get_position (out opening_x, out opening_y);
            this.get_size (out window_width, out window_height);
        }

        public void restore_window () {
            if (this.opening_x > 0 && this.opening_y > 0 && this.window_width > 0 && this.window_height > 0) {
                this.move (this.opening_x, this.opening_y);
                this.set_default_size (this.window_width, this.window_height);
            }
        }

        public override void show () {
            base.show ();
            this.restore_window ();
        }
    }
}
