using System;

namespace Grill.Utility
{
	public static class Cpp
	{
		[Import("kernel32.lib"), CLink]
		public static extern int32 system(char8* command);

		[Import("kernel32.lib"), CLink]
		public static extern void exit(int status);
	}
}
