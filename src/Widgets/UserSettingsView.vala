/***
  Copyright (C) 2014-2015 Switchboard User Accounts Plug Developer
  This program is free software: you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License version 3, as published
  by the Free Software Foundation.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranties of
  MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
  PURPOSE. See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program. If not, see http://www.gnu.org/licenses/.
***/

namespace SwitchboardPlugUserAccounts.Widgets {
    public class UserSettingsView : Gtk.Grid {
        private unowned Act.User   user;
        private UserUtils           utils;

        private Gtk.Image           avatar;
        private Gdk.Pixbuf?         avatar_pixbuf;
        private Gtk.Button          avatar_button;
        private Gtk.Entry           full_name_entry;
        private Gtk.Button          password_button;
        private Gtk.Button          enable_user_button;
        private Gtk.ComboBoxText    user_type_box;
        private Gtk.ComboBoxText    language_box;
        private Gtk.Button          language_button;
        private Gtk.Switch          autologin_switch;
        private Gtk.Popover         avatar_popover;

        //lock widgets
        private Gtk.Image           full_name_lock;
        private Gtk.Image           user_type_lock;
        private Gtk.Image           language_lock;
        private Gtk.Image           autologin_lock;
        private Gtk.Image           password_lock;
        private Gtk.Image           enable_lock;

        private Dialogs.AvatarDialog avatar_dialog;

        private const string no_permission_string   = _("You do not have permissions to change this");
        private const string current_user_string    = _("You cannot change this for the currently active user");
        private const string last_admin_string      = _("You cannot remove the last administrator's privileges");

        public UserSettingsView (Act.User user) {
            this.user = user;
            utils = new UserUtils (this.user, this);
            build_ui ();
            this.user.changed.connect (update_ui);
        }
        
        public void build_ui () {
            margin = 20;
            set_row_spacing (10);
            set_column_spacing (20);
            set_valign (Gtk.Align.START);
            set_halign (Gtk.Align.CENTER);

            avatar_button = new Gtk.Button ();
            avatar_button.set_relief (Gtk.ReliefStyle.NONE);
            avatar_button.clicked.connect (avatar_button_clicked);
            attach (avatar_button, 0, 0, 1, 1);

            full_name_entry = new Gtk.Entry ();
            full_name_entry.get_style_context ().add_class ("h3");
            full_name_entry.activate.connect (() => utils.change_full_name (full_name_entry.get_text ()));
            attach (full_name_entry, 1, 0, 1, 1);

            var user_type_label = new Gtk.Label (_("Account type:"));
            user_type_label.halign = Gtk.Align.END;
            attach (user_type_label,0, 1, 1, 1);

            user_type_box = new Gtk.ComboBoxText ();
            user_type_box.append_text (_("Standard"));
            user_type_box.append_text (_("Administrator"));
            user_type_box.changed.connect (() => utils.change_user_type (user_type_box.get_active ()));
            attach (user_type_box, 1, 1, 1, 1);

            var lang_label = new Gtk.Label (_("Language:"));
            lang_label.halign = Gtk.Align.END;
            attach (lang_label, 0, 2, 1, 1);

            if (user != get_current_user ()) {
                language_box = new Gtk.ComboBoxText ();
                foreach (string s in get_installed_languages ()) {
                    if (s.length == 2)
                        language_box.append_text (Gnome.Languages.get_language_from_code (s, null));
                    else if (s.length == 5)
                        language_box.append_text (Gnome.Languages.get_language_from_locale (s, null));
                }
                language_box.changed.connect (() => utils.change_language (language_box.get_active_text ()));
                attach (language_box, 1, 2, 1, 1);
            } else {
                language_button = new Gtk.Button ();
                language_button.set_size_request (0, 27);
                language_button.clicked.connect (() => {
                    //TODO locale plug might change its codename because that's currently not really okay
                    var command = new Granite.Services.SimpleCommand (
                            Environment.get_home_dir (),
                            "/usr/bin/switchboard -o system-pantheon-locale");
                    command.run ();
                    return;
                });
                attach (language_button, 1, 2, 1, 1);
            }

            var login_label = new Gtk.Label (_("Log In automatically:"));
            login_label.halign = Gtk.Align.END;
            login_label.margin_top = 20;
            attach (login_label, 0, 3, 1, 1);

            autologin_switch = new Gtk.Switch ();
            autologin_switch.hexpand = true;
            autologin_switch.halign = Gtk.Align.START;
            autologin_switch.margin_top = 20;
            autologin_switch.notify["active"].connect (() => utils.change_autologin (autologin_switch.get_active ()));
            attach (autologin_switch, 1, 3, 1, 1);

            var change_password_label = new Gtk.Label (_("Password:"));
            change_password_label.halign = Gtk.Align.END;
            attach (change_password_label, 0, 4, 1, 1);

            password_button = new Gtk.Button ();
            password_button.set_relief (Gtk.ReliefStyle.NONE);
            password_button.halign = Gtk.Align.START;
            password_button.clicked.connect (() => {
                Widgets.PasswordPopover pw_popover = new Widgets.PasswordPopover (password_button, user);
                pw_popover.show_all ();
                pw_popover.request_password_change.connect (utils.change_password);
            });
            attach (password_button, 1, 4, 1, 1);

            enable_user_button = new Gtk.Button ();
            enable_user_button.clicked.connect (utils.change_lock);
            enable_user_button.set_sensitive (false);
            enable_user_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            enable_user_button.set_size_request (0, 27);
            attach (enable_user_button, 1, 6, 1, 1);

            full_name_lock = new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON);
            full_name_lock.set_tooltip_text (no_permission_string);
            attach (full_name_lock, 2, 0, 1, 1);

            user_type_lock = new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON);
            user_type_lock.set_tooltip_text (no_permission_string);
            attach (user_type_lock, 2, 1, 1, 1);

            language_lock = new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON);
            language_lock.set_tooltip_text (no_permission_string);
            attach (language_lock, 2, 2, 1, 1);

            autologin_lock = new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON);
            autologin_lock.set_tooltip_text (no_permission_string);
            autologin_lock.margin_top = 20;
            attach (autologin_lock, 2, 3, 1, 1);

            password_lock = new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON);
            password_lock.set_tooltip_text (no_permission_string);
            attach (password_lock, 2, 4, 1, 1);

            enable_lock = new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON);
            enable_lock.set_tooltip_text (no_permission_string);
            attach (enable_lock, 2, 6, 1, 1);

            update_ui ();
            get_permission ().notify["allowed"].connect (update_ui);
        }
        
        public void update_ui () {
            user_type_box.set_sensitive (false);
            password_button.set_sensitive (false);
            autologin_switch.set_sensitive (false);
            enable_user_button.set_sensitive (false);

            user_type_lock.set_opacity (0.5);
            autologin_lock.set_opacity (0.5);
            password_lock.set_opacity (0.5);
            enable_lock.set_opacity (0.5);

            if (!get_permission ().allowed) {
                user_type_lock.set_tooltip_text (no_permission_string);
                enable_lock.set_tooltip_text (no_permission_string);
            } else if (get_current_user () == user) {
                user_type_lock.set_tooltip_text (current_user_string);
                enable_lock.set_tooltip_text (current_user_string);
            } else if (is_last_admin (user)) {
                user_type_lock.set_tooltip_text (last_admin_string);
                enable_lock.set_tooltip_text (last_admin_string);
            }

            if (get_current_user () == user || get_permission ().allowed) {
                avatar_button.set_sensitive (true);
                full_name_entry.set_sensitive (true);
                full_name_lock.set_opacity (0);
                language_box.set_sensitive (true);
                language_lock.set_opacity (0);
                if (!user.get_locked ()) {
                    password_button.set_sensitive (true);
                    password_lock.set_opacity (0);
                }
                if (get_permission ().allowed) {
                    if (!user.get_locked ()) {
                        autologin_switch.set_sensitive (true);
                        autologin_lock.set_opacity (0);
                    }
                    if (!is_last_admin (user) && get_current_user () != user) {
                        user_type_box.set_sensitive (true);
                        user_type_lock.set_opacity (0);
                    }
                }
            } else {
                avatar_button.set_sensitive (false);
                full_name_entry.set_sensitive (false);
                full_name_lock.set_opacity (0.5);
                language_box.set_sensitive (false);
                language_lock.set_opacity (0.5);
            }

            try {
                avatar_pixbuf = new Gdk.Pixbuf.from_file_at_scale (user.get_icon_file (), 72, 72, true);
                if (avatar == null)
                    avatar = new Gtk.Image.from_pixbuf (avatar_pixbuf);
                else
                    avatar.set_from_pixbuf (avatar_pixbuf);
            } catch (Error e) {
                Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
                try {
                    avatar_pixbuf = icon_theme.load_icon ("avatar-default", 72, 0);
                    avatar = new Gtk.Image.from_pixbuf (avatar_pixbuf);
                } catch (Error e) { }
            }
            avatar_button.set_image (avatar);

            full_name_entry.set_text (user.get_real_name ());

            //set user_type_box according to accounttype
            if (user.get_account_type () == Act.UserAccountType.ADMINISTRATOR)
                user_type_box.set_active (1);
            else
                user_type_box.set_active (0);

            //set autologin_switch according to autologin
            if (user.get_automatic_login () && !autologin_switch.get_active ())
                autologin_switch.set_active (true);
            else if (!user.get_automatic_login () && autologin_switch.get_active ())
                autologin_switch.set_active (false);

            if (user.get_password_mode () == Act.UserPasswordMode.NONE || user.get_locked ())
                password_button.set_label (_("None set"));
            else
                password_button.set_label ("**********");

            if (user.get_locked ()) {
                enable_user_button.set_label (_("Enable User Account"));
                enable_user_button.get_style_context ().remove_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            } else if (!user.get_locked ())
                enable_user_button.set_label (_("Disable User Account"));

            if (get_permission ().allowed && get_current_user () != user && !is_last_admin (user)) {
                enable_user_button.set_sensitive (true);
                enable_lock.set_opacity (0);
                if (!user.get_locked ())
                    enable_user_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            }

            if (user != get_current_user ()) {
                int i = 0;
                foreach (string s in get_installed_languages ()) {
                    if (user.get_language () == s) {
                        language_box.set_active (i);
                        break;
                    }
                    i++;
                }
            } else {
                var language = user.get_language ();
                if (user.get_language ().length == 2)
                    language = Gnome.Languages.get_language_from_code (language, null);
                else if (user.get_language ().length == 5)
                    language = Gnome.Languages.get_language_from_locale (language, null);
                language_button.set_label (language);
            }

            show_all ();
        }

        private void avatar_button_clicked () {
            PasswdErrorNotifier.get_default ().unset_error ();

            avatar_popover = new Gtk.Popover (avatar_button);
            avatar_popover.set_position (Gtk.PositionType.BOTTOM);

            Gtk.Grid popover_grid = new Gtk.Grid ();
            popover_grid.margin = 12;
            popover_grid.column_spacing = 10;
            popover_grid.row_spacing = 10;
            avatar_popover.add (popover_grid);

            Gtk.Button select_button = new Gtk.Button.with_label (_("Set from File ..."));
            Gtk.Button remove_button = new Gtk.Button.with_label (_("Remove Avatar"));
            select_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            popover_grid.attach (select_button, 1, 1, 1, 1);
            popover_grid.attach (remove_button, 0, 1, 1, 1);

            if (user.get_icon_file ().contains (".face"))
                remove_button.set_sensitive (false);
            else {
                remove_button.set_sensitive (true);
                remove_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            }

            avatar_popover.show_all ();

            select_button.grab_focus ();

            remove_button.clicked.connect (() => utils.change_avatar (null));

            select_button.clicked.connect (() => {
                var file_dialog = new Gtk.FileChooserDialog (_("Select an image"),
                get_parent_window () as Gtk.Window?, Gtk.FileChooserAction.OPEN, _("Cancel"),
                Gtk.ResponseType.CANCEL, _("Open"), Gtk.ResponseType.ACCEPT);
            
                Gtk.FileFilter filter = new Gtk.FileFilter ();
                filter.set_filter_name (_("Images"));
                file_dialog.set_filter (filter);
                filter.add_mime_type ("image/jpeg");
                filter.add_mime_type ("image/jpg");
                filter.add_mime_type ("image/png");

                // Add a preview widget
                Gtk.Image preview_area = new Gtk.Image ();
                file_dialog.set_preview_widget (preview_area);
                file_dialog.update_preview.connect (() => {
                    string uri = file_dialog.get_preview_uri ();
                    // We only display local files:
                    if (uri != null && uri.has_prefix ("file://") == true) {
                        try {
                            Gdk.Pixbuf pixbuf = new Gdk.Pixbuf.from_file_at_scale (uri.substring (7), 150,     150, true);
                            preview_area.set_from_pixbuf (pixbuf);
                            preview_area.show ();
                            file_dialog.set_preview_widget_active (true);
                        } catch (Error e) {
                            preview_area.hide ();
                            file_dialog.set_preview_widget_active (false);
                        }
                    } else {
                        preview_area.hide ();
                        file_dialog.set_preview_widget_active (false);
                    }
                });

                if (file_dialog.run () == Gtk.ResponseType.ACCEPT) {
                    var path = file_dialog.get_file ().get_path ();
                    file_dialog.hide ();
                    file_dialog.destroy ();
                    avatar_dialog = new Dialogs.AvatarDialog (path);
                    avatar_dialog.request_avatar_change.connect (utils.change_avatar);
                } else
                    file_dialog.close ();
            });
        }
    }
}