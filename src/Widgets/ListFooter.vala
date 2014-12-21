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

namespace SwitchboardPlugUsers.Widgets {
	public class ListFooter : Gtk.Box {
		public Gtk.Button button_add;
		public Gtk.Button button_remove;

		private unowned Polkit.Permission permission;

		public ListFooter (Polkit.Permission _permission) {
			Object (orientation: Gtk.Orientation.HORIZONTAL, spacing: 5);
			permission = _permission;
			permission.notify["allowed"].connect (update_ui);
			build_ui ();
		}

		private void build_ui () {
			button_add = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.BUTTON);
			button_add.set_tooltip_text (_("Create user account"));
			button_add.margin_start = 4;
			button_add.set_relief (Gtk.ReliefStyle.NONE);
			button_add.set_sensitive (false);
			button_add.clicked.connect (show_new_user_dialog);
			pack_start (button_add, false);

			pack_start (new Gtk.Separator (Gtk.Orientation.VERTICAL), false);
			button_remove = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.BUTTON);
			button_remove.set_tooltip_text (_("Mark user account for removal"));
			button_remove.set_relief (Gtk.ReliefStyle.NONE);
			button_remove.set_sensitive (false);
			pack_start (button_remove, false);

			pack_start (new Gtk.Separator (Gtk.Orientation.VERTICAL), false);

			show_all ();
		}

		private void update_ui () {
			if (permission.allowed && permission.get_action_id () == "org.freedesktop.accounts.user-administration") {
				button_add.set_sensitive (true);
				button_remove.set_sensitive (true);
			}
		}

		private void show_new_user_dialog () {
			Dialogs.NewUserDialog new_user_d = new Dialogs.NewUserDialog ();
			new_user_d.show ();
		}
	}
}
