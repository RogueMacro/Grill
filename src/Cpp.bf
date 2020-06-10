using System;

namespace Grill
{
	public static class Cpp
	{
		[Import("kernel32.lib"), CLink]
		public static extern int32 system(char8* command);

		// Joe mama

		[Import("kernel32.lib"), CLink]
		public static extern char8* getenv(char8* env_var);
	}
}
