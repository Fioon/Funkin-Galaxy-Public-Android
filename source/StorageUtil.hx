package;

#if android
import android.content.Context as AndroidContext;
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.Tools as AndroidTools;
import android.os.Build.VERSION as AndroidVersion;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
import android.os.Environment as AndroidEnvironment;
#end
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.Assets as OpenFlAssets;
import openfl.Lib;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import flash.system.System;

/**
 * ...
 * @author: Saw (M.A. Jigsaw)
 */

using StringTools;

class StorageUtil
{
        #if android
        private static var aDir:String = null; // android dir
        #end

        public static function getPath():String
        {
                #if android
                if (aDir != null && aDir.length > 0)
                        return aDir;
                else
                        return aDir = AndroidEnvironment.getExternalStorageDirectory() + '/.' + Application.current.meta.get('file') + '/';
                #else
                return '';
                #end
        }

        public static function requestPermissionsAndCheck()
        {
                #if android
                if (!AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE') || !AndroidPermissions.getGrantedPermissions().contains('android.permission.WRITE_EXTERNAL_STORAGE'))
                {
                        AndroidPermissions.requestPermission(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);
                        StorageUtil.applicationAlert('Permissions', "if you acceptd the permissions all good if not expect a crash" + '\n' + 'Press Ok to see what happens');
                }

                if (AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE') || AndroidPermissions.getGrantedPermissions().contains('android.permission.WRITE_EXTERNAL_STORAGE'))
                {
                        if (!FileSystem.exists(AndroidEnvironment.getExternalStorageDirectory() + '/' + '.' + Application.current.meta.get('file')))
                                FileSystem.createDirectory(AndroidEnvironment.getExternalStorageDirectory() + '/' + '.' + Application.current.meta.get('file'));

                        if (!FileSystem.exists(StorageUtil.getPath() + 'assets') && !FileSystem.exists(StorageUtil.getPath() + 'mods'))
                        {
                                StorageUtil.applicationAlert('Uncaught Error :( !', "Whoops, seems you didn't extract the files from the .APK!\nPlease watch the tutorial by pressing OK.");
                                CoolUtil.browserLoad('https://youtu.be/zjvkTmdWvfU');
                                System.exit(0);
                        }
                        else
                        {
                                if (!FileSystem.exists(StorageUtil.getPath() + 'assets'))
                                {
                                        StorageUtil.applicationAlert('Uncaught Error :(!', "Whoops, seems you didn't extract the assets/assets folder from the .APK!\nPlease watch the tutorial by pressing OK.");
                                        CoolUtil.browserLoad('https://youtu.be/zjvkTmdWvfU');
                                        System.exit(0);
                                }

                                if (!FileSystem.exists(StorageUtil.getPath() + 'mods'))
                                {
                                        StorageUtil.applicationAlert('Uncaught Error :(!', "Whoops, seems you didn't extract the assets/mods folder from the .APK!\nPlease watch the tutorial by pressing OK.");
                                        CoolUtil.browserLoad('https://youtu.be/zjvkTmdWvfU');
                                        System.exit(0);
                                }
                        }
                }
                #end
        }

        public static function gameCrashCheck()
        {
                Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
        }

        public static function onCrash(e:UncaughtErrorEvent):Void
        {
                var callStack:Array<StackItem> = CallStack.exceptionStack(true);
                var dateNow:String = Date.now().toString();
                dateNow = StringTools.replace(dateNow, " ", "_");
                dateNow = StringTools.replace(dateNow, ":", "'");

                var path:String = "crash/" + "crash_" + dateNow + ".txt";
                var errMsg:String = "";

                for (stackItem in callStack)
                {
                        switch (stackItem)
                        {
                                case FilePos(s, file, line, column):
                                        errMsg += file + " (line " + line + ")\n";
                                default:
                                        Sys.println(stackItem);
                        }
                }

                errMsg += e.error;

                if (!FileSystem.exists(StorageUtil.getPath() + "crash"))
                FileSystem.createDirectory(StorageUtil.getPath() + "crash");

                File.saveContent(StorageUtil.getPath() + path, errMsg + "\n");

                Sys.println(errMsg);
                Sys.println("Crash dump saved in " + Path.normalize(path));
                Sys.println("Making a simple alert ...");

                StorageUtil.applicationAlert("Uncaught Error :(!", errMsg);
                System.exit(0);
        }

        private static function applicationAlert(title:String, description:String)
        {
                Application.current.window.alert(description, title);
        }

        #if android
        public static function saveContent(fileName:String = 'file', fileExtension:String = '.json', fileData:String = 'you forgot something to add in your code')
        {
                if (!FileSystem.exists(StorageUtil.getPath() + 'saves'))
                        FileSystem.createDirectory(StorageUtil.getPath() + 'saves');

                File.saveContent(StorageUtil.getPath() + 'saves/' + fileName + fileExtension, fileData);
                StorageUtil.applicationAlert('Done :)!', 'File Saved Successfully!');
        }

        public static function saveClipboard(fileData:String = 'you forgot something to add in your code')
        {
                openfl.system.System.setClipboard(fileData);
                StorageUtil.applicationAlert('Done :)!', 'Data Saved to Clipboard Successfully!');
        }

        public static function copyContent(copyPath:String, savePath:String)
        {
                if (!FileSystem.exists(savePath))
                        File.saveBytes(savePath, OpenFlAssets.getBytes(copyPath));
        }
        #end
}
