using System.Collections;

namespace System
{
	extension Environment
	{
		public static String GetEnvironmentVariable(String variable)
		{
			let dict = new Dictionary<String, String>();
			Environment.GetEnvironmentVariables(dict);

			if (!dict.ContainsKey(variable))
				return String.Empty;

			var value = new String(dict[variable]);
			DeleteDictionaryAndKeysAndItems!(dict);
			return value;
		}
	}
}
