/***
Copyright (C) 2014-2015 Marvin Beckers
This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License version 3, as published
by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranties of
MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program. If not, see http://www.gnu.org/licenses/.
***/

namespace SwitchboardPlugUserAccounts.Widgets {
	public class GuestSettings : Gtk.Grid {
		private Gtk.Switch guest_switch;
		public signal void guest_switch_changed ();

		public GuestSettings () {
			vexpand = false;
			valign = Gtk.Align.CENTER;
			halign = Gtk.Align.CENTER;
			margin_left = 96;
			margin_right = 96;
			border_width = 24;
			row_spacing = 24;
			column_spacing = 12;
			build_ui ();
			update_ui ();

			get_permission ().notify["allowed"].connect (update_ui);
		}

		private void build_ui () {
			Gtk.Grid sub_grid = new Gtk.Grid ();
			sub_grid.hexpand = true;
			sub_grid.halign = Gtk.Align.CENTER;
			sub_grid.column_spacing = 10;
			attach (sub_grid, 0, 0, 1, 1);

			Gtk.Image image = new Gtk.Image ();
			Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
				try {
					Gdk.Pixbuf image_pixbuf = icon_theme.load_icon ("avatar-default", 72, 0);
					image.set_from_pixbuf (image_pixbuf);
				} catch (Error e) { }
			image.valign = Gtk.Align.START;
			image.halign = Gtk.Align.END;
			sub_grid.attach (image, 0, 0, 1, 2);

			var header_label = new Gtk.Label (_("Guest Session"));
			header_label.hexpand = true;
			header_label.get_style_context ().add_class ("h2");
			header_label.halign = Gtk.Align.START;
			header_label.valign = Gtk.Align.END;
			header_label.justify = Gtk.Justification.FILL;

			sub_grid.attach (header_label, 1, 0, 1, 1);

			guest_switch = new Gtk.Switch ();
			guest_switch.hexpand = true;
			guest_switch.halign = Gtk.Align.START;
			guest_switch.notify["active"].connect (() => {
				set_guest_session_state (guest_switch.active);
				guest_switch_changed ();
			});
			sub_grid.attach (guest_switch, 1, 1, 1, 1);

			Gtk.Label label = new Gtk.Label ("%s %s\n\n%s".printf (
				_("The Guest Session allows someone to use a temporary default account without a password."),
					_("Once they log out, all of their settings and data will be deleted."),
					_("Changes to the Guest Session will apply after the system restarted.")));
			label.justify = Gtk.Justification.FILL;
			label.valign = Gtk.Align.START;
			label.set_line_wrap (true);
			attach (label, 0, 1, 1, 1);

			show_all ();
		}

		public void update_ui () {
			guest_switch.set_sensitive (get_permission ().allowed);
			guest_switch.set_active (get_guest_session_state ());
		}
	}
}