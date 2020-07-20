using System;
using System.IO;
using Grill.Utility;

namespace Grill
{
	public static class GrillPath
	{
		private static String mAppData = new String(Cpp.getenv("APPDATA"));

		public static StringView AppData => mAppData;

		public static String SourceDirectory   = new .() ~ delete _;
		public static String PackagesDirectory = new .() ~ delete _;
		public static String CacheDirectory    = new .() ~ delete _;
		public static String ConfigPath        = new .() ~ delete _;

		public static this()
		{
			var str = scope String();
			Environment.GetExecutableFilePath(str);
			Path.GetDirectoryPath(str, SourceDirectory);

			Path.InternalCombine(PackagesDirectory, SourceDirectory, "Packages");
			Path.InternalCombine(CacheDirectory, PackagesDirectory, "Cache");
			Path.InternalCombine(ConfigPath, SourceDirectory, "Config.toml");
		}
	}
}
