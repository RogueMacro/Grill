using System;
using System.IO;

namespace Grill
{
	public static class SpecialFolder
	{
		private static String mAppData = new String(Cpp.getenv("APPDATA"));

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
