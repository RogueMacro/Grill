using System;
using System.Collections;
using System.IO;
using Grill.Utility;

namespace Grill
{
	public static class SpecialFolder
	{
		/*private static String mAppData = new String(Cpp.getenv("APPDATA"));*/
		private static String mAppData = new String(Environment.GetEnvironmentVariable("APPDATA"));

		public static StringView AppData => mAppData;

		public static String SourceDirectory = new String();
		public static String PackagesFolder = new String();

		public static this()
		{
			var str = scope String();
			Environment.GetExecutableFilePath(str);
			Path.GetDirectoryPath(str, SourceDirectory);

			Path.InternalCombine(PackagesFolder, SourceDirectory, "packages");
		}

		public static ~this()
		{
			delete mAppData;
			delete SourceDirectory;
			delete PackagesFolder;
		}
	}
}
