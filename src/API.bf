using System;

namespace Grill.API
{
	public static class API
	{
		public static void GetPackageRepoUrl(StringView name, String target)
		{
			// Todo: Get package from GraphQL API
			target.Set("https://github.com/roguemacro/steak.logging");
		}
	}
}
