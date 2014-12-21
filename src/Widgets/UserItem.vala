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
 */
using Act;

namespace SwitchboardPlugUsers.Widgets {
	public class UserItem : Gtk.ListBoxRow {
		private Gtk.Grid grid;
		private Gtk.Image avatar;
		private Gdk.Pixbuf avatar_pixbuf;
		private Gtk.Box label_box;
		private Gtk.Label full_name_label;
		private Gtk.Label user_name_label;
		
		private Act.User user;

		public string user_name;

		public UserItem (Act.User user) {
			this.user = user;
			this.user_name = user.get_user_name ();

			build_ui ();
		}

		private void build_ui () {
			grid = new Gtk.Grid ();
			grid.margin = 6;
			grid.column_spacing = 6;
			add (grid);

			label_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
			label_box.vexpand = true;
			label_box.valign = Gtk.Align.CENTER;
			grid.attach (label_box, 1, 0, 1, 1);

			full_name_label = new Gtk.Label ("");
			full_name_label.halign = Gtk.Align.START;
			full_name_label.get_style_context ().add_class ("h3");

			user_name_label = new Gtk.Label ("");
			user_name_label.halign = Gtk.Align.START;
			user_name_label.use_markup = true;

			label_box.pack_start (full_name_label, false, false);
			label_box.pack_start (user_name_label, false, false);

			update_ui ();
		}

		public void update_ui () {
			try {
				avatar_pixbuf = new Gdk.Pixbuf.from_file_at_scale (user.get_icon_file (), 32, 32, true);
				avatar = new Gtk.Image.from_pixbuf (avatar_pixbuf);
			} catch (Error e) {
				avatar = new Gtk.Image.from_icon_name ("image-loading", Gtk.IconSize.DND);
			}
			avatar.margin_end = 5;
			grid.attach (avatar, 0, 0, 1, 1);

			full_name_label.set_label (user.get_real_name ());
			user_name_label.set_label ("<span font_size=\"small\">" + user.get_user_name () + "</span>");
			
			grid.show_all ();
		}
	}
}