/*-
 * Copyright (c) 2014 Marvin Beckers <beckersmarvin@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Corentin Noël <tintou@mailoo.org>
 * Authored by: Marvin Beckers <beckersmarvin@gmail.com>
 */

namespace SwitchboardPlugUsers {
	public static Plug plug;
	private Gtk.Grid main_grid;
	private Gtk.InfoBar infobar;

	private Gtk.LockButton lock_button;

	public class Plug : Switchboard.Plug {
		private Widgets.UserView userview;

		public Plug () {
			Object (category: Category.SYSTEM,
				code_name: Build.PLUGCODENAME,
				display_name: _("Users Accounts"),
				description: _("Manage user accounts on your local system"),
				icon: "system-users");

			plug = this;
		}

		public override Gtk.Widget get_widget () {
			if (main_grid != null)
				return main_grid;

			main_grid = new Gtk.Grid ();
			main_grid.expand = true;

			try {
				var permission = new Polkit.Permission.sync ("org.freedesktop.accounts.user-administration", Polkit.UnixProcess.new (Posix.getpid ()));

				infobar = new Gtk.InfoBar ();
				infobar.message_type = Gtk.MessageType.INFO;
				lock_button = new Gtk.LockButton (permission);
				var area = infobar.get_action_area () as Gtk.Container;
				var content = infobar.get_content_area () as Gtk.Container;
				var label = new Gtk.Label (_("Some settings require administrator rights to be changed"));
				area.add (lock_button);
				content.add (label);
				main_grid.attach (infobar, 0, 0, 1, 1);

				userview = null;
				userview = new Widgets.UserView (permission);
				main_grid.attach (userview, 0, 1, 1, 1);
				main_grid.show_all ();

				permission.notify["allowed"].connect (() => {
					if (permission.allowed) {
						infobar.no_show_all = true;
						infobar.hide ();
					}
				});
			} catch (Error e) {
				critical (e.message);
			}

			return main_grid;
		}

        public override void shown () { }
        public override void hidden () { }
        public override void search_callback (string location) { }

        // 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior")
        public override async Gee.TreeMap<string, string> search (string search) {
            return new Gee.TreeMap<string, string> (null, null);
        }
    }
}

public Switchboard.Plug get_plug (Module module) {
	debug ("Activating User Accounts plug");
	var plug = new SwitchboardPlugUsers.Plug ();
	return plug;
}
