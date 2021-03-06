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

namespace Birdie.Utils {

    /**
     * LogLevel:
     */
    public enum LogLevel {
        /**
         * This level is for use in debugging.
         */
        DEBUG,

        /**
         * This level should be used for non-error, non-debugging that is not due to any direct event.
         */
        INFO,

        /**
         * This level is used to log events that have happened in the app.
         */
        NOTIFY,

        /**
         * This level should be used for warnings of errors that haven't happened yet.
         */
        WARN,

        /**
         * This level should be used by recoverable errors.
         */
        ERROR,

        /**
         * This level should be used only in cases of unrecoverable errors.
         */
        FATAL,
    }

    enum ConsoleColor {
        BLACK,
        RED,
        GREEN,
        YELLOW,
        BLUE,
        MAGENTA,
        CYAN,
        WHITE,
    }

    /**
     * This class helps in the use of logs in a Granite application.
     *
     */
    public class Logger : GLib.Object {

        /**
         * This is used to determine which level of LogLevelling should be used.
         */
        public static LogLevel DisplayLevel { get; set; default = LogLevel.WARN; }

        /**
         * The name of the app that is logging.
         */
        static string AppName { get; set; }

        static Regex re;

        /**
         * This method initializes the Logger
         *
         * @param app_name name of app that is logging
         */
        public static void initialize (string app_name) {

            AppName = app_name;
            /*try {
                re = new Regex ("""(.*)\.vala(:\d+): (.*)""");
            } catch { }*/

            Log.set_default_handler (glib_log_func);
        }

        /**
         * Formats a message to be logged
         *
         * @param msg message to be formatted
         */
        static string format_message (string msg) {

            if (re != null && re.match (msg)) {
                var parts = re.split (msg);
                return "[%s%s] %s".printf (parts[1], parts[2], parts[3]);
            }
            return msg;
        }

        /**
         * Logs message using Notify level formatting
         *
         * @param msg message to be logged
         */
        public static void notification (string msg) {
            write (LogLevel.NOTIFY, format_message (msg));
        }

        static string get_time () {

            var now = new DateTime.now_local ();
            return "%.2d:%.2d:%.2d.%.6d".printf (now.get_hour (), now.get_minute (), now.get_second (), now.get_microsecond ());
        }

        static void write (LogLevel level, string msg) {

            if (level < DisplayLevel)
                return;

            set_color_for_level (level);
            stdout.printf ("[%s %s]", level.to_string ().substring (16), get_time ());

            reset_color ();
            stdout.printf (" %s\n", msg);
        }

        static void set_color_for_level (LogLevel level) {

            switch (level) {
                case LogLevel.DEBUG:
                    set_foreground (ConsoleColor.GREEN);
                    break;
                case LogLevel.INFO:
                    set_foreground (ConsoleColor.BLUE);
                    break;
                case LogLevel.NOTIFY:
                    set_foreground (ConsoleColor.MAGENTA);
                    break;
                case LogLevel.WARN:
                    set_foreground (ConsoleColor.YELLOW);
                    break;
                case LogLevel.ERROR:
                    set_foreground (ConsoleColor.RED);
                    break;
                case LogLevel.FATAL:
                    set_background (ConsoleColor.RED);
                    set_foreground (ConsoleColor.WHITE);
                    break;
            }
        }

        static void reset_color () {
            stdout.printf ("\x001b[0m");
        }

        static void set_foreground (ConsoleColor color) {
            set_color (color, true);
        }

        static void set_background (ConsoleColor color) {
            set_color (color, false);
        }

        static void set_color (ConsoleColor color, bool isForeground) {

            var color_code = color + 30 + 60;
            if (!isForeground)
                color_code += 10;
            stdout.printf ("\x001b[%dm", color_code);
        }

        static void glib_log_func (string? d, LogLevelFlags flags, string msg) {
            var domain = "";
            if (d != null)
                domain = "[%s] ".printf (d);

            var message = msg.replace ("\n", "").replace ("\r", "");
            message = "%s%s".printf (domain, message);

            switch (flags) {
                case LogLevelFlags.LEVEL_CRITICAL:
                    write (LogLevel.FATAL, format_message (message));
                    write (LogLevel.FATAL, format_message (AppName + " will not function properly."));
                    break;

                case LogLevelFlags.LEVEL_ERROR:
                    write (LogLevel.ERROR, format_message (message));
                    break;

                case LogLevelFlags.LEVEL_INFO:
                case LogLevelFlags.LEVEL_MESSAGE:
                    write (LogLevel.INFO, format_message (message));
                    break;

                case LogLevelFlags.LEVEL_DEBUG:
                    write (LogLevel.DEBUG, format_message (message));
                    break;

                case LogLevelFlags.LEVEL_WARNING:
                default:
                    write (LogLevel.WARN, format_message (message));
                    break;
            }
        }

    }

}