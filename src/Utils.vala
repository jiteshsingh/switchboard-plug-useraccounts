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
 * Authored by: Marvin Beckers <beckersmarvin@gmail.com>
 * Authored by: Switchboard Locale Plug Developers
 */

namespace SwitchboardPlugUserAccounts {
	public enum PassChangeType {
		NEW_PASSWORD,
		NO_PASSWORD,
		ON_LOGIN
	}

	private static string[]? installed_languages = null;

	public static string[]? get_installed_languages () {
		if (installed_languages != null)
			return installed_languages;

		string output;
		int status;

		try {
			Process.spawn_sync (null, 
				{"/usr/share/language-tools/language-options" , null}, 
				Environ.get (),
				SpawnFlags.SEARCH_PATH,
				null,
				out output,
				null,
				out status);

				installed_languages = output.split("\n");
				return installed_languages;
		} catch (Error e) {
			return null;
		}
	}

		private static Polkit.Permission? permission = null;
	
		public static Polkit.Permission? get_permission () {
			if (permission != null)
				return permission;
			try {
				permission = new Polkit.Permission.sync ("org.freedesktop.accounts.user-administration", Polkit.UnixProcess.new (Posix.getpid ()));
				return permission;
			} catch (Error e) {
				critical (e.message);
				return null;
			}
		}

		private static Act.UserManager? usermanager = null;
	
		public static unowned Act.UserManager? get_usermanager () {
			if (usermanager != null && usermanager.is_loaded)
				return usermanager;

			usermanager = Act.UserManager.get_default ();
			return usermanager;
		}

		private static Act.User? current_user = null;

		public static unowned Act.User? get_current_user () {
			if (current_user != null)
				return current_user;

			current_user = get_usermanager ().get_user (GLib.Environment.get_user_name ());
			return current_user;
		}

		private static List<Act.User>? removal_list = null;

		public static unowned List<Act.User> get_removal_list () {
			if (removal_list != null)
				return removal_list;

			removal_list = new List<Act.User> ();
			return removal_list;
		}
		public static void clear_removal_list () {
			removal_list = null;
		}

		public static void mark_removal (Act.User user) {
			if (removal_list == null)
				get_removal_list ();

			removal_list.append (user);
		}

		public static void undo_removal () {
			if (removal_list != null && removal_list.last () != null) {
				removal_list.remove (removal_list.last ().data);
			}
		}

		public static bool check_removal (Act.User user) {
			if (removal_list != null && removal_list.last () != null) {
				unowned List<Act.User>? find = removal_list.find (user);
				if (find != null)
					return true;
				else
					return false;
			}
			return false;
		}

		public static bool is_last_admin (Act.User user) {
			foreach (unowned Act.User temp_user in get_usermanager ().list_users ()) {
				if (temp_user != user && temp_user.get_account_type () == Act.UserAccountType.ADMINISTRATOR)
					return false;
			}
			return true;
		}

		public static void create_new_user (string fullname, string username, Act.UserAccountType usertype, PassChangeType type, string? pw = null) {
			if (get_permission ().allowed) {
				try {
					Act.User created_user = get_usermanager ().create_user (username, fullname, usertype);
					get_usermanager ().user_added.connect ((user) => {
						if (user == created_user) {
							created_user.set_locked (false);
								if (type == PassChangeType.NEW_PASSWORD && pw != null)
									created_user.set_password (pw, "");
								else if (type == PassChangeType.NO_PASSWORD)
									created_user.set_password_mode (Act.UserPasswordMode.NONE);
								else if (type == PassChangeType.ON_LOGIN)
									created_user.set_password_mode (Act.UserPasswordMode.SET_AT_LOGIN);
						}
					});
				} catch (Error e) {
					critical ("Creation of user '%s' failed".printf (username));
				}
			}
		}
}
