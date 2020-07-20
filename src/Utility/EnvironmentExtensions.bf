using System.Collections;

namespace System
{
	extension Environment
	{
		public static String GetEnvironmentVariable(String variable)
		{
			let dict = scope Dictionary<String, String>();
			Environment.GetEnvironmentVariables(dict);

			if (!dict.ContainsKey(variable))
			{
				return String.Empty;
			}
			return dict[variable];
		}
	}
}
